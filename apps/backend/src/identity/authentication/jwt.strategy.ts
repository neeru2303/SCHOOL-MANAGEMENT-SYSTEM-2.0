import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { PrismaService } from '../../core/database/prisma.service.js';
import { PermissionsService } from '../authorization/permissions.service.js';

export interface AccessTokenPayload {
  sub: string;
  sid: string;
  schoolId: string;
  membershipId: string;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly permissionsService: PermissionsService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.getOrThrow<string>(
        'JWT_ACCESS_SECRET',
      ),
    });
  }

  async validate(payload: AccessTokenPayload) {
    // Reject malformed or incomplete school token payloads.
    if (
      !payload.sub ||
      !payload.sid ||
      !payload.schoolId ||
      !payload.membershipId
    ) {
      throw new UnauthorizedException(
        'Invalid school authentication token.',
      );
    }

    const session = await this.prisma.authSession.findUnique({
      where: {
        id: payload.sid,
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

    if (!session) {
      throw new UnauthorizedException('Invalid session.');
    }

    const now = new Date();

    // School APIs must never accept platform sessions.
    if (
      session.sessionType !== 'SCHOOL' ||
      session.userId !== payload.sub ||
      session.revokedAt !== null ||
      session.expiresAt <= now
    ) {
      throw new UnauthorizedException(
        'Invalid, expired or revoked school session.',
      );
    }

    const user = session.user;
    const membership = user.membership;

    if (
      user.status !== 'ACTIVE' ||
      !membership ||
      membership.status !== 'ACTIVE' ||
      membership.id !== payload.membershipId ||
      membership.schoolId !== payload.schoolId ||
      membership.school.status !== 'ACTIVE'
    ) {
      throw new UnauthorizedException(
        'User or school membership is inactive.',
      );
    }

    const permissions =
      await this.permissionsService.getSchoolPermissions(
        membership.id,
        membership.schoolId,
      );

    return {
      userId: user.id,
      sessionId: session.id,
      schoolId: membership.schoolId,
      membershipId: membership.id,
      permissions,
    };
  }
}