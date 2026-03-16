import { Router } from 'express';
import GradeController from '../controllers/grade';
import AuthMiddleware from '../middlewares/auth';
import multer from 'multer';

const upload = multer({ storage: multer.memoryStorage() });

const router = Router();

// Route nhập điểm (Admin, Leader, Teacher đều được nhập)
router.post('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader', 'teacher'), GradeController.inputGrade);
// Route xem điểm của 1 thiếu nhi cụ thể
router.get('/child/:childId', AuthMiddleware.protect, GradeController.getStudentGrades);
// Sửa điểm theo ID của bản ghi
router.put('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), GradeController.updateGrade);
//api/v1/grades/class/1?year=2025-2026
router.get('/class/:classId', AuthMiddleware.protect, GradeController.getClassGrades);

router.get('/export/:classId', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), GradeController.exportExcel);
router.post('/import/:classId', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader'), upload.single('file'), GradeController.importExcel);

export default router;