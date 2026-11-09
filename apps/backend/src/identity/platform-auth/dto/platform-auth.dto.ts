import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MaxLength,
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