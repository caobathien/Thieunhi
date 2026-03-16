import { Router } from 'express';
import ChildController from '../controllers/children';
import AuthMiddleware from '../middlewares/auth';
import { validate } from '../middlewares/validation';
import { createChildSchema, updateChildSchema } from '../validations/child.validation';
import multer from 'multer';

const upload = multer({ storage: multer.memoryStorage() });

const router = Router();

// Tất cả các thao tác với thiếu nhi đều cần đăng nhập
router.use(AuthMiddleware.protect);

/**
 * @swagger
 * /children:
 *   get:
 *     summary: Lấy danh sách tất cả thiếu nhi
 *     tags: [Children]
 *     responses:
 *       200:
 *         description: Danh sách thiếu nhi
 */
router.get('/', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), ChildController.getAll);

/**
 * @swagger
 * /children:
 *   post:
 *     summary: Thêm thiếu nhi mới
 *     tags: [Children]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [class_id, first_name, last_name, gender]
 *     responses:
 *       201:
 *         description: Tạo thành công
 */
router.post('/', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), validate(createChildSchema), ChildController.create);

/**
 * @swagger
 * /children/{id}:
 *   delete:
 *     summary: Xóa hồ sơ thiếu nhi
 *     tags: [Children]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: {type: string}
 *     responses:
 *       200:
 *         description: Xóa thành công
 */
router.delete('/:id', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), ChildController.delete);

/**
 * @swagger
 * /children/{id}:
 *   put:
 *     summary: Cập nhật thông tin thiếu nhi
 *     tags: [Children]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: {type: string}
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 */
router.put('/:id', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), validate(updateChildSchema), ChildController.update);

/**
 * @swagger
 * /children/class/{classId}:
 *   get:
 *     summary: Lấy danh sách thiếu nhi theo lớp
 *     tags: [Children]
 *     parameters:
 *       - in: path
 *         name: classId
 *         required: true
 *         schema: {type: integer}
 *     responses:
 *       200:
 *         description: Danh sách thiếu nhi trong lớp
 */
router.get('/class/:classId', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader', 'teacher'), ChildController.getByClass);

router.get('/export/excel', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), ChildController.exportExcel);
router.get('/export/class/:classId', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), ChildController.exportByClass);
router.post('/import/:classId', AuthMiddleware.restrictTo('admin', 'leader-vip', 'leader'), upload.single('file'), ChildController.importExcel);

export default router;