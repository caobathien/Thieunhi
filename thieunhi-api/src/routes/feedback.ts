import { Router } from 'express';
import FeedbackController from '../controllers/feedback';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// Ai đã đăng nhập cũng có thể gửi phản hồi
router.post('/', AuthMiddleware.protect, FeedbackController.submitFeedback);

// Xem phản hồi của chính mình
router.get('/my', AuthMiddleware.protect, FeedbackController.getMyFeedbacks);

// Admin/Leader xem tất cả phản hồi
router.get('/all', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader', 'teacher'), FeedbackController.getAllFeedbacks);

// Admin xử lý phản hồi
router.put('/respond/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), FeedbackController.respondFeedback);

export default router;