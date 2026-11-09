import { Module } from '@nestjs/common';

import { ConfigModule, ConfigService } from '@nestjs/config';

import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';

import { PasswordModule } from '../passwords/password.module.js';

import { PermissionsService } from '../authorization/permissions.service.js';

import { PlatformAuthController } from './platform-auth.controller.js';
import { PlatformAuthService } from './platform-auth.service.js';
import { PlatformJwtStrategy } from './platform-jwt.strategy.js';
import { PlatformAuthGuard } from './platform-auth.guard.js';

@Module({
  imports: [
    ConfigModule,

    PasswordModule,

    PassportModule.register({
      defaultStrategy: 'platform-jwt',
    }),

    JwtModule.registerAsync({
      imports: [ConfigModule],

      inject: [ConfigService],

      useFactory: (configService: ConfigService) => ({
        secret: configService.getOrThrow<string>(
          'JWT_PLATFORM_ACCESS_SECRET',
        ),

        signOptions: {
          expiresIn: 900,
        },
      }),
    }),
  ],

  controllers: [
    PlatformAuthController,
  ],

  providers: [
    PlatformAuthService,
    PlatformJwtStrategy,
    PlatformAuthGuard,
    PermissionsService,
  ],

  exports: [
    PlatformAuthService,
    PlatformAuthGuard,
  ],
})
export class PlatformAuthModule {}