import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';

import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { AuthController } from './auth.controller.js';
import { AuthService } from './auth.service.js';
import { JwtStrategy } from './jwt.strategy.js';

import { PasswordModule } from '../passwords/password.module.js';
import { PermissionsService } from '../authorization/permissions.service.js';
import { PermissionsGuard } from '../authorization/permissions.guard.js';
import { RolesService } from '../authorization/roles.service.js';
import { RolesController } from '../authorization/roles.controller.js';

@Module({
  imports: [
    ConfigModule,

    PasswordModule,

    PassportModule.register({
      defaultStrategy: 'jwt',
    }),

    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.getOrThrow<string>(
          'JWT_ACCESS_SECRET',
        ),
        signOptions: {
          expiresIn: 900,
        },
      }),
    }),
  ],

  controllers: [
    AuthController,
    RolesController,
  ],

  providers: [
    AuthService,
    JwtStrategy,
    PermissionsService,
    PermissionsGuard,
    RolesService,
  ],

  exports: [
    AuthService,
    JwtModule,
    PassportModule,
    PermissionsService,
  ],
})
export class AuthModule {}