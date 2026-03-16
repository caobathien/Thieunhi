import Joi from 'joi';

export const updateProfileSchema = Joi.object({
    full_name: Joi.string().min(3).max(50).messages({
        'string.min': 'Họ tên phải có ít nhất 3 ký tự',
        'string.max': 'Họ tên không được vượt quá 50 ký tự'
    }),
    gmail: Joi.string().email().messages({
        'string.email': 'Email không đúng định dạng'
    }),
    phone: Joi.string().pattern(/^[0-9]{10}$/).messages({
        'string.pattern.base': 'Số điện thoại phải gồm 10 chữ số'
    }),
    avatar_url: Joi.string().uri().allow('', null),
    notes: Joi.string().allow('', null)
});

export const changePasswordSchema = Joi.object({
    oldPassword: Joi.string().required().messages({
        'any.required': 'Vui lòng nhập mật khẩu cũ'
    }),
    newPassword: Joi.string().min(6).required().messages({
        'string.min': 'Mật khẩu mới phải có ít nhất 6 ký tự',
        'any.required': 'Vui lòng nhập mật khẩu mới'
    })
});