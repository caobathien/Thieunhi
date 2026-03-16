import { Router } from 'express';
import TermSummaryController from '../controllers/term_summary';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// Chạy tổng kết (Admin/Leader/Teacher)
router.post('/process', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader', 'teacher'), TermSummaryController.processSummary);
// Xem kết quả 1 thiếu nhi
router.get('/child/:childId', AuthMiddleware.protect, TermSummaryController.getStudentSummary);
// xem kết quả cả lớp
router.get('/class/:classId', AuthMiddleware.protect, TermSummaryController.getClassSummary);

export default router;