import dotenv from 'dotenv';
import argon2 from 'argon2';
import { randomBytes } from 'node:crypto';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client.js';

dotenv.config({ path: '../../.env' });

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is missing from the environment.');
}

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL,
});

const prisma = new PrismaClient({ adapter });

const SUPER_ADMIN_EMAIL = 'admin@schoolerp.com';

const PLATFORM_PERMISSION_CODES = [
  'platform.schools.view',
  'platform.schools.manage',
  'platform.users.view',
  'platform.users.manage',
  'platform.roles.view',
  'platform.roles.manage',
  'platform.permissions.manage',
  'platform.audit.view',
];

async function main() {
  console.log('Starting Platform Super Admin bootstrap...\n');

  // 1. Check whether the email already exists.
  const existingUser = await prisma.user.findUnique({
    where: { email: SUPER_ADMIN_EMAIL },
    include: {
      membership: true,
      platformRoles: true,
    },
  });

  if (existingUser) {
    const alreadySuperAdmin = existingUser.platformRoles.length > 0;

    if (alreadySuperAdmin) {
      console.log('A platform account with this email already exists.');
      console.log('No changes were made.');
      return;
    }

    throw new Error(
      'This email already belongs to another user. ' +
      'Bootstrap stopped to prevent account takeover. ' +
      'Use a different email or investigate the existing account.',
    );
  }

  // 2. Verify the platform permission catalogue.
  const permissions = await prisma.permission.findMany({
    where: {
      code: { in: PLATFORM_PERMISSION_CODES },
      scope: 'PLATFORM',
    },
  });

  if (permissions.length !== PLATFORM_PERMISSION_CODES.length) {
    throw new Error(
      'Platform permission catalogue is incomplete. ' +
      'Run the permission seed script first.',
    );
  }

  // 3. Generate a secure initial password.
  const initialPassword = randomBytes(24).toString('base64url');

  const passwordHash = await argon2.hash(initialPassword, {
    type: argon2.argon2id,
    memoryCost: 19456,
    timeCost: 2,
    parallelism: 1,
  });

  // 4. Create the role, permission assignments and owner account.
  const result = await prisma.$transaction(async (tx) => {
    const role = await tx.platformRole.upsert({
      where: { code: 'SUPER_ADMIN' },
      update: {
        name: 'Super Administrator',
        description: 'Full platform-level administrative authority.',
        status: 'ACTIVE',
      },
      create: {
        code: 'SUPER_ADMIN',
        name: 'Super Administrator',
        description: 'Full platform-level administrative authority.',
        status: 'ACTIVE',
      },
    });

    await tx.platformRolePermission.createMany({
      data: permissions.map((permission) => ({
        roleId: role.id,
        permissionId: permission.id,
      })),
      skipDuplicates: true,
    });

    const user = await tx.user.create({
      data: {
        firstName: 'Platform',
        lastName: 'Owner',
        email: SUPER_ADMIN_EMAIL,
        passwordHash,
        status: 'ACTIVE',
      },
    });

    await tx.platformUserRole.create({
      data: {
        userId: user.id,
        roleId: role.id,
      },
    });

    return { user, role };
  });

  console.log('\n======================================');
  console.log('SUPER ADMIN CREATED SUCCESSFULLY');
  console.log('======================================');
  console.log(`Email: ${result.user.email}`);
  console.log(`Role: ${result.role.code}`);
  console.log(`Permissions: ${permissions.length}`);
  console.log('\nINITIAL PASSWORD (SAVE IT NOW):');
  console.log(initialPassword);
  console.log('\n======================================');
  console.log('Store this password securely.');
  console.log('It will not be displayed again.');
  console.log('======================================');
}

main()
  .catch((error) => {
    console.error('\nSuper Admin bootstrap failed:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });