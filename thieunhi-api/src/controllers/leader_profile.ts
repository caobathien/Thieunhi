import { Request, Response } from 'express';
import LeaderProfileService from '../services/leader_profile.service';
import { sendSuccess, sendError } from '../utils/response';

class LeaderProfileController {
    /**
     * POST /leaders
     * Admin tạo leader mới
     */
    async createLeader(req: Request, res: Response) {
        try {
            const { phone, gmail } = req.body;
            if (!phone && !gmail) {
                return sendError(res, 'Phải cung cấp ít nhất Số điện thoại hoặc Gmail', 400);
            }

            const result = await LeaderProfileService.createLeader({ phone, gmail });
            return sendSuccess(res, 'Tạo Huynh Trưởng thành công', result);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    /**
     * GET /leaders/:id
     * Lấy hồ sơ (id là user_id)
     */
    async getProfile(req: Request, res: Response) {
        try {
            const id = req.params.id as string;
            const profile = await LeaderProfileService.getProfileByUserId(id);
            return sendSuccess(res, 'Lấy hồ sơ thành công', profile);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }

    /**
     * GET /leaders/profile
     * Lấy hồ sơ của chính mình
     */
    async getMyProfile(req: Request, res: Response) {
        try {
            const userId = (req as any).user?.id;
            if (!userId) return sendError(res, 'Không tìm thấy ID người dùng', 401);

            const profile = await LeaderProfileService.getProfileByUserId(userId);
            return sendSuccess(res, 'Lấy hồ sơ thành công', profile);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }

    /**
     * PATCH /leaders/profile
     * Leader tự cập nhật hồ sơ
     */
    async updateMyProfile(req: Request, res: Response) {
        try {
            const userId = (req as any).user?.id;
            if (!userId) return sendError(res, 'Không tìm thấy ID người dùng', 401);

            const updatedProfile = await LeaderProfileService.updateMyProfile(userId, req.body);
            return sendSuccess(res, 'Cập nhật hồ sơ thành công', updatedProfile);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    /**
     * PATCH /leaders/admin/:userId
     * Admin cập nhật các thông tin hành chính
     */
    async adminUpdateProfile(req: Request, res: Response) {
        try {
            const userId = req.params.userId as string;
            const updatedProfile = await LeaderProfileService.adminUpdateProfile(userId, req.body);
            return sendSuccess(res, 'Admin cập nhật hồ sơ thành công', updatedProfile);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    /**
     * GET /leaders
     */
    async getAllLeaders(req: Request, res: Response) {
        try {
            const leaders = await LeaderProfileService.getAllLeaders();
            return sendSuccess(res, 'Lấy danh sách Huynh Trưởng thành công', leaders);
        } catch (error: any) {
            return sendError(res, error.message, 500);
        }
    }
}

export default new LeaderProfileController();