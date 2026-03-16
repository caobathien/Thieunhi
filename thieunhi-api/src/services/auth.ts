import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import UserModel from '../models/user';
import { IUser } from '../interfaces/user';
import { ROLES } from '../config/constants';

class AuthService {
    async register(userData: IUser) {
        const existingUser = await UserModel.findByUsername(userData.username);
        if (existingUser) {
            throw new Error('Tên đăng nhập đã tồn tại!');
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(userData.password_hash, salt);

        const newUser = await UserModel.create({
            ...userData,
            password_hash: hashedPassword,
            role: ROLES.USER as any,
            status: 'active'
        });

        return newUser;
    }

    // Logic Đăng nhập
    async login(identifier: string, password_unhashed: string) {
        const user = await UserModel.findByIdentifier(identifier);
        
        if (!user) throw new Error('Tài khoản hoặc mật khẩu không chính xác');

        const isMatch = await bcrypt.compare(password_unhashed, user.password_hash);
        if (!isMatch) throw new Error('Tài khoản hoặc mật khẩu không chính xác');

        if (user.status === 'locked' || user.is_active === false) {
            throw new Error('Tài khoản của bạn đã bị khóa hoặc chưa kích hoạt');
        }

        // TẠO TOKEN: Thời hạn 7 ngày để người dùng không phải đăng nhập lại liên tục
        const token = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET || 'secret',
            { expiresIn: '7d' } 
        );

        const { password_hash, ...userWithoutPassword } = user;
        return { user: userWithoutPassword, token };
    }

    /**
     * HÀM MỚI: Lấy thông tin người dùng để phục vụ tính năng "Lưu đăng nhập"
     * Khi App gửi token cũ lên route /me, hàm này sẽ xác nhận user vẫn tồn tại
     */
    async getUserById(id: string) {
        const user = await UserModel.findById(id); // Giả định UserModel của bạn có findById
        
        if (!user) {
            throw new Error('Người dùng không tồn tại hoặc phiên làm việc đã hết hạn');
        }

        if (user.status === 'locked' || user.is_active === false) {
            throw new Error('Tài khoản đã bị khóa');
        }

        const { password_hash, ...userWithoutPassword } = user;
        return userWithoutPassword;
    }
    /**
     * Tự động tạo tài khoản cho Huynh Trưởng (Admin flow)
     */
    async autoCreateLeaderAccount(data: { phone?: string, gmail?: string }) {
        const { phone, gmail } = data;
        
        // 1. Kiểm tra user đã tồn tại chưa
        const existingUser = await UserModel.findByPhoneOrEmail(phone, gmail);
        if (existingUser) {
            return existingUser;
        }

        // 2. Tạo password mặc định
        const tempPassword = "123456";
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(tempPassword, salt);

        // 3. Tạo username từ phone hoặc email
        const username = phone || gmail || `leader_${Date.now()}`;

        // 4. Tạo user mới
        const newUser = await UserModel.create({
            username: username,
            password_hash: hashedPassword,
            phone: phone,
            gmail: gmail,
            role: 'leader',
            status: 'active'
        });

        // Bổ sung mật khẩu tạm vào response để Admin có thể gửi cho Leader
        return { ...newUser, tempPassword };
    }

    /**
     * HÀM MỚI: Đổi mật khẩu
     */
    async changePassword(userId: string, oldPassword: string, newPassword: string) {
        const user = await UserModel.findById(userId);
        if (!user) throw new Error('Người dùng không tồn tại');

        // 1. Kiểm tra mật khẩu cũ
        const isMatch = await bcrypt.compare(oldPassword, user.password_hash);
        if (!isMatch) throw new Error('Mật khẩu cũ không chính xác');

        // 2. Hash mật khẩu mới
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        // 3. Cập nhật vào DB
        await UserModel.update(userId, { password_hash: hashedPassword });
        
        return true;
    }

    async getUserByUsername(username: string) {
        return await UserModel.findByUsername(username);
    }
}

export default new AuthService();