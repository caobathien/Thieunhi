import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';

const router = Router();

// Cấu hình Multer để lưu file vào thư mục 'uploads'
const storage = multer.diskStorage({
  destination: (req, res, cb) => {
    // Sử dụng process.cwd() để đảm bảo đường dẫn ổn định cả ở DEV và PROD (dist)
    const uploadsPath = path.join(process.cwd(), 'uploads'); 
    cb(null, uploadsPath);
  },
  filename: (req, file, cb) => {
    // Đổi tên file để tránh trùng lặp: timestamp + tên gốc
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

// Chỉ chấp nhận các file ảnh
const fileFilter = (req: Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Chỉ chấp nhận file định dạng hình ảnh!'));
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 1024 * 1024 * 50 // Tăng giới hạn lên 50MB để hỗ trợ ảnh chất lượng cao
  }
}).single('image');

router.post('/', (req: Request, res: Response): void => {
  upload(req, res, (err: any) => {
    if (err) {
      console.error('❌ Lỗi Multer:', err);
      res.status(500).json({
        success: false,
        message: 'Lỗi khi tải ảnh lên',
        error: err.message
      });
      return;
    }

    try {
      console.log('--- Nhận yêu cầu upload ---');
      if (!req.file) {
        console.log('Error: Không tìm thấy file trong request');
        res.status(400).json({ success: false, message: 'Vui lòng chọn một file ảnh để tải lên' });
        return;
      }
      
      console.log('File đã nhận:', req.file.filename, 'Size:', req.file.size);
      
      // Trả về URL tĩnh để client có thể truy cập ảnh
      const imageUrl = `/uploads/${req.file.filename}`;
      
      res.status(200).json({
        success: true,
        data: {
          url: imageUrl
        }
      });
    } catch (error: any) {
      console.error('❌ Lỗi xử lý sau upload:', error);
      res.status(500).json({
        success: false,
        message: 'Lỗi máy chủ khi xử lý ảnh',
        error: error.message
      });
    }
  });
});

export default router;
