export enum UserRole {
    ADMIN = 'admin',
    LEADER_VIP = 'leader-vip',
    LEADER = 'leader',
    TEACHER = 'teacher',
    USER = 'user'
}

export enum AttendanceStatus {
    PRESENT = 'present',
    ABSENT_EXCUSED = 'absent_excused',
    ABSENT_UNEXCUSED = 'absent_unexcused',
    LATE = 'late'
}

export const ROLES = {
    ADMIN: 'admin',
    LEADER_VIP: 'leader-vip',
    LEADER: 'leader',
    TEACHER: 'teacher',
    USER: 'user'
};

export const USER_STATUS = {
    ACTIVE: 'active',
    LOCKED: 'locked',
    PENDING: 'pending'
};