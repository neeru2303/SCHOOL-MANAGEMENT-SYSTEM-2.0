import dotenv from 'dotenv';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client.js';

dotenv.config({ path: '../../.env' });

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({ adapter });

const permissions = [
  // SCHOOL ROLE MANAGEMENT
  {
    code: 'school.roles.view',
    name: 'View School Roles',
    description: 'View roles configured for the school.',
    scope: 'SCHOOL' as const,
  },
  {
    code: 'school.roles.manage',
    name: 'Manage School Roles',
    description: 'Create and update school roles.',
    scope: 'SCHOOL' as const,
  },
  {
    code: 'school.roles.assign',
    name: 'Assign School Roles',
    description: 'Assign roles to school and branch members.',
    scope: 'SCHOOL' as const,
  },
  {
    code: 'school.permissions.manage',
    name: 'Manage Role Permissions',
    description: 'Assign permissions to school roles.',
    scope: 'SCHOOL' as const,
  },

  // PLATFORM MANAGEMENT
  {
    code: 'platform.schools.view',
    name: 'View Schools',
    description: 'View schools registered on the platform.',
    scope: 'PLATFORM' as const,
  },
  {
    code: 'platform.schools.manage',
    name: 'Manage Schools',
    description: 'Create, update, suspend and manage schools.',
    scope: 'PLATFORM' as const,
  },
  {
    code: 'platform.users.view',
    name: 'View Platform Users',
    description: 'View platform-level user accounts.',
    scope: 'PLATFORM' as const,
  },
  {
    code: 'platform.users.manage',
    name: 'Manage Platform Users',
    description: 'Manage platform-level user accounts.',
    scope: 'PLATFORM' as const,
  },
  {
    code: 'platform.roles.view',
    name: 'View Platform Roles',
    description: 'View platform-level roles.',
    scope: 'PLATFORM' as const,
  },
  {
    code: 'platform.roles.manage',
    name: 'Manage Platform Roles',
    description: 'Create and update platform-level roles.',
    scope: 'PLATFORM' as const,
  },
  {
    code: 'platform.permissions.manage',
    name: 'Manage Platform Permissions',
    description: 'Assign permissions to platform roles.',
    scope: 'PLATFORM' as const,
  },
  {
    code: 'platform.audit.view',
    name: 'View Platform Audit Logs',
    description: 'View platform-level audit records.',
    scope: 'PLATFORM' as const,
  },
];

async function main() {
  console.log('Starting permission catalogue seeding...');

  for (const permission of permissions) {
    await prisma.permission.upsert({
      where: {
        code: permission.code,
      },
      update: {
        name: permission.name,
        description: permission.description,
        scope: permission.scope,
      },
      create: permission,
    });

    console.log(`✓ ${permission.code}`);
  }

  console.log('\nPermission catalogue seeded successfully.');
  console.log(`Total permissions processed: ${permissions.length}`);
}

main()
  .catch((error) => {
    console.error('Permission seeding failed:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });