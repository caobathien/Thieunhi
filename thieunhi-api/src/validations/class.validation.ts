import Joi from 'joi';

export const createClassSchema = Joi.object({
  class_name: Joi.string().required().messages({
    'any.required': 'Tên lớp là bắt buộc',
  }),
  room_number: Joi.string().allow('', null),
  academic_year: Joi.string().required().messages({
    'any.required': 'Năm học là bắt buộc',
  }),
  total_capacity: Joi.number().integer().min(1).default(40),
  main_leader_id: Joi.number().integer().allow(null),
  status: Joi.string().valid('active', 'inactive').default('active'),
  description: Joi.string().allow('', null),
});

export const updateClassSchema = Joi.object({
  class_name: Joi.string(),
  room_number: Joi.string().allow('', null),
  academic_year: Joi.string(),
  total_capacity: Joi.number().integer().min(1),
  main_leader_id: Joi.number().integer().allow(null),
  status: Joi.string().valid('active', 'inactive'),
  description: Joi.string().allow('', null),
});
