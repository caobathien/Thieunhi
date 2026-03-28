import pool from '../config/database';
import { ITermSummary } from '../interfaces/term_summary';

class TermSummaryModel {
    // 1. Tự động tính toán và cập nhật tổng kết cho một em
    async calculateSummary(childId: string, classId: number, term: string, year: string) {
        // A. Lấy danh sách các ngày Chủ Nhật thực tế có điểm danh cho lớp này
        const classSundaysRes = await pool.query(
            `SELECT DISTINCT attendance_date 
             FROM attendance 
             WHERE class_id = $1 AND academic_year = $2 
               AND EXTRACT(DOW FROM attendance_date) = 0`,
            [classId, year]
        );
        const totalSundays = parseInt(classSundaysRes.rowCount?.toString() ?? '0');

        // B. Lấy số buổi có mặt của học sinh đó vào các ngày Chủ Nhật này
        const presentSundaysRes = await pool.query(
            `SELECT COUNT(*) as present
             FROM attendance 
             WHERE child_id = $1 AND class_id = $2 AND academic_year = $3 
               AND EXTRACT(DOW FROM attendance_date) = 0 
               AND status IN ('Có mặt', 'Muộn')`,
            [childId, classId, year]
        );
        const present = parseInt(presentSundaysRes.rows[0].present);

        // C. Lấy điểm trung bình học tập (GPA) từ bảng grades theo học kỳ
        let gpaQuery = '';
        if (term === 'HK1') {
            gpaQuery = `SELECT (midterm_score_k1 + final_score_k1) / 2 as gpa FROM grades WHERE child_id = $1 AND academic_year = $2`;
        } else if (term === 'HK2') {
            gpaQuery = `SELECT (midterm_score_k2 + final_score_k2) / 2 as gpa FROM grades WHERE child_id = $1 AND academic_year = $2`;
        } else { // CaNam
            gpaQuery = `SELECT ((midterm_score_k1 + final_score_k1) / 2 + (midterm_score_k2 + final_score_k2) / 2) / 2 as gpa FROM grades WHERE child_id = $1 AND academic_year = $2`;
        }

        const gradeRes = await pool.query(gpaQuery, [childId, year]);
        const academic_score = gradeRes.rows.length > 0 ? parseFloat(gradeRes.rows[0].gpa) || 0 : 0;
        
        // D. KẾT QUẢ: avg_score LẤY TRỰC TIẾP TỪ GRADED (Không chia đôi với chuyên cần)
        const final_avg = academic_score;

        const query = `
            INSERT INTO term_summaries (child_id, class_id, term, academic_year, avg_score, attendance_count, absence_count, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
            ON CONFLICT (child_id, class_id, term, academic_year) 
            DO UPDATE SET 
                avg_score = EXCLUDED.avg_score,
                attendance_count = EXCLUDED.attendance_count,
                absence_count = EXCLUDED.absence_count,
                updated_at = NOW()
            RETURNING *;
        `;
        
        const values = [childId, classId, term, year, final_avg.toFixed(2), present, (totalSundays - present)];
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
    async findSummariesWithStudentInfo(classId: number, year: string, term: string) {
    const query = `
        SELECT 
            c.id as child_id,
            c.first_name, 
            c.last_name, 
            c.baptismal_name,
            ts.*,
            g.midterm_score_k1,
            g.final_score_k1,
            g.midterm_score_k2,
            g.final_score_k2
        FROM children c
        LEFT JOIN term_summaries ts ON c.id = ts.child_id AND ts.academic_year = $2 AND ts.term = $3
        LEFT JOIN grades g ON c.id = g.child_id AND g.academic_year = $2
        WHERE c.class_id = $1
        ORDER BY c.first_name ASC;
    `;
    const result = await pool.query(query, [classId, year, term]);
    return result.rows;
}

    // Lấy danh sách các ngày vắng Chủ Nhật cụ thể
    async getAbsenceDates(childId: string, year: string) {
        const query = `
            SELECT attendance_date
            FROM attendance
            WHERE child_id = $1 
                AND academic_year = $2 
                AND status = 'Vắng'
                AND EXTRACT(DOW FROM attendance_date) = 0
            ORDER BY attendance_date DESC;
        `;
        const result = await pool.query(query, [childId, year]);
        return result.rows.map(row => row.attendance_date);
    }
}

export default new TermSummaryModel();