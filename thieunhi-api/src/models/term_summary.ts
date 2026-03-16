import pool from '../config/database';
import { ITermSummary } from '../interfaces/term_summary';

class TermSummaryModel {
    // 1. Tự động tính toán và cập nhật tổng kết cho một em
    async calculateSummary(childId: string, classId: number, term: string, year: string) {
        // Lấy số buổi điểm danh (Có mặt/Muộn tính là có mặt)
        const attendanceRes = await pool.query(
            `SELECT 
                COUNT(*) FILTER (WHERE status IN ('Có mặt', 'Muộn')) as present,
                COUNT(*) as total
                FROM attendance 
                WHERE child_id = $1 AND class_id = $2 AND academic_year = $3`,
            [childId, classId, year]
        );

        // Lấy điểm trung bình học tập (GPA)
        const gradeRes = await pool.query(
            `SELECT SUM(score * weight) / SUM(weight) as gpa
                FROM grades
                WHERE child_id = $1 AND class_id = $2 AND term = $4 AND academic_year = $3`,
            [childId, classId, year, term]
        );

        const { present, total } = attendanceRes.rows[0];
        const academic_score = parseFloat(gradeRes.rows[0].gpa) || 0;
        
        // CHIA 2: Quy đổi chuyên cần sang thang điểm 10 và cộng trung bình
        const attendance_score = total > 0 ? (parseInt(present) / parseInt(total)) * 10 : 0;
        const final_avg = (academic_score + attendance_score) / 2;

        const query = `
            INSERT INTO term_summaries (child_id, class_id, term, academic_year, avg_score, attendance_count, absence_count, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
            ON CONFLICT (child_id, class_id, term, academic_year) 
            DO UPDATE SET 
                avg_score = EXCLUDED.avg_score,
                attendance_count = EXCLUDED.attendance_count,
                updated_at = NOW()
            RETURNING *;
        `;
        
        const values = [childId, classId, term, year, final_avg.toFixed(2), present, (total - present)];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // 2. Lấy thông tin tổng kết
    async findSummary(childId: string, year: string) {
        const query = `
            SELECT ts.*, c.class_name 
            FROM term_summaries ts
            JOIN classes c ON ts.class_id = c.id
            WHERE ts.child_id = $1 AND ts.academic_year = $2
            ORDER BY ts.term ASC;
        `;
        const result = await pool.query(query, [childId, year]);
        return result.rows;
    }
    async calculateClassSummary(classId: number, term: string, year: string) {
        const students = await pool.query('SELECT id FROM children WHERE class_id = $1', [classId]);
        
        const summaries = [];
        for (const student of students.rows) {
            const s = await this.calculateSummary(student.id, classId, term, year);
            summaries.push(s);
        }
        return summaries;
    }

    // 3. Cập nhật xếp loại/lời phê (Dành cho Huynh trưởng)
    async updateManualInfo(id: number, data: Partial<ITermSummary>) {
        const query = `
            UPDATE term_summaries 
            SET conduct_grade = COALESCE($1, conduct_grade),
                final_result = COALESCE($2, final_result),
                teacher_remarks = COALESCE($3, teacher_remarks),
                is_locked = COALESCE($4, is_locked),
                updated_at = NOW()
            WHERE id = $5 RETURNING *;
        `;
        const values = [data.conduct_grade, data.final_result, data.teacher_remarks, data.is_locked, id];
        const result = await pool.query(query, values);
        return result.rows[0];
    }
    // xem tổng kết thiếu nhi trong lớp
    async findSummariesWithStudentInfo(classId: number, year: string) {
    const query = `
        SELECT 
            ts.*, 
            c.first_name, 
            c.last_name, 
            c.baptismal_name 
        FROM term_summaries ts
        JOIN children c ON ts.child_id = c.id
        WHERE ts.class_id = $1 AND ts.academic_year = $2
        ORDER BY c.first_name ASC, ts.term ASC;
    `;
    const result = await pool.query(query, [classId, year]);
    return result.rows;
}
}

export default new TermSummaryModel();