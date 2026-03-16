import { Request, Response } from 'express';
import UsersService from '../services/users';
import { sendSuccess, sendError } from '../utils/response';
import { changePasswordSchema, updateProfileSchema } from '../validations/user.validation';

class UserController {
    // 1. Lấy thông tin cá nhân (Cho route /me)
    async getProfile(req: Request, res: Response) {
        try {
            const userId = (req as any).user.id; 
            const user = await UsersService.getUserById(userId);
            return sendSuccess(res, 'Lấy thông tin cá nhân thành công', user);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }

    // 2. Lấy danh sách tất cả người dùng (Chỉ Admin)
    async getAllUsers(req: Request, res: Response) {
        try {
            const users = await UsersService.getAllUsers();
            return sendSuccess(res, 'Danh sách người dùng hệ thống', users);
        } catch (error: any) {
            return sendError(res, error.message, 500);
        }
    }

    // 3. Cập nhật profile cá nhân
    async updateMyProfile(req: Request, res: Response) {
        try {
            const { error, value } = updateProfileSchema.validate(req.body);
            if (error) return sendError(res, error.details[0].message, 400);

            const userId = (req as any).user.id;
            const updatedUser = await UsersService.updateProfile(userId, value);
            return sendSuccess(res, 'Cập nhật thông tin thành công', updatedUser);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // 4. Admin khóa/mở khóa tài khoản
    async updateStatus(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { is_active, reason } = req.body;
            const status = is_active ? 'active' : 'locked';
            const result = await UsersService.toggleUserStatus(id as string, status, reason);
            return sendSuccess(res, result.message, result);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // 5. Admin phân quyền
    async updateRole(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { role } = req.body;
            const result = await UsersService.updateUserRole(id as string, role);
            return sendSuccess(res, 'Cập nhật quyền thành công', result);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // 6. Admin xóa tài khoản
    async deleteUser(req: Request, res: Response) {
        try {
            const { id } = req.params;
            await UsersService.deleteUser(id as string);
            return sendSuccess(res, 'Xóa tài khoản thành công');
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // 7. Đổi mật khẩu
    async changePassword(req: Request, res: Response) {
        try {
            const { error, value } = changePasswordSchema.validate(req.body);
            if (error) return sendError(res, error.details[0].message, 400);

            const userId = (req as any).user.id;
            const { oldPassword, newPassword } = value;
            
            const result = await UsersService.changePassword(userId, oldPassword, newPassword);
            return sendSuccess(res, result.message);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // 8. Admin cập nhật thông tin user (Admin role only)
    async adminUpdateUser(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const updatedUser = await UsersService.adminUpdateUser(id as string, req.body);
            return sendSuccess(res, 'Cập nhật người dùng thành công', updatedUser);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    // 9. Admin thiết lập lại mật khẩu
    async adminResetPassword(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { newPassword } = req.body;
            if (!newPassword) return sendError(res, 'Cần có mật khẩu mới', 400);

            const result = await UsersService.adminResetPassword(id as string, newPassword);
            return sendSuccess(res, result.message);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }
}

export default new UserController();