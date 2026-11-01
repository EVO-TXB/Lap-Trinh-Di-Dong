-- ============================================================================
-- DỰ ÁN: TIMASS (Time Management & Scheduling System)
-- HỆ QUẢN TRỊ CSDL: MySQL 8.x
-- QUY CHUẨN: Bảng & Cột là tiếng Việt không dấu snake_case
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `timass_db` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `timass_db`;

DROP TABLE IF EXISTS `cong_viec_con`;
DROP TABLE IF EXISTS `cong_viec`;
DROP TABLE IF EXISTS `quy_tac_lap`;
DROP TABLE IF EXISTS `nguoi_dung`;

-- 1. BẢNG NGUOI_DUNG
CREATE TABLE `nguoi_dung` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `so_dien_thoai` VARCHAR(20) NOT NULL UNIQUE,
    `mat_khau` VARCHAR(255) NOT NULL,
    `ho_ten` VARCHAR(100) NULL,
    `ngay_tao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `uk_nguoi_dung_so_dien_thoai` UNIQUE (`so_dien_thoai`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. BẢNG QUY_TAC_LAP
CREATE TABLE `quy_tac_lap` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `ma_nguoi_dung` BIGINT NOT NULL,
    `ten_cong_viec` VARCHAR(255) NOT NULL,
    `la_thiet_yeu` BOOLEAN NOT NULL DEFAULT FALSE,
    `gio_bat_dau` TIME NOT NULL,
    `gio_ket_thuc` TIME NOT NULL,
    `dia_diem` VARCHAR(255) NULL,
    `cac_ngay_trong_tuan` VARCHAR(50) NOT NULL COMMENT 'Ví dụ chuỗi: 2,4,6 hoặc 2,3,4,5,6',
    `ngay_bat_dau` DATE NOT NULL,
    `ngay_ket_thuc` DATE NOT NULL,
    `nhac_nho_truoc_phut` INT NOT NULL DEFAULT 15,
    `ngay_tao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_quy_tac_lap_nguoi_dung` 
        FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung` (`id`) 
        ON DELETE CASCADE,
    INDEX `idx_quy_tac_lap_ma_nguoi_dung` (`ma_nguoi_dung`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. BẢNG CONG_VIEC
CREATE TABLE `cong_viec` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `ma_nguoi_dung` BIGINT NOT NULL,
    `ma_quy_tac_lap` BIGINT NULL,
    `ten_cong_viec` VARCHAR(255) NOT NULL,
    `thoi_gian_bat_dau` DATETIME NOT NULL,
    `thoi_gian_ket_thuc` DATETIME NOT NULL,
    `dia_diem` VARCHAR(255) NULL,
    `la_thiet_yeu` BOOLEAN NOT NULL DEFAULT FALSE,
    `da_hoan_thanh` BOOLEAN NOT NULL DEFAULT FALSE,
    `nhac_nho_truoc_phut` INT NOT NULL DEFAULT 15,
    `ngay_tao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_cong_viec_nguoi_dung` 
        FOREIGN KEY (`ma_nguoi_dung`) REFERENCES `nguoi_dung` (`id`) 
        ON DELETE CASCADE,
    CONSTRAINT `fk_cong_viec_quy_tac_lap` 
        FOREIGN KEY (`ma_quy_tac_lap`) REFERENCES `quy_tac_lap` (`id`) 
        ON DELETE CASCADE,
    INDEX `idx_cong_viec_nguoi_dung_thoi_gian` (`ma_nguoi_dung`, `thoi_gian_bat_dau`, `thoi_gian_ket_thuc`),
    INDEX `idx_cong_viec_quy_tac_lap` (`ma_quy_tac_lap`),
    INDEX `idx_cong_viec_thoi_gian_bat_dau` (`thoi_gian_bat_dau`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. BẢNG CONG_VIEC_CON
CREATE TABLE `cong_viec_con` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `ma_cong_viec` BIGINT NOT NULL,
    `ten_cong_viec_con` VARCHAR(255) NOT NULL,
    `da_hoan_thanh` BOOLEAN NOT NULL DEFAULT FALSE,
    `thu_tu` INT NOT NULL DEFAULT 0,
    `ngay_tao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_cong_viec_con_cong_viec` 
        FOREIGN KEY (`ma_cong_viec`) REFERENCES `cong_viec` (`id`) 
        ON DELETE CASCADE,
    INDEX `idx_cong_viec_con_cong_viec_thu_tu` (`ma_cong_viec`, `thu_tu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- DỮ LIỆU MẪU (SEED DATA)
-- ============================================================================

INSERT INTO `nguoi_dung` (`id`, `so_dien_thoai`, `mat_khau`, `ho_ten`, `ngay_tao`) 
VALUES (
    1, 
    '0987654321', 
    '$2a$10$wT8KzD/x6c1U5bX0Z7G3Oe6r6QO7Yl3d12z5z0P1oG7C5P4dYmJGy', 
    'Nguyễn Văn An', 
    '2026-11-01 08:00:00'
);

INSERT INTO `quy_tac_lap` (
    `id`, `ma_nguoi_dung`, `ten_cong_viec`, `la_thiet_yeu`, 
    `gio_bat_dau`, `gio_ket_thuc`, `dia_diem`, `cac_ngay_trong_tuan`, 
    `ngay_bat_dau`, `ngay_ket_thuc`, `nhac_nho_truoc_phut`, `ngay_tao`
) VALUES (
    1, 
    1, 
    'Học lập trình Spring Boot & Flutter', 
    FALSE, 
    '19:30:00', 
    '21:30:00', 
    'Phòng làm việc tại nhà', 
    '2,4,6', 
    '2026-11-01', 
    '2026-12-31', 
    15, 
    '2026-11-01 08:05:00'
);

INSERT INTO `cong_viec` (
    `id`, `ma_nguoi_dung`, `ma_quy_tac_lap`, `ten_cong_viec`, 
    `thoi_gian_bat_dau`, `thoi_gian_ket_thuc`, `dia_diem`, 
    `la_thiet_yeu`, `da_hoan_thanh`, `nhac_nho_truoc_phut`, `ngay_tao`
) VALUES (
    1, 
    1, 
    1, 
    'Học lập trình Spring Boot & Flutter - Buổi 1', 
    '2026-11-02 19:30:00', 
    '2026-11-02 21:30:00', 
    'Phòng làm việc tại nhà', 
    FALSE, 
    TRUE, 
    15, 
    '2026-11-01 08:10:00'
), (
    2, 
    1, 
    NULL, 
    'Ngủ đêm (Thiết yếu)', 
    '2026-11-02 23:00:00', 
    '2026-11-03 06:30:00', 
    'Phòng ngủ', 
    TRUE, 
    FALSE, 
    15, 
    '2026-11-01 08:10:00'
), (
    3, 
    1, 
    NULL, 
    'Họp tiến độ đồ án tốt nghiệp Timass', 
    '2026-11-03 09:00:00', 
    '2026-11-03 11:00:00', 
    'Google Meet', 
    FALSE, 
    FALSE, 
    15, 
    '2026-11-01 08:10:00'
);

INSERT INTO `cong_viec_con` (
    `id`, `ma_cong_viec`, `ten_cong_viec_con`, `da_hoan_thanh`, `thu_tu`, `ngay_tao`
) VALUES (
    1, 
    3, 
    'Chuẩn bị slide báo cáo MVP', 
    TRUE, 
    1, 
    '2026-11-01 08:15:00'
), (
    2, 
    3, 
    'Demo tính năng Lịch tuần và Checklist', 
    FALSE, 
    2, 
    '2026-11-01 08:15:00'
);
