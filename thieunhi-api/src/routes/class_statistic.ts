import { Router } from 'express';
import ClassStatisticController from '../controllers/class_statistic';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

router.post('/sync', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), ClassStatisticController.runClassStats);
router.get('/:classId', AuthMiddleware.protect, ClassStatisticController.getClassStats);
router.get('/export/:classId', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), ClassStatisticController.exportExcel
);

export default router;