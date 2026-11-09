import dotenv from 'dotenv';
dotenv.config({ path: '../../.env' });

import { PrismaService } from '../src/core/database/prisma.service.js';
import { PasswordService } from '../src/identity/passwords/password.service.js';

async function main() {
  const prisma = new PrismaService();
  const passwordService = new PasswordService();

  try {
    const password = process.env.SUPER_ADMIN_NEW_PASSWORD;

    if (!password || password.length < 12) {
      throw new Error('Password must contain at least 12 characters.');
    }

    await prisma.$connect();

    const user = await prisma.user.findUnique({
      where: { email: 'admin@schoolerp.com' },
      select: {
        id: true,
        status: true,
      },
    });

    if (!user || user.status !== 'ACTIVE') {
      throw new Error('Active Super Admin account not found.');
    }

    const role = await prisma.platformUserRole.findFirst({
      where: {
        userId: user.id,
        role: {
          is: {
            code: 'SUPER_ADMIN',
            status: 'ACTIVE',
          },
        },
      },
    });

    if (!role) {
      throw new Error('Active SUPER_ADMIN role not found.');
    }

    const passwordHash =
      await passwordService.hashPassword(password);

    const verified = await passwordService.verifyPassword(
      password,
      passwordHash,
    );

    if (!verified) {
      throw new Error('Password hash verification failed.');
    }

    await prisma.$transaction(async (tx) => {
      await tx.user.update({
        where: { id: user.id },
        data: { passwordHash },
      });

      await tx.authSession.updateMany({
        where: {
          userId: user.id,
          sessionType: 'PLATFORM',
          revokedAt: null,
        },
        data: {
          revokedAt: new Date(),
        },
      });
    });

    console.log('\nSUPER ADMIN PASSWORD UPDATED SUCCESSFULLY.');
    console.log('Password hash verified successfully.');
    console.log('Existing platform sessions revoked.');
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error) => {
  console.error('Password reset failed:', error.message);
  process.exitCode = 1;
});