import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { HealthModule } from './health/health.module.js';
import { DatabaseModule } from './core/database/database.module.js';
import { PasswordModule } from './identity/passwords/password.module.js';
import { AuthModule } from './identity/authentication/auth.module.js';
import { PlatformAuthModule } from './identity/platform-auth/plaform-auth.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '../../.env',
    }),

    DatabaseModule,
    PasswordModule,
    HealthModule,
    AuthModule,
    PlatformAuthModule,
  ],
})
export class AppModule {}