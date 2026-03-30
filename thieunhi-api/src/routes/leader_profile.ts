import { Router } from 'express';
import LeaderProfileController from '../controllers/leader_profile';
import AuthMiddleware from '../middlewares/auth';

const router = Router();

// CREATE leader (Admin only)
router.post('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), LeaderProfileController.createLeader);

// ✅ GET all leaders — tĩnh, phải đặt trước /:id
router.get('/', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin', 'leader', 'user'), LeaderProfileController.getAllLeaders);

// ✅ GET own profile — tĩnh, phải đặt trước /:id
router.get('/profile', AuthMiddleware.protect, AuthMiddleware.restrictTo('leader', 'admin', 'user', 'teacher'), LeaderProfileController.getMyProfile);

// ✅ UPDATE own profile — tĩnh, phải đặt trước /:id
router.patch('/profile', AuthMiddleware.protect, AuthMiddleware.restrictTo('leader', 'user', 'teacher', 'admin'), LeaderProfileController.updateMyProfile);

// ✅ Admin update — tĩnh prefix /admin, đặt trước /:id
router.patch('/admin/:userId', AuthMiddleware.protect, AuthMiddleware.restrictTo('admin'), LeaderProfileController.adminUpdateProfile);

// ✅ GET by ID — động, đặt CUỐI CÙNG
router.get('/:id', AuthMiddleware.protect, LeaderProfileController.getProfile);


export default router;