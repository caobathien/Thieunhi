import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';

// Import cấu hình DB để khởi tạo kết nối ngay khi app chạy
import './config/database';
import routes from './routes';
import swaggerUi from 'swagger-ui-express';
import { specs } from './config/swagger';

dotenv.config();

const app: Application = express();

// --- Middlewares ---
app.use(helmet()); // Bảo mật các HTTP headers
app.use(cors()); // Cho phép App Mobile truy cập (Cross-Origin)
app.use(morgan('dev')); // Log các request ra terminal để dễ debug
app.use(express.json()); // Cho phép nhận dữ liệu JSON từ body request
app.use(express.urlencoded({ extended: true }));

// Cho phép truy cập tĩnh tới thư mục uploads
import path from 'path';
import fs from 'fs';

const uploadsDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadsDir)) {
  console.log('--- Đang tạo thư mục uploads tại:', uploadsDir);
  fs.mkdirSync(uploadsDir, { recursive: true });
}
app.use('/uploads', express.static(uploadsDir));

// --- Route kiểm tra cơ bản ---
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    message: "Chào mừng bạn đến với API Quản lý Thiếu nhi - Church Management System",
    version: "1.0.0"
  });
});

app.use('/api/v1/docs', swaggerUi.serve, swaggerUi.setup(specs));
app.use('/api/v1', routes);

export default app;