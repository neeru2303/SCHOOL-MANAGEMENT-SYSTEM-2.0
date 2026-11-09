import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../core/database/prisma.service.js';
import { PasswordService } from '../passwords/password.service.js';

import { createHash, randomBytes } from 'crypto';
import { LoginDto } from '../authentication/dto/auth.dto.js';

const ACCESS_TOKEN_TTL = 15 * 60;
const REFRESH_TOKEN_DAYS = 30;

@Injectable()
export class AuthService {
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
      expiry.getDate() + REFRESH_TOKEN_DAYS,
    );

    return expiry;
  }

  private async generateAccessToken(
    userId: string,
    sessionId: string,
    schoolId: string,
    membershipId: string,
  ): Promise<string> {
    return this.jwtService.signAsync({
      sub: userId,
      sid: sessionId,
      schoolId,
      membershipId,
    });
  }

  private async createTokenResponse(
    userId: string,
    sessionId: string,
    schoolId: string,
    membershipId: string,
    refreshToken: string,
  ) {
    const accessToken = await this.generateAccessToken(
      userId,
      sessionId,
      schoolId,
      membershipId,
    );

    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: ACCESS_TOKEN_TTL,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: {
        email: dto.email.trim().toLowerCase(),
      },
      include: {
        membership: {
          include: {
            school: true,
          },
        },
      },
    });

    if (!user) {
      throw new UnauthorizedException(
        'Invalid school code, email or password.',
      );
    }

    const passwordValid =
      user.passwordHash !== null &&
      await this.passwordService.verifyPassword(
        dto.password,
        user.passwordHash,
      );

    if (!passwordValid) {
      throw new UnauthorizedException(
        'Invalid school code, email or password.',
      );
    }

    const membership = user.membership;

    if (
      !membership ||
      membership.school.code.toLowerCase() !==
        dto.schoolCode.trim().toLowerCase() ||
      user.status !== 'ACTIVE' ||
      membership.status !== 'ACTIVE' ||
      membership.school.status !== 'ACTIVE'
    ) {
      throw new UnauthorizedException(
        'Invalid school code, email or password.',
      );
    }

    const refreshToken = this.generateRefreshToken();

    const session = await this.prisma.authSession.create({
      data: {
        userId: user.id,
        sessionType: 'SCHOOL',
        refreshTokenHash:
          this.hashRefreshToken(refreshToken),
        expiresAt: this.getRefreshExpiry(),
      },
    });

    const tokens = await this.createTokenResponse(
      user.id,
      session.id,
      membership.school.id,
      membership.id,
      refreshToken,
    );

    return {
      ...tokens,
      user: {
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
      },
      school: {
        id: membership.school.id,
        name: membership.school.name,
        code: membership.school.code,
      },
    };
  }

  async refresh(refreshToken: string) {
    const tokenHash = this.hashRefreshToken(refreshToken);

    const session = await this.prisma.authSession.findFirst({
      where: {
        refreshTokenHash: tokenHash,
        sessionType: 'SCHOOL',
      },
      include: {
        user: {
          include: {
            membership: {
              include: {
                school: true,
              },
            },
          },
        },
      },
    });

    const now = new Date();

    if (
      !session ||
      session.revokedAt ||
      session.expiresAt <= now
    ) {
      throw new UnauthorizedException(
        'Invalid or expired refresh token.',
      );
    }

    const user = session.user;
    const membership = user.membership;

    if (
      !membership ||
      user.status !== 'ACTIVE' ||
      membership.status !== 'ACTIVE' ||
      membership.school.status !== 'ACTIVE'
    ) {
      throw new UnauthorizedException(
        'Your account or school is inactive.',
      );
    }

    const newRefreshToken = this.generateRefreshToken();

    const newSession = await this.prisma.$transaction(
      async (tx) => {
        const revoked = await tx.authSession.updateMany({
          where: {
            id: session.id,
            sessionType: 'SCHOOL',
            revokedAt: null,
            expiresAt: {
              gt: now,
            },
          },
          data: {
            revokedAt: now,
            lastUsedAt: now,
          },
        });

        if (revoked.count !== 1) {
          throw new UnauthorizedException(
            'Refresh token has already been used.',
          );
        }

        return tx.authSession.create({
          data: {
            userId: user.id,
            sessionType: 'SCHOOL',
            refreshTokenHash:
              this.hashRefreshToken(newRefreshToken),
            expiresAt: this.getRefreshExpiry(),
          },
        });
      },
    );

    const tokens = await this.createTokenResponse(
      user.id,
      newSession.id,
      membership.school.id,
      membership.id,
      newRefreshToken,
    );

    return tokens;
  }

  async logout(sessionId: string) {
    await this.prisma.authSession.updateMany({
      where: {
        id: sessionId,
        sessionType: 'SCHOOL',
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });

    return {
      message: 'Successfully logged out.',
    };
  }
}