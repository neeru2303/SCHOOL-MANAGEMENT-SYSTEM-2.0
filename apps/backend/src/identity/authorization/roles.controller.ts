import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Put,
  Req,
  UseGuards,
} from '@nestjs/common';

import { AuthGuard } from '@nestjs/passport';
import {
  ArrayNotEmpty,
  ArrayUnique,
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  Matches,
  MaxLength,
} from 'class-validator';

import { RolesService } from './roles.service.js';
import { PermissionsGuard } from './permissions.guard.js';
import { RequirePermissions } from '../authentication/permissions.decorator.js';

class CreateRoleDto {
  @IsString()
  @Matches(/^[A-Za-z0-9_-]+$/)
  @MaxLength(80)
  code!: string;

  @IsString()
  @Length(2, 100)
  name!: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
}

class UpdateRoleDto {
  @IsOptional()
  @IsString()
  @Length(2, 100)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsIn(['ACTIVE', 'INACTIVE'])
  status?: 'ACTIVE' | 'INACTIVE';
}

class SetRolePermissionsDto {
  @IsArray()
  @ArrayUnique()
  @ArrayNotEmpty()
  @IsString({ each: true })
  permissionCodes!: string[];
}

class AssignSchoolRoleDto {
  @IsUUID()
  membershipId!: string;
}

class AssignBranchRoleDto {
  @IsUUID()
  membershipId!: string;

  @IsUUID()
  branchId!: string;
}

interface AuthenticatedRequest {
  user: {
    userId: string;
    schoolId: string;
    membershipId: string;
    sessionId: string;
    permissions: string[];
  };
}

@Controller('school/roles')
@UseGuards(AuthGuard('jwt'), PermissionsGuard)
export class RolesController {
  constructor(
    private readonly rolesService: RolesService,
  ) {}

  // CREATE ROLE
  @Post()
  @RequirePermissions('school.roles.manage')
  createRole(
    @Req() req: AuthenticatedRequest,
    @Body() dto: CreateRoleDto,
  ) {
    return this.rolesService.createSchoolRole(
      req.user.schoolId,
      dto,
    );
  }

  // GET ROLES
  @Get()
  @RequirePermissions('school.roles.view')
  getRoles(
    @Req() req: AuthenticatedRequest,
  ) {
    return this.rolesService.getSchoolRoles(
      req.user.schoolId,
    );
  }

  // UPDATE ROLE
  @Patch(':roleId')
  @RequirePermissions('school.roles.manage')
  updateRole(
    @Req() req: AuthenticatedRequest,
    @Param('roleId') roleId: string,
    @Body() dto: UpdateRoleDto,
  ) {
    return this.rolesService.updateSchoolRole(
      req.user.schoolId,
      roleId,
      dto,
    );
  }

  // SET ROLE PERMISSIONS
  @Put(':roleId/permissions')
  @RequirePermissions('school.permissions.manage')
  setRolePermissions(
    @Req() req: AuthenticatedRequest,
    @Param('roleId') roleId: string,
    @Body() dto: SetRolePermissionsDto,
  ) {
    return this.rolesService.setRolePermissions(
      req.user.schoolId,
      roleId,
      dto.permissionCodes,
    );
  }

  // ASSIGN SCHOOL ROLE
  @Post(':roleId/assign')
  @RequirePermissions('school.roles.assign')
  assignSchoolRole(
    @Req() req: AuthenticatedRequest,
    @Param('roleId') roleId: string,
    @Body() dto: AssignSchoolRoleDto,
  ) {
    return this.rolesService.assignSchoolRole(
      req.user.schoolId,
      dto.membershipId,
      roleId,
    );
  }

  // ASSIGN BRANCH ROLE
  @Post(':roleId/assign-branch')
  @RequirePermissions('school.roles.assign')
  assignBranchRole(
    @Req() req: AuthenticatedRequest,
    @Param('roleId') roleId: string,
    @Body() dto: AssignBranchRoleDto,
  ) {
    return this.rolesService.assignBranchRole(
      req.user.schoolId,
      dto.membershipId,
      dto.branchId,
      roleId,
    );
  }
}