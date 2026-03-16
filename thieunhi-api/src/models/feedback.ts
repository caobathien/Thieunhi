import pool from '../config/database';
import { IFeedback } from '../interfaces/feedback';

class FeedbackModel {
    // 1. Gửi phản hồi mới
    async create(data: IFeedback) {
        const query = `
            INSERT INTO feedbacks (user_id, class_id, title, content, rating, category, image_url, is_anonymous)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING *;
        `;
        const values = [
            data.user_id, data.class_id, data.title, data.content, 
            data.rating, data.category, data.image_url, data.is_anonymous || false
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    async findAll() {
    const query = `
        SELECT f.*, u.full_name as sender_name, u.role as sender_role, c.class_name
        FROM feedbacks f
        LEFT JOIN users u ON f.user_id = u.id
        LEFT JOIN classes c ON f.class_id = c.id
        ORDER BY f.created_at DESC;
    `;
    const result = await pool.query(query);
    return result.rows;
}

    // 3. Admin cập nhật trạng thái hoặc ghi chú phản hồi
    async updateStatus(id: number, status: string, adminNote: string) {
        const query = `
            UPDATE feedbacks 
            SET status = $1, admin_note = $2 
            WHERE id = $3 
            RETURNING *;
        `;
        const result = await pool.query(query, [status, adminNote, id]);
        return result.rows[0];
    }

    // 4. Xem phản hồi của cá nhân tôi
    async findByUserId(userId: string) {
        const query = `SELECT * FROM feedbacks WHERE user_id = $1 ORDER BY created_at DESC`;
        const result = await pool.query(query, [userId]);
        return result.rows;
    }
}

export default new FeedbackModel();