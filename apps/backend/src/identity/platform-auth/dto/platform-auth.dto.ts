import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MaxLength,
  Matches,
} from 'class-validator';

export class PlatformLoginDto {
  @IsEmail()
  @MaxLength(255)
  email!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(256)
  password!: string;
}

export class PlatformRefreshTokenDto {
  @IsString()
  @IsNotEmpty()
  refreshToken!: string;
}

export class PlatformRememberDeviceDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  deviceKey!: string;

  @IsString()
  @Matches(/^\d{6}$/)
  pin!: string;
}

export class PlatformDeviceUnlockDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  deviceKey!: string;

  @IsString()
  @Matches(/^\d{6}$/)
  pin!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(256)
  refreshToken!: string;
}

export class PlatformForgetDeviceDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(128)
  deviceKey!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(256)
  refreshToken!: string;
}
