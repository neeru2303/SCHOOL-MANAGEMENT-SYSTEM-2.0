import dotenv from 'dotenv';
import { randomBytes } from 'node:crypto';
import * as argon2 from 'argon2';

import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client.js';

dotenv.config({ path: '../../.env' });

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error('DATABASE_URL is missing.');
}

const prisma = new PrismaClient({
  adapter: new PrismaPg({
    connectionString: databaseUrl,
  }),
});

async function main() {
  const schoolCode = 'SCHOOL_001';
  const email = 'admin@school001.com';

  // Generate a strong development password.
  const initialPassword = randomBytes(18).toString('base64url');

  const passwordHash = await argon2.hash(initialPassword, {
    type: argon2.argon2id,
    memoryCost: 19456,
    timeCost: 2,
    parallelism: 1,
  });

  const result = await prisma.$transaction(async (tx) => {
    const existingUser = await tx.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new Error(
        `User ${email} already exists. No records were changed.`,
      );
    }

    let school = await tx.school.findUnique({
      where: { code: schoolCode },
    });

    if (!school) {
      school = await tx.school.create({
        data: {
          name: 'Sandipani Academy',
          code: schoolCode,
          status: 'ACTIVE',
        },
      });
    }

    const user = await tx.user.create({
      data: {
        firstName: 'School',
        lastName: 'Administrator',
        email,
        passwordHash,
        status: 'ACTIVE',

        membership: {
          create: {
            schoolId: school.id,
            status: 'ACTIVE',
          },
        },
      },
    });

    return { school, user };
  });

  console.log('\n====================================');
  console.log(' DEVELOPMENT SCHOOL CREATED');
  console.log('====================================');

  console.log('School:', result.school.name);
  console.log('School Code:', result.school.code);
  console.log('User:', result.user.email);

  console.log('\nINITIAL PASSWORD:', initialPassword);

  console.log('\nIMPORTANT: Save this password securely.');
  console.log('It will not be displayed again.');

  console.log('====================================\n');
}

main()
  .catch((error) => {
    console.error('Seed operation failed:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });