import { Router } from 'express';
import AttendanceController from '../controllers/attendance';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// Endpoint: POST /api/v1/attendance/scan
router.post('/scan', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), AttendanceController.scanQR);
router.post('/manual', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), AttendanceController.manualMark);
router.get('/class/:class_id', AuthMiddleware.protect, AttendanceController.getClassReport);
router.get('/report/:class_id', AuthMiddleware.protect, AttendanceController.getReport);
router.get('/manual-list/:class_id', AuthMiddleware.protect, AttendanceController.getManualList);
router.get('/stats/:class_id', AuthMiddleware.protect, AttendanceController.getStats);

export default router;