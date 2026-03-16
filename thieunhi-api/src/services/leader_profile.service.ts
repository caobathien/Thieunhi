import pool from '../config/database';
import LeaderProfileModel from '../models/leader_profile';
import AuthService from './auth';
import { ILeaderProfile } from '../interfaces/leader_profile';

class LeaderProfileService {
    /**
     * Admin tạo Huynh Trưởng mới
     */
    async createLeader(data: { phone?: string, gmail?: string }) {
        const client = await pool.getClient();
        try {
            await client.query('BEGIN');

            // 1. Tự động tạo tài khoản user
            const userData = await AuthService.autoCreateLeaderAccount(data);
            
            // 2. Tạo leader profile
            // Mặc định các thông tin cá nhân sẽ trống, Admin chỉ nhập phone/gmail
            const profileData: ILeaderProfile = {
                user_id: userData.id!,
                christian_name: 'Chưa cập nhật', // Giá trị tạm thời
                full_name: userData.full_name || 'Huynh Trưởng',
                phone: userData.phone,
                gmail: userData.gmail,
                rank: 'Dự trưởng',
                position: 'Giáo lý viên',
                status: 'Đang công tác'
            };

            const profile = await LeaderProfileModel.create(profileData);

            await client.query('COMMIT');
            return { ...profile, tempPassword: (userData as any).tempPassword };
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Lấy hồ sơ cá nhân
     */
    async getProfileByUserId(userId: string) {
        const profile = await LeaderProfileModel.findByUserId(userId);
        return profile;
    }

    /**
     * Leader tự cập nhật hồ sơ
     */
    async updateMyProfile(userId: string, data: Partial<ILeaderProfile> & { username?: string }) {
        const client = await pool.getClient();
        try {
            await client.query('BEGIN');

            // 1. Nếu có đổi username, kiểm tra tính duy nhất
            if (data.username) {
                const existingUser = await AuthService.getUserByUsername(data.username);
                if (existingUser && existingUser.id !== userId) {
                    throw new Error('Tên tài khoản đã tồn tại');
                }
                // Cập nhật bảng users
                const UserModel = (await import('../models/user')).default;
                await UserModel.update(userId, { username: data.username });
            }

            // 2. Cập nhật các trường trong leaders_profile
            const editableFields = [
                'christian_name', 'full_name', 'phone', 'gmail', 
                'dob', 'avatar_url', 'notes'
            ];
            
            const filteredData: any = {};
            editableFields.forEach(field => {
                if (data[field as keyof ILeaderProfile] !== undefined) {
                    filteredData[field] = data[field as keyof ILeaderProfile];
                }
            });

            const result = await LeaderProfileModel.update(userId, filteredData);
            
            await client.query('COMMIT');
            return result;
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Admin cập nhật các trường hành chính
     */
    async adminUpdateProfile(userId: string, data: Partial<ILeaderProfile>) {
        return await LeaderProfileModel.adminUpdate(userId, data);
    }

    async getAllLeaders() {
        return await LeaderProfileModel.findAll();
    }
}

export default new LeaderProfileService();