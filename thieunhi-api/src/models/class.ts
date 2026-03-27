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
            INSERT INTO classes (class_name, room_number, academic_year, academic_year_id, total_capacity, main_leader_id, status, description)
            VALUES ($1, $2, $3, 
                (SELECT id FROM academic_years WHERE academic_year = (SELECT value FROM system_settings WHERE key = 'current_academic_year' LIMIT 1)), 
                $4, $5, $6, $7)
            RETURNING *;
        `;
        const values = [
            data.class_name, data.room_number, data.academic_year, 
            data.total_capacity || 40, data.main_leader_id, 
            data.status || 'active', data.description
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
                academic_year = COALESCE($3, academic_year),
                academic_year_id = COALESCE($4, (SELECT id FROM academic_years WHERE academic_year = (SELECT value FROM system_settings WHERE key = 'current_academic_year' LIMIT 1))),
                total_capacity = COALESCE($5, total_capacity),
                main_leader_id = COALESCE($6, main_leader_id),
                status = COALESCE($7, status),
                description = COALESCE($8, description)
            WHERE id = $9 RETURNING *;
        `;
        const values = [
            data.class_name, data.room_number, data.academic_year,
            data.academic_year_id, data.total_capacity, data.main_leader_id, 
            data.status, data.description, id
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