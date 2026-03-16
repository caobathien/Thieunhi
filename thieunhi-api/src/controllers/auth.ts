import { Request, Response } from 'express';
import AuthService from '../services/auth';
import { sendSuccess, sendError } from '../utils/response';

class AuthController {
    async register(req: Request, res: Response) {
        try {
            const { username, password, full_name, gmail, phone } = req.body;

            // Kiểm tra sơ bộ các trường bắt buộc
            if (!username || !password || !gmail || !full_name) {
                return sendError(res, 'Vui lòng điền đầy đủ thông tin bắt buộc', 400);
            }

            const newUser = await AuthService.register({
                username,
                password_hash: password, // truyền password thô vào, service sẽ hash
                full_name,
                gmail,
                phone,
                role: 'user' // Role này sẽ bị ghi đè lại trong Service để an toàn
            });

            return sendSuccess(res, 'Đăng ký tài khoản thành công. Quyền mặc định: Người Dùng', newUser, 201);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    async login(req: Request, res: Response) {
        try {
            const { username, password } = req.body;
            const data = await AuthService.login(username, password);
            return sendSuccess(res, 'Đăng nhập thành công', data);
        } catch (error: any) {
            return sendError(res, error.message, 401);
        }
    }

    async getMe(req: any, res: Response) {
        try {
            const user = await AuthService.getUserById(req.user.id);
            return sendSuccess(res, 'Lấy thông tin thành công', user);
        } catch (error: any) {
            return sendError(res, error.message, 404);
        }
    }

    async changePassword(req: any, res: Response) {
        try {
            const { oldPassword, newPassword } = req.body;
            if (!oldPassword || !newPassword) {
                return sendError(res, 'Vui lòng nhập đầy đủ mật khẩu cũ và mới', 400);
            }

            await AuthService.changePassword(req.user.id, oldPassword, newPassword);
            return sendSuccess(res, 'Đổi mật khẩu thành công');
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }
}

export default new AuthController();