-- CreateEnum
CREATE TYPE "PermissionScope" AS ENUM ('PLATFORM', 'SCHOOL');

-- CreateEnum
CREATE TYPE "RoleStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateTable
CREATE TABLE "Permission" (
    "id" UUID NOT NULL,
    "code" VARCHAR(120) NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "scope" "PermissionScope" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Permission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SchoolRole" (
    "id" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "code" VARCHAR(80) NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "status" "RoleStatus" NOT NULL DEFAULT 'ACTIVE',
    "isSystem" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SchoolRole_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RolePermission" (
    "roleId" UUID NOT NULL,
    "permissionId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RolePermission_pkey" PRIMARY KEY ("roleId","permissionId")
);

-- CreateTable
CREATE TABLE "MembershipRole" (
    "membershipId" UUID NOT NULL,
    "roleId" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MembershipRole_pkey" PRIMARY KEY ("membershipId","roleId")
);

-- CreateTable
CREATE TABLE "BranchMembershipRole" (
    "membershipId" UUID NOT NULL,
    "branchId" UUID NOT NULL,
    "roleId" UUID NOT NULL,
    "schoolId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "schoolMembershipId" UUID,

    CONSTRAINT "BranchMembershipRole_pkey" PRIMARY KEY ("membershipId","branchId","roleId")
);

-- CreateTable
CREATE TABLE "PlatformRole" (
    "id" UUID NOT NULL,
    "code" VARCHAR(80) NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "status" "RoleStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlatformRole_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlatformRolePermission" (
    "roleId" UUID NOT NULL,
    "permissionId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PlatformRolePermission_pkey" PRIMARY KEY ("roleId","permissionId")
);

-- CreateTable
CREATE TABLE "PlatformUserRole" (
    "userId" UUID NOT NULL,
    "roleId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PlatformUserRole_pkey" PRIMARY KEY ("userId","roleId")
);

-- CreateIndex
CREATE UNIQUE INDEX "Permission_code_key" ON "Permission"("code");

-- CreateIndex
CREATE INDEX "Permission_scope_idx" ON "Permission"("scope");

-- CreateIndex
CREATE INDEX "SchoolRole_schoolId_status_idx" ON "SchoolRole"("schoolId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "SchoolRole_id_schoolId_key" ON "SchoolRole"("id", "schoolId");

-- CreateIndex
CREATE UNIQUE INDEX "SchoolRole_schoolId_code_key" ON "SchoolRole"("schoolId", "code");

-- CreateIndex
CREATE INDEX "RolePermission_permissionId_idx" ON "RolePermission"("permissionId");

-- CreateIndex
CREATE INDEX "MembershipRole_schoolId_roleId_idx" ON "MembershipRole"("schoolId", "roleId");

-- CreateIndex
CREATE INDEX "BranchMembershipRole_schoolId_roleId_branchId_idx" ON "BranchMembershipRole"("schoolId", "roleId", "branchId");

-- CreateIndex
CREATE UNIQUE INDEX "PlatformRole_code_key" ON "PlatformRole"("code");

-- CreateIndex
CREATE INDEX "PlatformRolePermission_permissionId_idx" ON "PlatformRolePermission"("permissionId");

-- CreateIndex
CREATE INDEX "PlatformUserRole_roleId_idx" ON "PlatformUserRole"("roleId");

-- AddForeignKey
ALTER TABLE "SchoolRole" ADD CONSTRAINT "SchoolRole_schoolId_fkey" FOREIGN KEY ("schoolId") REFERENCES "School"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RolePermission" ADD CONSTRAINT "RolePermission_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "SchoolRole"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RolePermission" ADD CONSTRAINT "RolePermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipRole" ADD CONSTRAINT "MembershipRole_membershipId_schoolId_fkey" FOREIGN KEY ("membershipId", "schoolId") REFERENCES "SchoolMembership"("id", "schoolId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipRole" ADD CONSTRAINT "MembershipRole_roleId_schoolId_fkey" FOREIGN KEY ("roleId", "schoolId") REFERENCES "SchoolRole"("id", "schoolId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BranchMembershipRole" ADD CONSTRAINT "BranchMembershipRole_membershipId_branchId_fkey" FOREIGN KEY ("membershipId", "branchId") REFERENCES "BranchMembership"("membershipId", "branchId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BranchMembershipRole" ADD CONSTRAINT "BranchMembershipRole_roleId_schoolId_fkey" FOREIGN KEY ("roleId", "schoolId") REFERENCES "SchoolRole"("id", "schoolId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BranchMembershipRole" ADD CONSTRAINT "BranchMembershipRole_schoolMembershipId_fkey" FOREIGN KEY ("schoolMembershipId") REFERENCES "SchoolMembership"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlatformRolePermission" ADD CONSTRAINT "PlatformRolePermission_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "PlatformRole"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlatformRolePermission" ADD CONSTRAINT "PlatformRolePermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlatformUserRole" ADD CONSTRAINT "PlatformUserRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlatformUserRole" ADD CONSTRAINT "PlatformUserRole_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "PlatformRole"("id") ON DELETE CASCADE ON UPDATE CASCADE;
