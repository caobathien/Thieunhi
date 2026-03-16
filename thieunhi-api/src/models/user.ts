import db from '../config/database';
import { IUser } from '../interfaces/user';

class UserModel {
    // 1. Tìm theo Username (Đã có)
    async findByUsername(username: string): Promise<IUser | null> {
        const query = `
            SELECT id, username, password_hash, role, status, is_active, full_name, gmail, phone 
            FROM users 
            WHERE username = $1
        `;
        const result = await db.query(query, [username]);
        return result.rows[0] || null;
    }

    // 1b. Tìm theo Username, Email hoặc Số điện thoại (Cho Login linh hoạt)
    async findByIdentifier(identifier: string): Promise<IUser | null> {
        const query = `
            SELECT id, username, password_hash, role, status, is_active, full_name, gmail, phone 
            FROM users 
            WHERE username = $1 OR gmail = $1 OR phone = $1
        `;
        const result = await db.query(query, [identifier]);
        return result.rows[0] || null;
    }

    // 2. Tìm theo ID (Bổ sung mới)
    async findById(id: string): Promise<IUser | null> {
        const query = `
            SELECT id, username, password_hash, full_name, gmail, phone, role, status, is_active, avatar_url, notes, created_at
            FROM users 
            WHERE id = $1
        `;
        const result = await db.query(query, [id]);
        return result.rows[0] || null;
    }

    async findByPhoneOrEmail(phone?: string, email?: string): Promise<IUser | null> {
        if (!phone && !email) return null;
        let query = `SELECT * FROM users WHERE `;
        const params = [];
        if (phone && email) {
            query += `phone = $1 OR gmail = $2`;
            params.push(phone, email);
        } else if (phone) {
            query += `phone = $1`;
            params.push(phone);
        } else {
            query += `gmail = $1`;
            params.push(email);
        }
        const result = await db.query(query, params);
        return result.rows[0] || null;
    }

    // 3. Tạo người dùng mới (Đã có)
    async create(user: IUser): Promise<IUser> {
        const query = `
            INSERT INTO users (username, password_hash, full_name, gmail, phone, role)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, username, full_name, role, status;
        `;
        const values = [
            user.username,
            user.password_hash,
            user.full_name,
            user.gmail,
            user.phone,
            user.role || 'user'
        ];
        const result = await db.query(query, values);
        return result.rows[0];
    }

    // 4. Lấy tất cả người dùng (Đã có)
    async findAll(): Promise<IUser[]> {
        const result = await db.query('SELECT id, username, password_hash, full_name, role, status, is_active FROM users ORDER BY created_at DESC');
        return result.rows;
    }

    // 5. Cập nhật thông tin người dùng
    async update(id: string, data: Partial<IUser>): Promise<IUser | null> {
        const fields = Object.keys(data);
        const values = Object.values(data);

        if (fields.length === 0) return null;

        const setClause = fields
            .map((field, index) => `${field} = $${index + 2}`)
            .join(', ');

        const query = `
            UPDATE users 
            SET ${setClause} 
            WHERE id = $1 
            RETURNING id, username, full_name, role, status;
        `;

        const result = await db.query(query, [id, ...values]);
        return result.rows[0] || null;
    }

    // 6. Cập nhật trạng thái khóa/mở khóa (Bổ sung mới)
    async updateStatus(id: string, statusData: { status: string, lock_reason?: string, locked_at?: Date }): Promise<void> {
        const query = `
            UPDATE users 
            SET status = $2, lock_reason = $3, locked_at = $4 
            WHERE id = $1
        `;
        await db.query(query, [id, statusData.status, statusData.lock_reason, statusData.locked_at]);
    }

    // 7. Xóa người dùng
    async delete(id: string): Promise<boolean> {
        const result = await db.query('DELETE FROM users WHERE id = $1', [id]);
        return (result.rowCount ?? 0) > 0;
    }
}

export default new UserModel();