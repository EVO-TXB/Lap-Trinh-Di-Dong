package com.timass.service;

import com.timass.dto.DangKyRequest;
import com.timass.dto.DangNhapRequest;
import com.timass.dto.NguoiDungDto;
import com.timass.dto.XacThucResponse;
import com.timass.entity.NguoiDung;
import com.timass.repository.NguoiDungRepository;
import com.timass.security.JwtUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class XacThucService {

    private final NguoiDungRepository nguoiDungRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;

    public XacThucService(NguoiDungRepository nguoiDungRepository,
                          PasswordEncoder passwordEncoder,
                          JwtUtils jwtUtils) {
        this.nguoiDungRepository = nguoiDungRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtils = jwtUtils;
    }

    public boolean kiemTraSoDienThoaiTonTai(String soDienThoai) {
        return nguoiDungRepository.existsBySoDienThoai(soDienThoai.trim());
    }

    @Transactional
    public NguoiDungDto dangKy(DangKyRequest dangKyRequest) {
        String sdtClean = dangKyRequest.getSoDienThoai().trim();

        if (nguoiDungRepository.existsBySoDienThoai(sdtClean)) {
            throw new IllegalArgumentException("Số điện thoại này đã được đăng ký trong hệ thống!");
        }

        NguoiDung nguoiDungMoi = new NguoiDung();
        nguoiDungMoi.setSoDienThoai(sdtClean);
        nguoiDungMoi.setMatKhau(passwordEncoder.encode(dangKyRequest.getMatKhau()));
        nguoiDungMoi.setHoTen(dangKyRequest.getHoTen().trim());
        nguoiDungMoi.setNgayTao(LocalDateTime.now());

        NguoiDung nguoiDungDaLuu = nguoiDungRepository.save(nguoiDungMoi);

        return new NguoiDungDto(
                nguoiDungDaLuu.getId(),
                nguoiDungDaLuu.getSoDienThoai(),
                nguoiDungDaLuu.getHoTen(),
                nguoiDungDaLuu.getNgayTao()
        );
    }

    @Transactional(readOnly = true)
    public XacThucResponse dangNhap(DangNhapRequest dangNhapRequest) {
        String sdtClean = dangNhapRequest.getSoDienThoai().trim();

        NguoiDung nguoiDung = nguoiDungRepository.findBySoDienThoai(sdtClean)
                .orElseThrow(() -> new IllegalArgumentException("Số điện thoại hoặc mật khẩu không chính xác!"));

        if (!passwordEncoder.matches(dangNhapRequest.getMatKhau(), nguoiDung.getMatKhau())) {
            throw new IllegalArgumentException("Số điện thoại hoặc mật khẩu không chính xác!");
        }

        String token = jwtUtils.generateToken(nguoiDung.getSoDienThoai());

        NguoiDungDto nguoiDungDto = new NguoiDungDto(
                nguoiDung.getId(),
                nguoiDung.getSoDienThoai(),
                nguoiDung.getHoTen(),
                nguoiDung.getNgayTao()
        );

        return new XacThucResponse(
                token,
                "Bearer",
                jwtUtils.getThoiGianHetHanGiay(),
                nguoiDungDto
        );
    }
}

