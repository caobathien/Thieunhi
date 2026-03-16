import pool from '../config/database';
import { IUser } from '../interfaces/user'; // Đổi tên interface cho phù hợp

class UserModel {
    async findByUserId(userId: string) {
        const query = `
            SELECT 
                id, username, full_name, gmail, phone, role,
                christian_name, dob, gender, address, avatar_url, bio, updated_at
            FROM users 
            WHERE id = $1;
        `;
        const result = await pool.query(query, [userId]);
        return result.rows[0];
    }

    async update(userId: string, data: Partial<IUser>) {
        // Loại bỏ trường 'id' khỏi data update để tránh lỗi ghi đè khóa chính
        const fields = Object.keys(data).filter(key => key !== 'id');
        if (fields.length === 0) return null;

        const setClause = fields.map((field, index) => `${field} = $${index + 1}`).join(', ');
        const values = fields.map(field => (data as any)[field]);

        const query = `
            UPDATE users
            SET ${setClause}, updated_at = CURRENT_TIMESTAMP
            WHERE id = $${fields.length + 1} 
            RETURNING *;
        `;
        
        const result = await pool.query(query, [...values, userId]);
        return result.rows[0];
    }
    async updatePassword(userId: string, hashedPassword: string) {
        const query = `
            UPDATE users
            SET password = $1, updated_at = CURRENT_TIMESTAMP
            WHERE id = $2 
            -- Chỉ trả về id hoặc username để xác nhận, tuyệt đối không RETURNING password
            RETURNING id, username, updated_at; 
        `;
        
        const result = await pool.query(query, [hashedPassword, userId]);
        return result.rows[0];
    }
}

export default new UserModel();