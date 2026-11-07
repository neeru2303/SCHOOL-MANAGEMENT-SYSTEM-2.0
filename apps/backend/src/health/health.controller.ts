import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  checkHealth() {
    return {
      success: true,
      message: 'School ERP API is running',
      service: 'school-erp-backend',
      timestamp: new Date().toISOString(),
    };
  }
}