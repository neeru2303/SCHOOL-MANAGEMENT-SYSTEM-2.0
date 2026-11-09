import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../../core/database/prisma.service.js';

interface CreateSchoolRoleInput {
  code: string;
  name: string;
  description?: string;
}

interface UpdateSchoolRoleInput {
  name?: string;
  description?: string;
  status?: 'ACTIVE' | 'INACTIVE';
}

@Injectable()
export class RolesService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  // CREATE SCHOOL ROLE
  async createSchoolRole(
    schoolId: string,
    input: CreateSchoolRoleInput,
  ) {
    const code = input.code.trim().toUpperCase();
    const name = input.name.trim();

    if (!code || !name) {
      throw new BadRequestException(
        'Role code and name are required.',
      );
    }

    try {
      return await this.prisma.schoolRole.create({
        data: {
          schoolId,
          code,
          name,
          description: input.description?.trim() || null,
        },
      });
    } catch (error) {
      if (
        typeof error === 'object' &&
        error !== null &&
        'code' in error &&
        error.code === 'P2002'
      ) {
        throw new ConflictException(
          'A role with this code already exists in this school.',
        );
      }

      throw error;
    }
  }

  // GET SCHOOL ROLES
  async getSchoolRoles(schoolId: string) {
    return this.prisma.schoolRole.findMany({
      where: { schoolId },
      include: {
        permissions: {
          include: {
            permission: true,
          },
        },
      },
      orderBy: {
        createdAt: 'asc',
      },
    });
  }

  // UPDATE SCHOOL ROLE
  async updateSchoolRole(
    schoolId: string,
    roleId: string,
    input: UpdateSchoolRoleInput,
  ) {
    const role = await this.prisma.schoolRole.findFirst({
      where: {
        id: roleId,
        schoolId,
      },
    });

    if (!role) {
      throw new NotFoundException('School role not found.');
    }

    if (role.isSystem) {
      throw new ForbiddenException(
        'System roles cannot be modified.',
      );
    }

    return this.prisma.schoolRole.update({
      where: { id: roleId },
      data: {
        ...(input.name !== undefined && {
          name: input.name.trim(),
        }),
        ...(input.description !== undefined && {
          description: input.description.trim() || null,
        }),
        ...(input.status !== undefined && {
          status: input.status,
        }),
      },
    });
  }

  // SET ROLE PERMISSIONS
  async setRolePermissions(
    schoolId: string,
    roleId: string,
    permissionCodes: string[],
  ) {
    const role = await this.prisma.schoolRole.findFirst({
      where: {
        id: roleId,
        schoolId,
      },
    });

    if (!role) {
      throw new NotFoundException('School role not found.');
    }

    if (role.isSystem) {
      throw new ForbiddenException(
        'System role permissions cannot be modified.',
      );
    }

    const uniqueCodes = [
      ...new Set(permissionCodes.map((code) => code.trim())),
    ];

    return this.prisma.$transaction(async (tx) => {
      const permissions = await tx.permission.findMany({
        where: {
          code: { in: uniqueCodes },
          scope: 'SCHOOL',
        },
        select: {
          id: true,
          code: true,
        },
      });

      if (permissions.length !== uniqueCodes.length) {
        throw new BadRequestException(
          'Invalid or non-school permission code supplied.',
        );
      }

      await tx.rolePermission.deleteMany({
        where: { roleId },
      });

      if (permissions.length > 0) {
        await tx.rolePermission.createMany({
          data: permissions.map((permission) => ({
            roleId,
            permissionId: permission.id,
          })),
        });
      }

      return {
        roleId,
        permissions: permissions.map(
          (permission) => permission.code,
        ),
      };
    });
  }

  // ASSIGN SCHOOL ROLE
  async assignSchoolRole(
    schoolId: string,
    membershipId: string,
    roleId: string,
  ) {
    const [membership, role] = await Promise.all([
      this.prisma.schoolMembership.findFirst({
        where: {
          id: membershipId,
          schoolId,
          status: 'ACTIVE',
        },
      }),

      this.prisma.schoolRole.findFirst({
        where: {
          id: roleId,
          schoolId,
          status: 'ACTIVE',
        },
      }),
    ]);

    if (!membership) {
      throw new NotFoundException(
        'Active school membership not found.',
      );
    }

    if (!role) {
      throw new NotFoundException(
        'Active school role not found.',
      );
    }

    return this.prisma.membershipRole.upsert({
      where: {
        membershipId_roleId: {
          membershipId,
          roleId,
        },
      },
      update: {},
      create: {
        membershipId,
        roleId,
        schoolId,
      },
    });
  }

  // ASSIGN BRANCH ROLE
  async assignBranchRole(
    schoolId: string,
    membershipId: string,
    branchId: string,
    roleId: string,
  ) {
    const [branchMembership, role] = await Promise.all([
      this.prisma.branchMembership.findFirst({
        where: {
          membershipId,
          branchId,
          schoolId,
        },
      }),

      this.prisma.schoolRole.findFirst({
        where: {
          id: roleId,
          schoolId,
          status: 'ACTIVE',
        },
      }),
    ]);

    if (!branchMembership) {
      throw new NotFoundException(
        'Member does not belong to this branch.',
      );
    }

    if (!role) {
      throw new NotFoundException(
        'Active school role not found.',
      );
    }

    return this.prisma.branchMembershipRole.upsert({
      where: {
        membershipId_branchId_roleId: {
          membershipId,
          branchId,
          roleId,
        },
      },
      update: {},
      create: {
        membershipId,
        branchId,
        roleId,
        schoolId,
      },
    });
  }
}