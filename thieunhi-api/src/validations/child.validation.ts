import Joi from 'joi';

export const createChildSchema = Joi.object({
  class_id: Joi.number().integer().required().messages({
    'any.required': 'Mã lớp là bắt buộc',
  }),
  first_name: Joi.string().required().messages({
    'any.required': 'Tên là bắt buộc',
  }),
  last_name: Joi.string().required().messages({
    'any.required': 'Họ là bắt buộc',
  }),
  baptismal_name: Joi.string().allow('', null),
  birth_date: Joi.date().allow(null),
  gender: Joi.string().valid('Nam', 'Nữ').required().messages({
    'any.required': 'Giới tính là bắt buộc',
  }),
  address: Joi.string().allow('', null),
  ten_thanh_bo: Joi.string().allow('', null),
  ho_va_ten_bo: Joi.string().allow('', null),
  sdt_bo: Joi.string().pattern(/^[0-9]{10,11}$/).allow('', null).messages({
    'string.pattern.base': 'Số điện thoại bố không hợp lệ',
  }),
  ten_thanh_me: Joi.string().allow('', null),
  ho_va_ten_me: Joi.string().allow('', null),
  sdt_me: Joi.string().pattern(/^[0-9]{10,11}$/).allow('', null).messages({
    'string.pattern.base': 'Số điện thoại mẹ không hợp lệ',
  }),
  ma_qr: Joi.string().allow('', null),
  status: Joi.string().valid('active', 'inactive', 'graduated').default('active'),
});

export const updateChildSchema = Joi.object({
  class_id: Joi.number().integer(),
  first_name: Joi.string(),
  last_name: Joi.string(),
  baptismal_name: Joi.string().allow('', null),
  birth_date: Joi.date().allow(null),
  gender: Joi.string().valid('Nam', 'Nữ'),
  address: Joi.string().allow('', null),
  ten_thanh_bo: Joi.string().allow('', null),
  ho_va_ten_bo: Joi.string().allow('', null),
  sdt_bo: Joi.string().pattern(/^[0-9]{10,11}$/).allow('', null),
  ten_thanh_me: Joi.string().allow('', null),
  ho_va_ten_me: Joi.string().allow('', null),
  sdt_me: Joi.string().pattern(/^[0-9]{10,11}$/).allow('', null),
  ma_qr: Joi.string().allow('', null),
  status: Joi.string().valid('active', 'inactive', 'graduated'),
});
