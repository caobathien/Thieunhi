import bcrypt from 'bcryptjs';
import UserModel from '../models/user';
import LeaderProfileModel from '../models/leader_profile';
import { IUser } from '../interfaces/user';

class UsersService {
    // 1. Lấy tất cả người dùng
    async getAllUsers() {
        const users = await UserModel.findAll();
        return users.map(({ password_hash, ...user }) => user);
    }

    // 2. Lấy chi tiết thông tin theo ID
    async getUserById(id: string) {
        const user = await UserModel.findById(id); 
        if (!user) throw new Error('Không tìm thấy người dùng');
        const { password_hash, ...userProfile } = user;

        // Bổ sung thông tin lớp được phân công (nếu có)
        try {
            const assignment = await require('../models/class_assignment').default.findByUserId(id);
            if (assignment) {
                (userProfile as any).assigned_class_id = assignment.class_id;
                (userProfile as any).assigned_class_name = assignment.class_name;
            }
        } catch (err) {
            // Không có phân công hoặc class_assignment model chưa load
        }

        return userProfile;
    }

    // 3. Cập nhật thông tin cá nhân (Thực hiện lưu xuống DB)
    async updateProfile(id: string, updateData: Partial<IUser>) {
        const { password_hash, role, ...safeData } = updateData;
        
        // Nếu cập nhật username, cần check xem có bị trùng không
        if (safeData.username) {
            const existingUser = await UserModel.findByUsername(safeData.username);
            if (existingUser && existingUser.id !== id) {
                throw new Error('Tên đăng nhập đã được sử dụng bởi người khác');
            }
        }

        const updatedUser = await UserModel.update(id, safeData);
        if (!updatedUser) throw new Error('Cập nhật thất bại, người dùng không tồn tại');
        
        return updatedUser;
    }

    // 4. Khóa hoặc mở khóa tài khoản (Thực hiện lưu xuống DB)
    async toggleUserStatus(id: string, status: 'active' | 'locked' | 'pending', reason?: string) {
        if (status === 'locked' && !reason) {
            throw new Error('Phải có lý do khi khóa tài khoản');
        }

        await UserModel.updateStatus(id, { 
            status, 
            lock_reason: reason, 
            locked_at: status === 'locked' ? new Date() : undefined 
        });
        
        return { message: `Đã ${status === 'locked' ? 'khóa' : 'mở khóa'} tài khoản thành công`, userId: id };
    }

    // 5. Thay đổi mật khẩu
    async changePassword(id: string, oldPass: string, newPass: string) {
        const user = await UserModel.findById(id);
        if (!user) throw new Error('Người dùng không tồn tại');

        // Kiểm tra mật khẩu cũ
        const isMatch = await bcrypt.compare(oldPass, user.password_hash);
        if (!isMatch) throw new Error('Mật khẩu cũ không chính xác');

        // Mã hóa mật khẩu mới
        const salt = await bcrypt.genSalt(10);
        const hashedNewPass = await bcrypt.hash(newPass, salt);

        await UserModel.update(id, { password_hash: hashedNewPass });
        return { message: 'Thay đổi mật khẩu thành công' };
    }

    // 6. Cập nhật log đăng nhập (Gọi hàm này trong AuthService khi login thành công)
    async updateLoginLog(id: string) {
        await UserModel.update(id, { 
            last_login: new Date(),
            login_attempts: 0 // Reset số lần thử sai khi đăng nhập thành công
        });
    }

    // 7. Xóa tài khoản người dùng
    async deleteUser(id: string) {
        const user = await UserModel.findById(id);
        if (!user) throw new Error('Không tìm thấy người dùng để xóa');

        // Xóa hồ sơ Huynh trưởng trước (Cascading)
        await LeaderProfileModel.deleteByUserId(id);

        const isDeleted = await UserModel.delete(id);
        if (!isDeleted) throw new Error('Xóa tài khoản thất bại');

        return { message: 'Xóa tài khoản thành công' };
    }

    // 8. Admin cập nhật quyền cho người dùng
    async updateUserRole(id: string, role: string) {
        const validRoles = ['admin', 'leader-vip', 'leader', 'teacher', 'user'];
        if (!validRoles.includes(role)) {
            throw new Error('Quyền không hợp lệ. Chỉ chấp nhận: admin, leader-vip, leader, teacher, user');
        }

        const updatedUser = await UserModel.update(id, { role } as Partial<IUser>);
        if (!updatedUser) throw new Error('Không tìm thấy người dùng để cập nhật quyền');

        return updatedUser;
    }

    // 9. Admin cập nhật thông tin bất kỳ (Bao gồm username, role)
    async adminUpdateUser(id: string, updateData: Partial<IUser>) {
        const updatedUser = await UserModel.update(id, updateData);
        if (!updatedUser) throw new Error('Không tìm thấy người dùng để cập nhật');
        return updatedUser;
    }

    // 10. Admin thiết lập lại mật khẩu
    async adminResetPassword(id: string, newPass: string) {
        const user = await UserModel.findById(id);
        if (!user) throw new Error('Người dùng không tồn tại');

        const salt = await bcrypt.genSalt(10);
        const hashedNewPass = await bcrypt.hash(newPass, salt);

        await UserModel.update(id, { password_hash: hashedNewPass });
        return { message: 'Thiết lập lại mật khẩu thành công' };
    }
}

export default new UsersService();