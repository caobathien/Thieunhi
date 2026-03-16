import app from './app';
import dotenv from 'dotenv';

dotenv.config();

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(`
  🚀 Server đang chạy tại: http://localhost:${PORT}
  Mode: ${process.env.NODE_ENV || 'development'}
  -----------------------------------------------
  `);
});

// Xử lý khi server gặp lỗi nghiêm trọng mà không bị crash đột ngột
process.on('unhandledRejection', (err: Error) => {
  console.error('❌ LỖI NGHIÊM TRỌNG (Unhandled Rejection):', err.message);
  server.close(() => process.exit(1));
});