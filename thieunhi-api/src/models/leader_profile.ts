import pool from '../config/database';
import { ILeaderProfile } from '../interfaces/leader_profile';

class LeaderProfileModel {
    // Tạo hồ sơ mới
    async create(data: ILeaderProfile) {
        const query = `
            INSERT INTO leaders_profile (
                user_id, christian_name, full_name, phone, gmail, 
                birth_date, rank, position, join_date, status, avatar_url, award_notes, notes
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
            RETURNING *;
        `;
        const values = [
            data.user_id, data.christian_name, data.full_name, data.phone, data.gmail,
            data.birth_date, data.rank, data.position, data.join_date, 
            data.status || 'Đang công tác', data.avatar_url, data.award_notes, data.notes
        ];
        console.log('Executing create query:', query, values);
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    async findByUserId(userId: string) {
        const query = `
            SELECT 
                u.id as user_id, u.username, u.full_name as account_full_name, 
                u.gmail as account_gmail, u.phone as account_phone, u.role as account_role,
                u.status as account_status, u.is_active, u.created_at as account_created_at,
                lp.id, lp.christian_name, lp.full_name, lp.phone, lp.gmail,
                COALESCE(lp.birth_date, lp.dob) as birth_date, lp.dob,
                lp.rank, lp.position, lp.join_date, lp.status, 
                lp.avatar_url, lp.award_notes, lp.notes,
                ac.class_id as assigned_class_id, ac.class_name as assigned_class
            FROM users u
            LEFT JOIN leaders_profile lp ON u.id = lp.user_id
            LEFT JOIN (
                SELECT DISTINCT ON (ca.user_id) ca.user_id, ca.class_id, c.class_name
                FROM class_assignments ca
                JOIN classes c ON ca.class_id = c.id
                ORDER BY ca.user_id, ca.assigned_at DESC
            ) ac ON u.id = ac.user_id
            WHERE u.id = $1
            ORDER BY 
                CASE WHEN lp.christian_name IS NOT NULL AND lp.christian_name != 'Chưa cập nhật' THEN 0 ELSE 1 END,
                lp.id DESC;
        `;
        const result = await pool.query(query, [userId]);
        return result.rows[0];
    }

    async findById(id: number) {
        const query = `
            SELECT 
                u.id as user_id, u.username, u.full_name as account_full_name, 
                u.gmail as account_gmail, u.phone as account_phone, u.role as account_role,
                lp.*
            FROM leaders_profile lp
            JOIN users u ON lp.user_id = u.id
            WHERE lp.id = $1;
        `;
        const result = await pool.query(query, [id]);
        return result.rows[0];
    }

    // Cập nhật hoặc tạo mới hồ sơ (UPSERT)
    async update(userId: string, data: Partial<ILeaderProfile>) {
        const fields = Object.keys(data).filter(key => key !== 'user_id' && key !== 'id');
        
        // Luôn đảm bảo có user_id
        const allFields = ['user_id', ...fields];
        const placeholders = allFields.map((_, i) => `$${i + 1}`).join(', ');
        const updateClause = fields.map((field, i) => `${field} = EXCLUDED.${field}`).join(', ');
        
        const query = `
            INSERT INTO leaders_profile (${allFields.join(', ')})
            VALUES (${placeholders})
            ON CONFLICT (user_id) 
            DO UPDATE SET ${updateClause === '' ? 'user_id = EXCLUDED.user_id' : updateClause}
            RETURNING *;
        `;
        
        const values = [userId, ...fields.map(field => (data as any)[field])];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Admin cập nhật các trường hành chính
    async adminUpdate(userId: string, data: Partial<ILeaderProfile>) {
        const fields = Object.keys(data).filter(key => key !== 'user_id' && key !== 'id');
        if (fields.length === 0) return null;

        const setClause = fields.map((field, index) => `${field} = $${index + 1}`).join(', ');
        const values = fields.map(field => (data as any)[field]);

        const query = `
            UPDATE leaders_profile
            SET ${setClause}
            WHERE user_id = $${fields.length + 1} 
            RETURNING *;
        `;
        
        const result = await pool.query(query, [...values, userId]);
        return result.rows[0];
    }

    async findAll() {
        const query = `
            SELECT 
                u.id as user_id, u.username, u.full_name as account_full_name, 
                u.gmail as account_gmail, u.phone as account_phone, u.role as account_role,
                lp.id, lp.christian_name, lp.full_name, lp.rank, lp.position, lp.status,
                lp.avatar_url, lp.phone, lp.gmail, lp.award_notes, lp.notes,
                ac.class_id as assigned_class_id, ac.class_name as assigned_class
            FROM users u
            INNER JOIN leaders_profile lp ON u.id = lp.user_id
            LEFT JOIN (
                SELECT DISTINCT ON (ca.user_id) ca.user_id, ca.class_id, c.class_name
                FROM class_assignments ca
                JOIN classes c ON ca.class_id = c.id
                ORDER BY ca.user_id, ca.assigned_at DESC
            ) ac ON u.id = ac.user_id
            ORDER BY COALESCE(lp.full_name, u.full_name) ASC;
        `;
        const result = await pool.query(query);
        return result.rows;
    }

    // Xóa hồ sơ theo userId
    async deleteByUserId(userId: string) {
        const query = 'DELETE FROM leaders_profile WHERE user_id = $1';
        await pool.query(query, [userId]);
    }
}

export default new LeaderProfileModel();