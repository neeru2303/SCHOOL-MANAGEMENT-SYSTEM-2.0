import { Injectable } from '@nestjs/common';
import * as argon2 from 'argon2';

@Injectable()
export class PasswordService {
  private readonly options: argon2.HashOptions = {
    type: argon2.argon2id,
    memoryCost: 19456,
    timeCost: 2,
    parallelism: 1,
  };

  // Hash a password before storing it.
  async hashPassword(password: string): Promise<string> {
    return await argon2.hash(password, this.options);
  }

  // Verify a password against its stored hash.
  async verifyPassword(
    password: string,
    passwordHash: string,
  ): Promise<boolean> {
    try {
      return await argon2.verify(passwordHash, password);
    } catch {
      return false;
    }
  }

  // Check whether the password hash needs upgrading.
  needsRehash(passwordHash: string): boolean {
    return argon2.needsRehash(passwordHash, this.options);
  }
}