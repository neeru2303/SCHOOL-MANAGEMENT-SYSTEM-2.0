import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../core/database/prisma.service.js';

@Injectable()
export class PermissionsService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  async getSchoolPermissions(
    membershipId: string,
    schoolId: string,
    branchId?: string,
  ): Promise<string[]> {
    const schoolAssignments =
      await this.prisma.membershipRole.findMany({
        where: {
          membershipId,
          schoolId,
          role: {
            status: 'ACTIVE',
          },
        },
        select: {
          role: {
            select: {
              permissions: {
                where: {
                  permission: {
                    scope: 'SCHOOL',
                  },
                },
                select: {
                  permission: {
                    select: {
                      code: true,
                    },
                  },
                },
              },
            },
          },
        },
      });

    const branchAssignments = branchId
      ? await this.prisma.branchMembershipRole.findMany({
          where: {
            membershipId,
            schoolId,
            branchId,
            role: {
              status: 'ACTIVE',
            },
          },
          select: {
            role: {
              select: {
                permissions: {
                  where: {
                    permission: {
                      scope: 'SCHOOL',
                    },
                  },
                  select: {
                    permission: {
                      select: {
                        code: true,
                      },
                    },
                  },
                },
              },
            },
          },
        })
      : [];

    const permissions = new Set<string>();

    for (const assignment of schoolAssignments) {
      for (const item of assignment.role.permissions) {
        permissions.add(item.permission.code);
      }
    }

    for (const assignment of branchAssignments) {
      for (const item of assignment.role.permissions) {
        permissions.add(item.permission.code);
      }
    }

    return [...permissions].sort();
  }

  async getPlatformPermissions(
    userId: string,
  ): Promise<string[]> {
    const assignments =
      await this.prisma.platformUserRole.findMany({
        where: {
          userId,
          role: {
            status: 'ACTIVE',
          },
        },
        select: {
          role: {
            select: {
              permissions: {
                where: {
                  permission: {
                    scope: 'PLATFORM',
                  },
                },
                select: {
                  permission: {
                    select: {
                      code: true,
                    },
                  },
                },
              },
            },
          },
        },
      });

    const permissions = new Set<string>();

    for (const assignment of assignments) {
      for (const item of assignment.role.permissions) {
        permissions.add(item.permission.code);
      }
    }

    return [...permissions].sort();
  }
}