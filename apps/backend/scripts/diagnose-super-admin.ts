import dotenv from 'dotenv';
dotenv.config({ path: '../../.env' });

import { PrismaService } from '../src/core/database/prisma.service.js';
import { PasswordService } from '../src/identity/passwords/password.service.js';

async function main() {
  const prisma = new PrismaService();
  const passwordService = new PasswordService();

  try {
    await prisma.$connect();

    const secure = await import('node:readline/promises');
    const terminal = secure.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    const password = await terminal.question(
      'Enter the latest generated Super Admin password: ',
    );

    terminal.close();

    const user = await prisma.user.findUnique({
      where: { email: 'admin@schoolerp.com' },
      select: {
        id: true,
        status: true,
        passwordHash: true,
      },
    });

    if (!user || !user.passwordHash) {
      console.log('ACCOUNT CHECK: FAILED');
      return;
    }

    const passwordMatches =
      await passwordService.verifyPassword(
        password,
        user.passwordHash,
      );

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

    console.log('\n--- DIAGNOSTIC RESULTS ---');
    console.log('Account active:', user.status === 'ACTIVE');
    console.log('Password matches:', passwordMatches);
    console.log('Active SUPER_ADMIN role:', Boolean(role));

    console.log('--------------------------');
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((error) => {
  console.error('Diagnostic failed:', error.message);
  process.exitCode = 1;
});