import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT || '5432'),
  max: 20,
  idleTimeoutMillis: 50000,
  connectionTimeoutMillis: 50000,
});

// Kiểm tra kết nối ngay lập tức bằng một truy vấn đơn giản
const checkConnection = async () => {
  try {
    const client = await pool.connect();
    console.log('✅ Đã kết nối thành công tới Database PostgreSQL');
    client.release(); // Trả lại kết nối cho pool
  } catch (err) {
    console.error('❌ Lỗi kết nối Database:', (err as Error).message);
    console.log('DEBUG DB_USER:', process.env.DB_USER);
  }
};

checkConnection();

export default {
  query: (text: string, params?: any[]) => pool.query(text, params),
  getClient: () => pool.connect(),
};