import pool from '../config/database';
import { IAttendance } from '../interfaces/attendance';

class AttendanceModel {
    async markAttendance(data: IAttendance) {
        const query = `
            INSERT INTO attendance (
                child_id, class_id, is_present, status, reason, marked_by,
                attendance_date, check_in_time, lesson_topic
            )
            VALUES ($1, $2, $3, $4, $5, $6, COALESCE($7::date, CURRENT_DATE), CURRENT_TIME, $8)
            ON CONFLICT (child_id, class_id, attendance_date) 
            DO UPDATE SET 
                is_present = EXCLUDED.is_present,
                status = EXCLUDED.status,
                check_in_time = CURRENT_TIME,
                marked_by = EXCLUDED.marked_by,
                reason = EXCLUDED.reason,
                lesson_topic = EXCLUDED.lesson_topic,
                updated_at = CURRENT_TIMESTAMP
            RETURNING *;
        `;
        const values = [
            data.child_id, 
            data.class_id, 
            data.is_present, 
            data.status, 
            data.reason || null, 
            data.marked_by,
            data.attendance_date || null,
            data.lesson_topic || null
        ];
        
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    async getDailyReport(classId: number, date: string) {
        const query = `
            SELECT a.*, c.first_name, c.last_name, c.baptismal_name
            FROM attendance a
            JOIN children c ON a.child_id = c.id
            WHERE a.class_id = $1 AND a.attendance_date = $2;
        `;
        const result = await pool.query(query, [classId, date]);
        return result.rows;
    }
    async getClassAttendance(classId: number, date: string) {
    const query = `
        SELECT 
            a.id,
            a.child_id,
            c.first_name, 
            c.last_name, 
            c.baptismal_name,
            a.check_in_time,
            a.status,
            a.reason,
            u.username as marked_by_name,
            a.updated_at
        FROM attendance a
        JOIN children c ON a.child_id = c.id
        -- SỬA Ở ĐÂY: Ép kiểu marked_by về UUID để khớp với u.id
        LEFT JOIN users u ON a.marked_by::uuid = u.id 
        -- THÊM ::uuid nếu child_id hoặc class_id là uuid, 
        -- nhưng ở đây classId là number nên giữ nguyên
        WHERE a.class_id = $1 AND a.attendance_date = $2
        ORDER BY a.check_in_time DESC;
    `;
    const result = await pool.query(query, [classId, date]);
    return result.rows;
}
    async getReportByFilter(classId: number, date: string) {
        const query = `
            SELECT 
                a.id,
                a.child_id,
                c.first_name, 
                c.last_name, 
                c.baptismal_name,
                c.ma_qr,
                a.attendance_date,
                a.check_in_time,
                a.status,
                a.is_present,
                a.reason,
                u.full_name as marked_by_name
            FROM attendance a
            JOIN children c ON a.child_id = c.id
            LEFT JOIN users u ON a.marked_by = CAST(u.id AS VARCHAR)
            WHERE a.class_id = $1 
                AND a.attendance_date = $2  -- Lọc chính xác ngày (YYYY-MM-DD)
            ORDER BY a.check_in_time ASC;
        `;
        const result = await pool.query(query, [classId, date]);
        return result.rows;
    }
    // danh sách các em thiếu nhi điểm danh
    async getStudentListForManual(classId: number, date: string) {
        const query = `
            SELECT 
                c.id as child_id,
                c.first_name, 
                c.last_name, 
                c.baptismal_name,
                a.status,         -- Sẽ là NULL nếu chưa điểm danh
                a.check_in_time,
                a.is_present
            FROM children c
            LEFT JOIN attendance a ON c.id = a.child_id 
                AND a.class_id = $1 
                AND a.attendance_date = $2
            WHERE c.class_id = $1 -- Giả sử bảng children có class_id để quản lý lớp
            ORDER BY c.first_name ASC;
        `;
        const result = await pool.query(query, [classId, date]);
        return result.rows;
    }

    // Lấy thống kê cho điểm danh từ startDate đến endDate
    async getAttendanceStats(classId: number, startDate: string, endDate: string) {
        const query = `
            SELECT 
                c.id as child_id,
                c.first_name, 
                c.last_name, 
                c.baptismal_name,
                a.attendance_date,
                a.status,
                a.is_present,
                a.reason
            FROM children c
            LEFT JOIN attendance a 
                ON c.id = a.child_id 
                AND a.class_id = $1 
                AND a.attendance_date >= $2::date 
                AND a.attendance_date <= $3::date
            WHERE c.class_id = $1
            ORDER BY c.first_name ASC, a.attendance_date ASC;
        `;
        const result = await pool.query(query, [classId, startDate, endDate]);
        return result.rows;
    }
}

export default new AttendanceModel();