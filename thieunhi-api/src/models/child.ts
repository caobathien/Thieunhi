import db from '../config/database';
import { IChild } from '../interfaces/child';

class ChildModel {
    async create(child: IChild): Promise<IChild> {
        const query = `
            INSERT INTO children (
                class_id, first_name, last_name, baptismal_name, birth_date, 
                gender, address, ten_thanh_bo, ho_va_ten_bo, sdt_bo, 
                ten_thanh_me, ho_va_ten_me, sdt_me, ma_qr, status
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
            RETURNING *;
        `;
        const values = [
            child.class_id, child.first_name, child.last_name, child.baptismal_name, child.birth_date,
            child.gender, child.address, child.ten_thanh_bo, child.ho_va_ten_bo, child.sdt_bo,
            child.ten_thanh_me, child.ho_va_ten_me, child.sdt_me, child.ma_qr, child.status || 'active'
        ];
        const result = await db.query(query, values);
        return result.rows[0];
    }

    async findAll(): Promise<IChild[]> {
        // SELECT đúng các cột hiện có trong ảnh của bạn
        const result = await db.query('SELECT * FROM children ORDER BY last_name ASC, first_name ASC');
        return result.rows;
    }


    // 3. Tìm theo ID (Dùng cho trang chi tiết hoặc khi sửa)
    async findById(id: string): Promise<IChild | null> {
        const result = await db.query('SELECT * FROM children WHERE id = $1', [id]);
        return result.rows[0] || null;
    }

    // 4. Cập nhật thông tin
    async update(id: string, data: Partial<IChild>): Promise<IChild | null> {
        const fields = Object.keys(data).filter(key => data[key as keyof IChild] !== undefined);
        const values = fields.map(key => data[key as keyof IChild]);

        if (fields.length === 0) return null;

        const setClause = fields
            .map((field, index) => `${field} = $${index + 2}`)
            .join(', ');

        const query = `
            UPDATE children 
            SET ${setClause} 
            WHERE id = $1 
            RETURNING *;
        `;

        const result = await db.query(query, [id, ...values]);
        return result.rows[0] || null;
    }

    // 5. Xóa thiếu nhi
    async delete(id: string): Promise<boolean> {
        const result = await db.query('DELETE FROM children WHERE id = $1', [id]);
        return (result.rowCount ?? 0) > 0;
    }
    async findByClass(classId: number): Promise<IChild[]> {
        const query = `
            SELECT c.*, cl.class_name 
            FROM children c
            LEFT JOIN classes cl ON c.class_id = cl.id
            WHERE c.class_id = $1
            ORDER BY c.last_name ASC, c.first_name ASC;
        `;
        const result = await db.query(query, [classId]);
        return result.rows;
    }
}

export default new ChildModel();