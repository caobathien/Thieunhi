import pool from '../config/database';
import { IGrade } from '../interfaces/grade';

class GradeModel {
    // Nhập bản ghi điểm mới cho một thiếu nhi
    // Điểm số sẽ mặc định là 0 theo thiết kế DB
    async create(data: IGrade) {
        const query = `
            INSERT INTO grades (
                child_id, class_id, teacher_id, 
                midterm_score_k1, final_score_k1, 
                midterm_score_k2, final_score_k2, 
                academic_year, remarks
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING *;
        `;
        const values = [
            data.child_id, 
            data.class_id, 
            data.teacher_id, 
            data.midterm_score_k1 || 0, 
            data.final_score_k1 || 0, 
            data.midterm_score_k2 || 0, 
            data.final_score_k2 || 0, 
            data.academic_year, 
            data.remarks
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    async findByChild(childId: string, academicYear: string) {
    const query = `
        SELECT 
            g.*, 
            c.first_name, 
            c.last_name, 
            c.baptismal_name,
            cl.class_name
        FROM grades g
        JOIN children c ON g.child_id = c.id
        JOIN classes cl ON g.class_id = cl.id
        WHERE g.child_id = $1
            AND ($2::text IS NULL OR g.academic_year = $2);
    `;
    const result = await pool.query(query, [childId, academicYear]);
    return result.rows; // Đảm bảo trả về các hàng tìm được
}

    // Cập nhật các đầu điểm (Chỉ sửa điểm, không nhập tên bài thi)
    async update(id: string, data: Partial<IGrade>) {
        const query = `
            UPDATE grades 
            SET midterm_score_k1 = COALESCE($1, midterm_score_k1),
                final_score_k1 = COALESCE($2, final_score_k1),
                midterm_score_k2 = COALESCE($3, midterm_score_k2),
                final_score_k2 = COALESCE($4, final_score_k2),
                remarks = COALESCE($5, remarks),
                updated_at = NOW()
            WHERE id = $6 
            RETURNING *;
        `;
        const values = [
            data.midterm_score_k1, 
            data.final_score_k1, 
            data.midterm_score_k2, 
            data.final_score_k2, 
            data.remarks, 
            Number(id)
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Lấy danh sách điểm theo lớp để hiển thị bảng tổng hợp
    async findByClass(classId: number) {
        const query = `
            SELECT 
                c.id as child_id,
                c.first_name,
                c.last_name,
                c.baptismal_name,
                g.id as grade_id,
                g.midterm_score_k1,
                g.final_score_k1,
                g.midterm_score_k2,
                g.final_score_k2,
                g.academic_year,
                g.remarks
            FROM children c
            LEFT JOIN grades g ON g.child_id = c.id
            WHERE c.class_id = $1
            ORDER BY c.first_name ASC;
        `;
        const result = await pool.query(query, [classId]);
        return result.rows;
    }
}

export default new GradeModel();