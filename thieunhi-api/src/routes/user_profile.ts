import { Router } from 'express';
import UserController from '../controllers/user_profile';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// Tất cả các route này yêu cầu đăng nhập
router.use(AuthMiddleware.protect);

/**
 * @swagger
 * /users/profile:
 * get:
 * summary: Lấy thông tin cá nhân của người dùng hiện tại
 * tags: [Users]
 */
router.get('/profile', UserController.getMyProfile);

/**
 * @swagger
 * /users/profile:
 * patch:
 * summary: Cập nhật thông tin cá nhân của người dùng hiện tại
 * tags: [Users]
 */
router.patch('/profile', UserController.updateMyProfile);

export default router;