import { Router } from 'express';
import authRoutes from './auth';
import userRoutes from './users';
import childrenRoutes from './children';
import attendanceRoutes from './attendance';
import classRoutes from './classes';
import leaderProfileRoutes from './leader_profile';
import classAssignmentRoutes from './class_assignment';
import gradeRoutes from './grade';
import termSummaryRoutes from './term_summary';
import classStatisticRoutes from './class_statistic';
import activityRoutes from './activity';
import feedbackRoutes from './feedback';
import uploadRoutes from './upload';
import userProfileRoutes from './user_profile';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/children', childrenRoutes);
router.use('/attendance', attendanceRoutes);
router.use('/classes', classRoutes);
router.use('/leaders-profile', leaderProfileRoutes);
router.use('/user-profiles', userProfileRoutes);
router.use('/class-assignments', classAssignmentRoutes);
router.use('/grades', gradeRoutes);
router.use('/term-summaries', termSummaryRoutes);
router.use('/class-statistics', classStatisticRoutes);
router.use('/activities', activityRoutes);
router.use('/feedbacks', feedbackRoutes);
router.use('/upload', uploadRoutes);

export default router;