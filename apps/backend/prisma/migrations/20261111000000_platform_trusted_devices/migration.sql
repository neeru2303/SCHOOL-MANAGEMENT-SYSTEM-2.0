CREATE TABLE "PlatformTrustedDevice" (
    "id" UUID NOT NULL,
    "deviceKey" VARCHAR(128) NOT NULL,
    "userId" UUID NOT NULL,
    "sessionId" UUID NOT NULL,
    "pinHash" TEXT NOT NULL,
    "failedAttempts" INTEGER NOT NULL DEFAULT 0,
    "lockedUntil" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "PlatformTrustedDevice_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "PlatformTrustedDevice_deviceKey_key"
ON "PlatformTrustedDevice"("deviceKey");

CREATE INDEX "PlatformTrustedDevice_userId_revokedAt_idx"
ON "PlatformTrustedDevice"("userId", "revokedAt");

CREATE INDEX "PlatformTrustedDevice_sessionId_revokedAt_idx"
ON "PlatformTrustedDevice"("sessionId", "revokedAt");

ALTER TABLE "PlatformTrustedDevice"
ADD CONSTRAINT "PlatformTrustedDevice_userId_fkey"
FOREIGN KEY ("userId") REFERENCES "User"("id")
ON DELETE CASCADE ON UPDATE CASCADE;
