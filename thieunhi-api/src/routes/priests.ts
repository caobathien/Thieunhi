import { Router } from 'express';
import PriestController from '../controllers/priests';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// Lấy danh sách (Ai cũng xem được miễn là có đăng nhập)
router.get('/', AuthMiddleware.protect, PriestController.getAllPriests);

// Các endpoint dưới đây chỉ Admin mới được truy cập
router.post('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), PriestController.createPriest);
router.patch('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), PriestController.updatePriest);
router.delete('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), PriestController.deletePriest);

export default router;
