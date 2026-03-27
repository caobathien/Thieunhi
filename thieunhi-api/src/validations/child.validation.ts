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
  gender: Joi.alternatives().try(
    Joi.string().valid('Nam', 'Nữ'),
    Joi.boolean()
  ).required().messages({
    'any.required': 'Giới tính là bắt buộc',
  }),
  avatar_url: Joi.string().allow('', null),
  address: Joi.string().allow('', null),
  ten_thanh_bo: Joi.string().allow('', null),
  ho_va_ten_bo: Joi.string().allow('', null),
  sdt_bo: Joi.string().allow('', null),
  ten_thanh_me: Joi.string().allow('', null),
  ho_va_ten_me: Joi.string().allow('', null),
  sdt_me: Joi.string().allow('', null),
  emergency_phone: Joi.string().allow('', null),
  ma_qr: Joi.string().allow('', null),
  status: Joi.string().valid('active', 'inactive', 'graduated').default('active'),
  join_date: Joi.date().allow(null),
  notes: Joi.string().allow('', null),
});

export const updateChildSchema = Joi.object({
  class_id: Joi.number().integer(),
  first_name: Joi.string(),
  last_name: Joi.string(),
  baptismal_name: Joi.string().allow('', null),
  birth_date: Joi.date().allow(null),
  gender: Joi.alternatives().try(
    Joi.string().valid('Nam', 'Nữ'),
    Joi.boolean()
  ),
  avatar_url: Joi.string().allow('', null),
  address: Joi.string().allow('', null),
  ten_thanh_bo: Joi.string().allow('', null),
  ho_va_ten_bo: Joi.string().allow('', null),
  sdt_bo: Joi.string().allow('', null),
  ten_thanh_me: Joi.string().allow('', null),
  ho_va_ten_me: Joi.string().allow('', null),
  sdt_me: Joi.string().allow('', null),
  emergency_phone: Joi.string().allow('', null),
  ma_qr: Joi.string().allow('', null),
  status: Joi.string().valid('active', 'inactive', 'graduated'),
  join_date: Joi.date().allow(null),
  notes: Joi.string().allow('', null),
});
