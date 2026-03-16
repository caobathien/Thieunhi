import { Request, Response } from 'express';
import UserService from '../services/user_profile'; // Trỏ về UserService mới
import { sendSuccess, sendError } from '../utils/response';

class UserController {
    /**
     * GET /api/v1/users/profile
     * Lấy thông tin cá nhân của chính mình
     */
    async getMyProfile(req: Request, res: Response) {
        try {
            const userId = (req as any).user?.id;
            if (!userId) return sendError(res, 'Không tìm thấy ID người dùng', 401);

            const profile = await UserService.getProfileByUserId(userId);
            return sendSuccess(res, 'Lấy thông tin cá nhân thành công', profile);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }

    /**
     * PATCH /api/v1/users/profile
     * Cập nhật thông tin cá nhân
     */
    async updateMyProfile(req: Request, res: Response) {
        try {
            const userId = (req as any).user?.id;
            if (!userId) return sendError(res, 'Không tìm thấy ID người dùng', 401);

            // Lưu ý: Cần loại bỏ các trường nhạy cảm như password, role ra khỏi req.body trước khi update
            // để tránh lỗi bảo mật (Mass Assignment)
            const { password, role, ...updateData } = req.body; 

            const updatedProfile = await UserService.updateMyProfile(userId, updateData);
            return sendSuccess(res, 'Cập nhật thông tin thành công', updatedProfile);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }
}

export default new UserController();