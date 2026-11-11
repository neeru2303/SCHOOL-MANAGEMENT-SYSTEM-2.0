import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { Request } from 'express';

import { PlatformAuthService } from './platform-auth.service.js';
import { PlatformAuthGuard } from './platform-auth.guard.js';

import {
  PlatformLoginDto,
  PlatformRefreshTokenDto,
  PlatformRememberDeviceDto,
  PlatformDeviceUnlockDto,
  PlatformForgetDeviceDto,
} from './dto/platform-auth.dto.js';

interface PlatformRequest extends Request {
  user: {
    userId: string;
    sessionId: string;
    email: string | null;
    firstName: string;
    lastName: string | null;
    scope: 'PLATFORM';
    roles: string[];
    permissions: string[];
  };
}

@Controller('platform/auth')
export class PlatformAuthController {
  constructor(
    private readonly platformAuthService: PlatformAuthService,
  ) {}

  @Post('login')
  async login(@Body() dto: PlatformLoginDto) {
    return this.platformAuthService.login(
      dto.email,
      dto.password,
    );
  }

  @Post('refresh')
  async refresh(
    @Body() dto: PlatformRefreshTokenDto,
  ) {
    return this.platformAuthService.refresh(
      dto.refreshToken,
    );
  }

  @Post('device/unlock')
  async unlockDevice(@Body() dto: PlatformDeviceUnlockDto) {
    return this.platformAuthService.unlockDevice(
      dto.deviceKey,
      dto.pin,
      dto.refreshToken,
    );
  }

  @Post('logout-session')
  async logoutByRefreshToken(@Body() dto: PlatformRefreshTokenDto) {
    return this.platformAuthService.logoutByRefreshToken(dto.refreshToken);
  }

  @Post('device/forget')
  async forgetDevice(@Body() dto: PlatformForgetDeviceDto) {
    return this.platformAuthService.forgetDevice(
      dto.deviceKey,
      dto.refreshToken,
    );
  }

  @UseGuards(PlatformAuthGuard)
  @Post('device/remember')
  async rememberDevice(
    @Req() request: PlatformRequest,
    @Body() dto: PlatformRememberDeviceDto,
  ) {
    return this.platformAuthService.rememberDevice(
      request.user.userId,
      request.user.sessionId,
      dto.deviceKey,
      dto.pin,
    );
  }

  @UseGuards(PlatformAuthGuard)
  @Post('logout')
  async logout(@Req() request: PlatformRequest) {
    return this.platformAuthService.logout(
      request.user.userId,
      request.user.sessionId,
    );
  }

  @UseGuards(PlatformAuthGuard)
  @Get('me')
  async me(@Req() request: PlatformRequest) {
    return request.user;
  }
}