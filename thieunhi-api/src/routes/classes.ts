import { Router } from 'express';
import ClassController from '../controllers/classes';
import AuthMiddleware from '../middlewares/auth';
import { validate } from '../middlewares/validation';
import { createClassSchema, updateClassSchema } from '../validations/class.validation';

const router = Router();

/**
 * @swagger
 * /classes:
 *   get:
 *     summary: Lấy danh sách tất cả các lớp
 *     tags: [Classes]
 *     responses:
 *       200:
 *         description: Danh sách các lớp học
 */
router.get('/', AuthMiddleware.protect, ClassController.getAllClasses);

/**
 * @swagger
 * /classes:
 *   post:
 *     summary: Tạo lớp học mới
 *     tags: [Classes]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [class_name, academic_year]
 *             properties:
 *               class_name: {type: string}
 *               academic_year: {type: string}
 *               room_number: {type: string}
 *               total_capacity: {type: integer}
 *     responses:
 *       201:
 *         description: Tạo lớp thành công
 */
router.post('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip'), validate(createClassSchema), ClassController.createClass);

/**
 * @swagger
 * /classes/{id}:
 *   put:
 *     summary: Cập nhật thông tin lớp học
 *     tags: [Classes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: {type: integer}
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 */
router.put('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip'), validate(updateClassSchema), ClassController.updateClass);

/**
 * @swagger
 * /classes/{id}:
 *   delete:
 *     summary: Xóa lớp học
 *     tags: [Classes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: {type: integer}
 *     responses:
 *       200:
 *         description: Xóa thành công
 */
router.delete('/:id', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader-vip'), ClassController.deleteClass);

/**
 * @swagger
 * /classes/{id}/children:
 *   get:
 *     summary: Lấy danh sách thiếu nhi trong một lớp
 *     tags: [Classes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: {type: integer}
 *     responses:
 *       200:
 *         description: Danh sách thiếu nhi
 */
router.get('/:id/children', AuthMiddleware.protect, ClassController.getStudentsInClass);
export default router;