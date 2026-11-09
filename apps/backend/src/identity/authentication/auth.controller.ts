import {
  Body,
  Controller,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { AuthService } from './auth.service.js';
import { LoginDto, RefreshTokenDto } from './dto/auth.dto.js';
import { JwtAuthGuard } from './jwt-auth.guard.js';

interface AuthenticatedRequest {
  user: {
    userId: string;
    sessionId: string;
    schoolId: string;
    membershipId: string;
  };
}

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
  ) {}

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('refresh')
  refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refresh(dto.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  logout(@Req() request: AuthenticatedRequest) {
    return this.authService.logout(
      request.user.sessionId,
    );
  }
}