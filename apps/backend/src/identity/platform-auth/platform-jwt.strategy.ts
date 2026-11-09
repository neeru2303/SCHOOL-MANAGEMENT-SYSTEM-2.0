import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { ConfigService } from '@nestjs/config';

import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { PrismaService } from '../../core/database/prisma.service.js';

import { PermissionsService } from '../authorization/permissions.service.js';

interface PlatformTokenPayload {
  sub: string;
  sid: string;
  scope: 'PLATFORM';
}

@Injectable()
export class PlatformJwtStrategy extends PassportStrategy(
  Strategy,
  'platform-jwt',
) {
  constructor(
    configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly permissionsService: PermissionsService,
  ) {
    super({
      jwtFromRequest:
        ExtractJwt.fromAuthHeaderAsBearerToken(),

      ignoreExpiration: false,

      secretOrKey: configService.getOrThrow<string>(
        'JWT_PLATFORM_ACCESS_SECRET',
      ),
    });
  }

  async validate(payload: PlatformTokenPayload) {
    if (
      !payload.sub ||
      !payload.sid ||
      payload.scope !== 'PLATFORM'
    ) {
      throw new UnauthorizedException(
        'Invalid platform access token.',
      );
    }

    const session =
      await this.prisma.authSession.findUnique({
        where: {
          id: payload.sid,
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
      session.sessionType !== 'PLATFORM' ||
      session.userId !== payload.sub ||
      session.revokedAt ||
      session.expiresAt <= new Date() ||
      session.user.status !== 'ACTIVE'
    ) {
      throw new UnauthorizedException(
        'Platform session is invalid or expired.',
      );
    }

    const platformRoles =
      await this.prisma.platformUserRole.findMany({
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

    if (platformRoles.length === 0) {
      throw new UnauthorizedException(
        'No active platform role assigned.',
      );
    }

    const permissions =
      await this.permissionsService.getPlatformPermissions(
        session.userId,
      );

    return {
      userId: session.user.id,
      sessionId: session.id,

      email: session.user.email,
      firstName: session.user.firstName,
      lastName: session.user.lastName,

      scope: 'PLATFORM',

      roles: platformRoles.map(
        (item) => item.role.code,
      ),

      permissions,
    };
  }
}