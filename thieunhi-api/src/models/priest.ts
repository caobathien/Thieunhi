import pool from '../config/database';
import { IPriest } from '../interfaces/priest';

class PriestModel {
    async create(data: IPriest) {
        const query = `
            INSERT INTO cha (
                christian_name, full_name, birth_date, ordination_date, appointment_date, image_url, favorite_verse
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *;
        `;
        const values = [
            data.christian_name, 
            data.full_name, 
            data.birth_date || null, 
            data.ordination_date || null, 
            data.appointment_date || null, 
            data.image_url || null, 
            data.favorite_verse || null
        ];
        const result = await pool.query(query, values);
        return result.rows[0];
    }

    async update(id: number, data: Partial<IPriest>) {
        const fields = Object.keys(data).filter(key => key !== 'id' && key !== 'created_at' && key !== 'updated_at');
        if (fields.length === 0) return null;

        const setClause = fields.map((field, index) => `${field} = $${index + 1}`).join(', ');
        const values = fields.map(field => (data as any)[field]);

        const query = `
            UPDATE cha
            SET ${setClause}, updated_at = CURRENT_TIMESTAMP
            WHERE id = $${fields.length + 1} 
            RETURNING *;
        `;
        
        const result = await pool.query(query, [...values, id]);
        return result.rows[0];
    }

    async findAll() {
        const query = `
            SELECT * FROM cha
            ORDER BY id ASC;
        `;
        const result = await pool.query(query);
        return result.rows;
    }

    async findById(id: number) {
        const query = `
            SELECT * FROM cha WHERE id = $1;
        `;
        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    async delete(id: number) {
        const query = 'DELETE FROM cha WHERE id = $1';
        const result = await pool.query(query, [id]);
        return (result.rowCount ?? 0) > 0;
    }
}

export default new PriestModel();
