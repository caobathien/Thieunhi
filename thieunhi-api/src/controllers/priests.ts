import { Request, Response } from 'express';
import PriestService from '../services/priests';
import { sendSuccess, sendError } from '../utils/response';

class PriestController {
    /**
     * Lấy danh sách Quý Cha
     */
    async getAllPriests(req: Request, res: Response) {
        try {
            const priests = await PriestService.getAllPriests();
            return sendSuccess(res, 'Lấy danh sách thành công', priests);
        } catch (error: any) {
            return sendError(res, error.message, 500);
        }
    }

    /**
     * Thêm mới Cha (Chỉ Admin)
     */
    async createPriest(req: Request, res: Response) {
        try {
            const result = await PriestService.createPriest(req.body);
            return sendSuccess(res, 'Thêm mới thành công', result);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    /**
     * Cập nhật thông tin (Chỉ Admin)
     */
    async updatePriest(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const result = await PriestService.updatePriest(parseInt(id as string, 10), req.body);
            return sendSuccess(res, 'Cập nhật thành công', result);
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }

    /**
     * Xóa Cha (Chỉ Admin)
     */
    async deletePriest(req: Request, res: Response) {
        try {
            const { id } = req.params;
            await PriestService.deletePriest(parseInt(id as string, 10));
            return sendSuccess(res, 'Xóa thành công');
        } catch (error: any) {
            return sendError(res, error.message, 400);
        }
    }
}

export default new PriestController();
