import { Router } from 'express';
import AuthController from '../controllers/auth';
import { protect } from '../middlewares/auth'; 

const router = Router();

// Đăng ký và Đăng nhập (Công khai)
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);

// Lấy thông tin cá nhân (Yêu cầu token - dùng để tự động đăng nhập)
router.get('/me', protect, AuthController.getMe);

// Đổi mật khẩu
router.patch('/change-password', protect, AuthController.changePassword);

export default router;