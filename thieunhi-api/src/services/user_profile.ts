import UserModel from '../models/user_profile'; // Trỏ về UserModel mới bạn vừa sửa
import { IUser } from '../interfaces/user';

class UserService {
    async getProfileByUserId(userId: string) {
        // Lấy thẳng thông tin từ bảng users
        const user = await UserModel.findByUserId(userId);
        if (!user) throw new Error('Không tìm thấy dữ liệu người dùng');
        return user;
    }

    async updateMyProfile(userId: string, data: Partial<IUser>) {
        // Bỏ qua logic kiểm tra tồn tại và create.
        // Cập nhật thẳng vào bảng users luôn.
        const updatedUser = await UserModel.update(userId, data);
        if (!updatedUser) throw new Error('Cập nhật thông tin thất bại');
        return updatedUser;
    }

    // Gợi ý thêm hàm đổi mật khẩu cho phần bạn vừa hỏi ở trên
    async updatePassword(userId: string, hashedPassword: string) {
        const updatedUser = await UserModel.updatePassword(userId, hashedPassword);
        if (!updatedUser) throw new Error('Cập nhật mật khẩu thất bại');
        return updatedUser;
    }
}

export default new UserService();