import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { sendError } from '../utils/response';

// Định nghĩa kiểu dữ liệu cho Payload của Token
interface JwtPayload {
    id: string;
    role: string;
}

// Mở rộng kiểu Request của Express để có thể chứa thông tin user sau khi check xong
declare global {
    namespace Express {
        interface Request {
            user?: JwtPayload;
        }
    }
}

export const protect = async (req: any, res: Response, next: NextFunction) => {
    try {
        let token;
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        }

        if (!token) {
            return res.status(401).json({ message: 'Bạn cần đăng nhập để thực hiện hành động này' });
        }

        // Giải mã token
        const decoded: any = jwt.verify(token, process.env.JWT_SECRET || 'secret');
        
        // Lưu thông tin vào request để các hàm sau sử dụng
        req.user = decoded; 
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại' });
    }
};


class AuthMiddleware {
    // 1. Kiểm tra Token (Xác thực - Authentication)
    public protect = async (req: Request, res: Response, next: NextFunction) => {
        let token;

        // Lấy token từ header Authorization: Bearer <token>
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        }

        if (!token) {
            return sendError(res, 'Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.', 401);
        }

        try {
            // Giải mã token
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret') as JwtPayload;

            // Lưu thông tin user vào request để các hàm sau sử dụng
            req.user = decoded;
            next();
        } catch (error) {
            return sendError(res, 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại', 401);
        }
    };

    // 2. Kiểm tra Quyền (Phân quyền - Authorization)
    // Dùng closure để truyền danh sách các quyền được phép vào
    public restrictTo = (...allowedRoles: string[]) => {
        return (req: Request, res: Response, next: NextFunction) => {
            console.log('User Role from Token:', req.user?.role); 
            console.log('Allowed Roles:', allowedRoles);
            if (!req.user || !allowedRoles.includes(req.user.role)) {
                return sendError(res, 'Bạn không có quyền thực hiện hành động này.', 403);
            }
            next();
        };
    };
}

export default new AuthMiddleware();