import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../core/database/prisma.service.js';
import { PasswordService } from '../passwords/password.service.js';

import {
  createHash,
  randomBytes,
} from 'node:crypto';

@Injectable()
export class PlatformAuthService {
  private readonly accessTokenTtl = 15 * 60;
  private readonly refreshTokenDays = 30;

  constructor(
    private readonly prisma: PrismaService,
    private readonly passwordService: PasswordService,
    private readonly jwtService: JwtService,
  ) {}

  private hashRefreshToken(token: string): string {
    return createHash('sha256')
      .update(token)
      .digest('hex');
  }

  private generateRefreshToken(): string {
    return randomBytes(32).toString('base64url');
  }

  private getRefreshExpiry(): Date {
    const expiry = new Date();

    expiry.setDate(
      expiry.getDate() + this.refreshTokenDays,
    );

    return expiry;
  }

  private async generateAccessToken(
    userId: string,
    sessionId: string,
  ): Promise<string> {
    return this.jwtService.signAsync({
      sub: userId,
      sid: sessionId,
      scope: 'PLATFORM',
    });
  }

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: {
        email: email.trim().toLowerCase(),
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        passwordHash: true,
        status: true,
      },
    });

    if (
      !user ||
      !user.passwordHash ||
      !(await this.passwordService.verifyPassword(
        password,
        user.passwordHash,
      ))
    ) {
      throw new UnauthorizedException(
        'Invalid email or password.',
      );
    }

    if (user.status !== 'ACTIVE') {
      throw new UnauthorizedException(
        'This account is not active.',
      );
    }

    const platformRole =
      await this.prisma.platformUserRole.findFirst({
        where: {
          userId: user.id,
          role: {
            is: {
              status: 'ACTIVE',
            },
          },
        },
        include: {
          role: true,
        },
      });

    if (!platformRole) {
      throw new UnauthorizedException(
        'Platform access is not assigned to this account.',
      );
    }

    const refreshToken = this.generateRefreshToken();

    const session = await this.prisma.authSession.create({
      data: {
        userId: user.id,
        refreshTokenHash:
          this.hashRefreshToken(refreshToken),
        sessionType: 'PLATFORM',
        expiresAt: this.getRefreshExpiry(),
      },
    });

    const accessToken = await this.generateAccessToken(
      user.id,
      session.id,
    );

    return {
      accessToken,
      refreshToken,

      expiresIn: this.accessTokenTtl,

      user: {
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
      },

      role: {
        code: platformRole.role.code,
        name: platformRole.role.name,
      },
    };
  }

  async refresh(refreshToken: string) {
    const tokenHash =
      this.hashRefreshToken(refreshToken);

    const session =
      await this.prisma.authSession.findFirst({
        where: {
          refreshTokenHash: tokenHash,
          sessionType: 'PLATFORM',
        },
        include: {
          user: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              status: true,
            },
          },
        },
      });

    if (
      !session ||
      session.revokedAt ||
      session.expiresAt <= new Date() ||
      session.user.status !== 'ACTIVE'
    ) {
      throw new UnauthorizedException(
        'Invalid or expired refresh token.',
      );
    }

    const platformRole =
      await this.prisma.platformUserRole.findFirst({
        where: {
          userId: session.userId,
          role: {
            is: {
              status: 'ACTIVE',
            },
          },
        },
        include: {
          role: true,
        },
      });

    if (!platformRole) {
      throw new UnauthorizedException(
        'Platform access is no longer active.',
      );
    }

    const newRefreshToken = this.generateRefreshToken();

    const newSession = await this.prisma.$transaction(
      async (tx) => {
        const revoked = await tx.authSession.updateMany({
          where: {
            id: session.id,
            userId: session.userId,
            sessionType: 'PLATFORM',
            revokedAt: null,
            expiresAt: {
              gt: new Date(),
            },
          },
          data: {
            revokedAt: new Date(),
            lastUsedAt: new Date(),
          },
        });

        if (revoked.count !== 1) {
          throw new UnauthorizedException(
            'Refresh token has already been used.',
          );
        }

        return tx.authSession.create({
          data: {
            userId: session.userId,
            refreshTokenHash:
              this.hashRefreshToken(newRefreshToken),
            sessionType: 'PLATFORM',
            expiresAt: this.getRefreshExpiry(),
          },
        });
      },
    );

    const accessToken = await this.generateAccessToken(
      session.userId,
      newSession.id,
    );

    return {
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: this.accessTokenTtl,

      user: {
        id: session.user.id,
        firstName: session.user.firstName,
        lastName: session.user.lastName,
        email: session.user.email,
      },

      role: {
        code: platformRole.role.code,
        name: platformRole.role.name,
      },
    };
  }

  async logout(userId: string, sessionId: string) {
    await this.prisma.authSession.updateMany({
      where: {
        id: sessionId,
        userId,
        sessionType: 'PLATFORM',
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });

    return {
      message: 'Logged out successfully.',
    };
  }
}