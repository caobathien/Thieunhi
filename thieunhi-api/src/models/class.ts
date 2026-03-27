import pool from '../config/database';
import { IClass } from '../interfaces/class';

class ClassModel {
    // Lấy danh sách tất cả các lớp (kèm tên Huynh trưởng phụ trách)
    async findAll() {
        const query = `
            SELECT 
                c.*, 
                u.full_name as leader_name,
                u.phone as leader_phone,
                COUNT(ch.id)::int as student_count
            FROM classes c
            LEFT JOIN users u ON c.main_leader_id = u.id
            LEFT JOIN children ch ON c.id = ch.class_id
            GROUP BY c.id, u.full_name, u.phone
            ORDER BY c.class_name ASC
        `;
        const result = await pool.query(query);
        return result.rows;
    }

    // Tạo lớp mới
    async create(data: IClass) {
        const query = `
            INSERT INTO classes (
                class_name,
                room_number,
                academic_year,
                academic_year_id,
                total_capacity,
                main_leader_id,
                status,
                description,
                start_time
            )
            SELECT
                $1,
                $2,
                ay.name,
                ay.id,
                $3,
                $4,
                $5,
                $6,
                $7
            FROM academic_years ay
            WHERE ay.is_current = true
            LIMIT 1
            RETURNING *;
        `;
        const values = [
            data.class_name, 
            data.room_number, 
            data.total_capacity || 40, 
            data.main_leader_id, 
            data.status || 'active', 
            data.description,
            data.start_time || '08:00:00'
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Cập nhật thông tin lớp
    async update(id: number, data: Partial<IClass>) {
        const query = `
            UPDATE classes 
            SET class_name = COALESCE($1, class_name),
                room_number = COALESCE($2, room_number),
                total_capacity = COALESCE($3, total_capacity),
                main_leader_id = COALESCE($4, main_leader_id),
                status = COALESCE($5, status),
                description = COALESCE($6, description),
                start_time = COALESCE($7, start_time)
            WHERE id = $8 RETURNING *;
        `;
        const values = [
            data.class_name, data.room_number, data.total_capacity, 
            data.main_leader_id, data.status, data.description, 
            data.start_time, id
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Xóa lớp học
    async delete(id: number): Promise<boolean> {
        const result = await pool.query('DELETE FROM classes WHERE id = $1', [id]);
        return (result.rowCount ?? 0) > 0;
    }
}

export default new ClassModel();