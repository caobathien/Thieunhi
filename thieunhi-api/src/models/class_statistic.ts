import pool from '../config/database';

class ClassStatisticModel {
    // Tự động tính toán thống kê cho một lớp dựa trên dữ liệu tổng kết của từng em
    async calculateClassStat(classId: number, term: string, year: string) {
        const queryCalc = `
            SELECT 
                COUNT(*) as total,
                AVG(avg_score) as gpa,
                COUNT(*) FILTER (WHERE avg_score >= 8.0) as excellence,
                COUNT(*) FILTER (WHERE avg_score < 5.0) as weak,
                AVG((attendance_count::float / NULLIF(attendance_count + absence_count, 0)) * 100) as attendance_rate
            FROM term_summaries
            WHERE class_id = $1 AND term = $2 AND academic_year = $3;
        `;
        
        const calcRes = await pool.query(queryCalc, [classId, term, year]);
        const stats = calcRes.rows[0];

        const queryUpsert = `
            INSERT INTO class_statistics (
                class_id, academic_year, term, total_students, 
                class_gpa, excellence_count, weak_students_count, 
                average_attendance_rate, last_updated
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
            ON CONFLICT (class_id, academic_year, term)
            DO UPDATE SET 
                total_students = EXCLUDED.total_students,
                class_gpa = EXCLUDED.class_gpa,
                excellence_count = EXCLUDED.excellence_count,
                weak_students_count = EXCLUDED.weak_students_count,
                average_attendance_rate = EXCLUDED.average_attendance_rate,
                last_updated = NOW()
            RETURNING *;
        `;

        const values = [
            classId, year, term, 
            stats.total || 0, 
            stats.gpa || 0, 
            stats.excellence || 0, 
            stats.weak || 0, 
            stats.attendance_rate || 0
        ];

        const result = await pool.query(queryUpsert, values);
        return result.rows[0];
    }

    // Lấy bảng thống kê của một lớp qua các năm
    async getClassHistory(classId: number) {
        const query = `SELECT * FROM class_statistics WHERE class_id = $1 ORDER BY academic_year DESC, term ASC`;
        const result = await pool.query(query, [classId]);
        return result.rows;
    }
}

export default new ClassStatisticModel();