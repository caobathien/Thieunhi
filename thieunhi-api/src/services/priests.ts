import PriestModel from '../models/priest';
import { IPriest } from '../interfaces/priest';

class PriestService {
    async createPriest(data: IPriest) {
        if (!data.christian_name || !data.full_name) {
            throw new Error('Tên thánh và Họ Tên là bắt buộc');
        }
        return await PriestModel.create(data);
    }

    async updatePriest(id: number, data: Partial<IPriest>) {
        const priest = await PriestModel.findById(id);
        if (!priest) {
            throw new Error('Không tìm thấy dữ liệu Cha');
        }
        return await PriestModel.update(id, data);
    }

    async getAllPriests() {
        return await PriestModel.findAll();
    }

    async getPriestById(id: number) {
        const priest = await PriestModel.findById(id);
        if (!priest) throw new Error('Không tìm thấy dữ liệu Cha');
        return priest;
    }

    async deletePriest(id: number) {
        const priest = await PriestModel.findById(id);
        if (!priest) {
            throw new Error('Không tìm thấy dữ liệu Cha');
        }
        return await PriestModel.delete(id);
    }
}

export default new PriestService();
