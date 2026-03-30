import pool from '../config/database';
import { IClassAssignment } from '../interfaces/class_assignment';

class ClassAssignmentModel {
    // Phân công Huynh trưởng vào lớp
    async checkExistingAssignment(userId: string, academicYear: string) {
        const query = `
            SELECT ca.*, c.class_name 
            FROM class_assignments ca
            JOIN classes c ON ca.class_id = c.id
            WHERE ca.user_id = $1 AND ca.academic_year = $2
        `;
        const result = await pool.query(query, [userId, academicYear]);
        return result.rows[0]; // Trả về thông tin phân công cũ nếu có
    }

    // Phân công Huynh trưởng vào lớp (có kiểm tra trùng)
    async create(data: IClassAssignment) {
        // 1. Kiểm tra xem người này đã có lớp chưa
        const existing = await this.checkExistingAssignment(data.user_id, data.academic_year);
        
        if (existing) {
            throw new Error(`Huynh trưởng này đã được phân công vào lớp ${existing.class_name} trong niên học ${data.academic_year}.`);
        }

        // 2. Nếu chưa có thì mới tiến hành thêm mới
        const query = `
            INSERT INTO class_assignments (user_id, class_id, assignment_role, academic_year)
            VALUES ($1, $2, $3, $4)
            RETURNING *;
        `;
        const values = [data.user_id, data.class_id, data.assignment_role, data.academic_year];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Lấy danh sách Huynh trưởng của một lớp cụ thể
    async findByClass(classId: number, academicYear: string) {
        const query = `
            SELECT ca.*, u.full_name, u.gmail, lp.christian_name, lp.phone, c.class_name
            FROM class_assignments ca
            JOIN users u ON ca.user_id = u.id
            JOIN classes c ON ca.class_id = c.id
            LEFT JOIN leaders_profile lp ON u.id = lp.user_id
            WHERE ca.class_id = $1 AND ca.academic_year = $2
            ORDER BY ca.assigned_at ASC;
        `;
        const result = await pool.query(query, [classId, academicYear]);
        return result.rows;
    }

    // Lấy tất cả phân công (kèm thông tin lớp và leader)
    async findAll(academicYear: string) {
        const query = `
            SELECT ca.*, u.full_name, u.gmail, lp.christian_name, c.class_name
            FROM class_assignments ca
            JOIN users u ON ca.user_id = u.id
            JOIN classes c ON ca.class_id = c.id
            LEFT JOIN leaders_profile lp ON u.id = lp.user_id
            WHERE ca.academic_year = $1
            ORDER BY c.class_name ASC, u.full_name ASC;
        `;
        const result = await pool.query(query, [academicYear]);
        return result.rows;
    }

    // Kiểm tra xem user có phải là leader của lớp đó không
    async isUserAssignedToClass(userId: string, classId: number) {
        const query = `
            SELECT 1 
            FROM class_assignments 
            WHERE user_id = $1 AND class_id = $2
        `;
        const result = await pool.query(query, [userId, classId]);
        return (result.rowCount ?? 0) > 0;
    }

    // Xóa phân công (Khi đổi lớp cho Huynh trưởng)
    async delete(id: number) {
        const result = await pool.query('DELETE FROM class_assignments WHERE id = $1', [id]);
        return (result.rowCount ?? 0) > 0;
    }

    async findById(id: number) {
        const query = `
            SELECT ca.*, u.full_name, c.class_name
            FROM class_assignments ca
            JOIN users u ON ca.user_id = u.id
            JOIN classes c ON ca.class_id = c.id
            WHERE ca.id = $1
        `;
        const result = await pool.query(query, [id]);
        return result.rows[0];
    }

    // Lấy phân công hiện tại của một user (cho profile)
    async findByUserId(userId: string) {
        const query = `
            SELECT ca.*, c.class_name 
            FROM class_assignments ca
            JOIN classes c ON ca.class_id = c.id
            WHERE ca.user_id = $1
            ORDER BY ca.assigned_at DESC
            LIMIT 1
        `;
        const result = await pool.query(query, [userId]);
        return result.rows[0];
    }
}

export default new ClassAssignmentModel();