import { Router } from 'express';
import ActivityController from '../controllers/activity';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// Ai cũng có thể xem thông báo (Công khai)
router.get('/', ActivityController.getActivities);

// Chỉ Admin hoặc Leader mới được đăng, sửa và xóa tin
router.post('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), ActivityController.createActivity);
router.put('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), ActivityController.updateActivity);
router.delete('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), ActivityController.deleteActivity);

export default router;