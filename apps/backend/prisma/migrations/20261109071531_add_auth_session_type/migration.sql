-- CreateEnum
CREATE TYPE "AuthSessionType" AS ENUM ('SCHOOL', 'PLATFORM');

-- AlterTable
ALTER TABLE "AuthSession" ADD COLUMN     "sessionType" "AuthSessionType" NOT NULL DEFAULT 'SCHOOL';

-- CreateIndex
CREATE INDEX "AuthSession_sessionType_expiresAt_idx" ON "AuthSession"("sessionType", "expiresAt");
