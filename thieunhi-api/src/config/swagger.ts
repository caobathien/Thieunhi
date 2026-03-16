import swaggerJsdoc from 'swagger-jsdoc';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API Quản lý Thiếu nhi - Church Management System',
      version: '1.0.0',
      description: 'Tài liệu API cho hệ thống quản lý thiếu nhi và huynh trưởng.',
    },
    servers: [
      {
        url: 'http://localhost:3000/api/v1',
        description: 'Server Phát triển',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./thieunhi-api/src/routes/*.ts', './src/routes/*.ts'], // Hỗ trợ cả khi chạy từ gốc dự án hoặc từ thieunhi-api
};

export const specs = swaggerJsdoc(options);
