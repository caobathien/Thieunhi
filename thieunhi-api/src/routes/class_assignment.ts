import { Router } from 'express';
import ClassAssignmentController from '../controllers/class_assignment';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// Chỉ Admin/Leader mới có quyền phân công
router.post('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip'), ClassAssignmentController.assignLeader);

// Lấy tất cả phân công (Chỉ Admin/Leader mới xem được tổng quát)
router.get('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip'), ClassAssignmentController.getAllAssignments);

// Xem danh sách Huynh trưởng của lớp (Tất cả giáo lý viên đều xem được)
router.get('/class/:classId', AuthMiddleware.protect, ClassAssignmentController.getLeadersByClass);

// Gỡ phân công
router.delete('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip'), ClassAssignmentController.removeAssignment);
router.get('/export/excel/:classId', AuthMiddleware.protect,AuthMiddleware.restrictTo('admin', 'leader-vip'), ClassAssignmentController.exportExcel);

export default router;