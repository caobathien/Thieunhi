import pool from '../config/database';
import { IActivity } from '../interfaces/activity';

class ActivityModel {
    // 1. Lấy danh sách cho Trang chủ (Ưu tiên tin Ghim và Priority cao)
    async findPublic() {
        const query = `
            SELECT * FROM activities 
            WHERE is_public = TRUE 
            ORDER BY is_featured DESC, priority DESC, created_at DESC;
        `;
        const result = await pool.query(query);
        return result.rows;
    }

    // 2. Tạo thông báo mới
    async create(data: IActivity) {
        const query = `
            INSERT INTO activities (title, summary, content, image_url, start_time, location, is_featured, is_public, priority)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING *;
        `;
        const values = [
            data.title, data.summary, data.content, data.image_url, 
            data.start_time, data.location, data.is_featured || false, 
            data.is_public ?? true, data.priority || 0
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // 3. Cập nhật thông báo
    async update(id: number, data: Partial<IActivity>) {
        const query = `
            UPDATE activities 
            SET title = COALESCE($1, title),
                summary = COALESCE($2, summary),
                content = COALESCE($3, content),
                image_url = COALESCE($4, image_url),
                is_featured = COALESCE($5, is_featured),
                is_public = COALESCE($6, is_public),
                priority = COALESCE($7, priority)
            WHERE id = $8 RETURNING *;
        `;
        const values = [data.title, data.summary, data.content, data.image_url, data.is_featured, data.is_public, data.priority, id];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // 4. Xóa thông báo
    async delete(id: number) {
        const result = await pool.query('DELETE FROM activities WHERE id = $1', [id]);
        return (result.rowCount ?? 0) > 0;
    }
}

export default new ActivityModel();