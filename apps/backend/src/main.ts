import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';

import { AppModule } from './app.module.js';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global API prefix
  app.setGlobalPrefix('api/v1');

  // HTTP security headers
  app.use(helmet());

  // Request validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Graceful shutdown
  app.enableShutdownHooks();

  const port = process.env.PORT ?? 3000;

  await app.listen(port);

  console.log(`School ERP API running on port ${port}`);
}

bootstrap();