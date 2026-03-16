import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';

const router = Router();

// Cấu hình Multer để lưu file vào thư mục 'uploads'
const storage = multer.diskStorage({
  destination: (req, res, cb) => {
    cb(null, 'uploads/');
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
    fileSize: 1024 * 1024 * 5 // Giới hạn 5MB
  }
});

router.post('/', upload.single('image'), (req: Request, res: Response): void => {
  try {
    if (!req.file) {
      res.status(400).json({ success: false, message: 'Vui lòng chọn một file ảnh để tải lên' });
      return;
    }
    
    // Trả về URL tĩnh để client có thể truy cập ảnh
    const imageUrl = `/uploads/${req.file.filename}`;
    
    res.status(200).json({
      success: true,
      data: {
        url: imageUrl
      }
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      message: 'Lỗi máy chủ khi tải ảnh lên',
      error: error.message
    });
  }
});

export default router;
