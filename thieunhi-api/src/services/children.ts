import ChildModel from '../models/child';
import { IChild } from '../interfaces/child';
import { v4 as uuidv4 } from 'uuid';
import ExcelService from './excel';

class ChildService {

    async getChildrenByClass(classId: number) {
        return await ChildModel.findByClass(classId);
    }

    async getAllChildren() {
        return await ChildModel.findAll();
    }

    async getChildDetail(id: string) {
        const child = await ChildModel.findById(id);
        if (!child) throw new Error('Không tìm thấy thiếu nhi này');
        return child;
    }

    async addChild(data: IChild) {
        if (!data.ma_qr) {
            data.ma_qr = `QR-${uuidv4().substring(0, 8).toUpperCase()}`;
        }
        
        // Convert boolean gender to string if necessary
        if (typeof data.gender === 'boolean') {
            data.gender = data.gender ? 'Nam' : 'Nữ';
        }

        return await ChildModel.create(data);
    }

    async updateChild(id: string, data: Partial<IChild>) {
        if (typeof data.gender === 'boolean') {
            data.gender = data.gender ? 'Nam' : 'Nữ';
        }
        const updated = await ChildModel.update(id, data);
        if (!updated) throw new Error('Không tìm thấy thiếu nhi để cập nhật');
        return updated;
    }

    async removeChild(id: string) {
        return await ChildModel.delete(id);
    }
    async exportToExcel(classId?: number) {
        const children = classId 
            ? await ChildModel.findByClass(classId)
            : await ChildModel.findAll();
        
        if (!children || children.length === 0) {
            throw new Error('Không có dữ liệu thiếu nhi để xuất file');
        }

        return await ExcelService.exportChildren(children);
    }

    async importFromExcel(buffer: Buffer, class_id: number) {
        const childrenData = await ExcelService.importChildren(buffer);
        const results = [];

        for (const data of childrenData) {
            if (data.id) {
                // Update existing
                const updated = await ChildModel.update(data.id, { ...data, class_id });
                results.push(updated);
            } else {
                // Create new
                const newChild = await this.addChild({ ...data, class_id } as IChild);
                results.push(newChild);
            }
        }
        return results;
    }
}

export default new ChildService();