import Joi from 'joi';

export const createClassSchema = Joi.object({
  class_name: Joi.string().required().messages({
    'any.required': 'Tên lớp là bắt buộc',
  }),
  room_number: Joi.string().allow('', null),
  academic_year: Joi.string().allow('', null),
  total_capacity: Joi.number().integer().min(1).default(40),
  main_leader_id: Joi.string().uuid().allow(null), // Changed to string/uuid based on DB
  status: Joi.string().valid('active', 'inactive').default('active'),
  description: Joi.string().allow('', null),
  start_time: Joi.string().regex(/^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/).allow('', null),
});

export const updateClassSchema = Joi.object({
  class_name: Joi.string(),
  room_number: Joi.string().allow('', null),
  academic_year: Joi.string().allow('', null),
  total_capacity: Joi.number().integer().min(1),
  main_leader_id: Joi.string().uuid().allow(null), // Changed to string/uuid
  status: Joi.string().valid('active', 'inactive'),
  description: Joi.string().allow('', null),
  start_time: Joi.string().regex(/^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/).allow('', null),
});
