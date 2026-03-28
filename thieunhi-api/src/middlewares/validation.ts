import { Request, Response, NextFunction } from 'express';
import { Schema } from 'joi';

export const validate = (schema: Schema, property: 'body' | 'query' | 'params' = 'body') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req[property]);

    if (!error) {
      next();
    } else {
      const { details } = error;
      const message = details.map((i) => i.message).join(',');

      console.log('❌ Validation Error:', message);
      console.log('📦 Request Body:', JSON.stringify(req[property], null, 2));
      res.status(400).json({
        success: false,
        message,
        details: details // Luôn hiển thị chi tiết để debug lỗi 400 trên Render
      });
    }
  };
};
