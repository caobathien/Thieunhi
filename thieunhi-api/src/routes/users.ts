import { Router } from 'express';
import AuthMiddleware from '../middlewares/auth';
import UserController from '../controllers/users';

const router = Router();

// Route xem profile cá nhân
router.get('/me', AuthMiddleware.protect, UserController.getProfile);

// Route cập nhật profile cá nhân
router.patch('/update-me', AuthMiddleware.protect, UserController.updateMyProfile);

// Route Admin lấy danh sách user
router.get('/all', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), UserController.getAllUsers);

// Route Admin khóa/mở khóa tài khoản
router.patch('/status/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), UserController.updateStatus);

// Route Admin phân quyền
router.patch('/update-role/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), UserController.updateRole);

// Route Admin xóa tài khoản
router.delete('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), UserController.deleteUser);

// Route Admin cập nhật thông tin bất kỳ
router.patch('/admin-update/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), UserController.adminUpdateUser);

// Route Admin thiết lập lại mật khẩu
router.post('/admin-reset-password/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), UserController.adminResetPassword);

// Đổi mật khẩu
router.post('/change-password', AuthMiddleware.protect, UserController.changePassword);

export default router;