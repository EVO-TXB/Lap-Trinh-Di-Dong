package com.timass.controller;

import com.timass.dto.ApiResponse;
import com.timass.dto.DangKyRequest;
import com.timass.dto.DangNhapRequest;
import com.timass.dto.NguoiDungDto;
import com.timass.dto.XacThucResponse;
import com.timass.service.XacThucService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/xac-thuc")
public class XacThucController {

    private final XacThucService xacThucService;

    public XacThucController(XacThucService xacThucService) {
        this.xacThucService = xacThucService;
    }

    @PostMapping("/dang-ky")
    public ResponseEntity<ApiResponse<NguoiDungDto>> dangKy(
            @Valid @RequestBody DangKyRequest dangKyRequest) {
        NguoiDungDto nguoiDungMoi = xacThucService.dangKy(dangKyRequest);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(201, "Đăng ký tài khoản thành công", nguoiDungMoi));
    }

    @PostMapping("/dang-nhap")
    public ResponseEntity<ApiResponse<XacThucResponse>> dangNhap(
            @Valid @RequestBody DangNhapRequest dangNhapRequest) {
        XacThucResponse xacThucResponse = xacThucService.dangNhap(dangNhapRequest);
        return ResponseEntity.ok(ApiResponse.thanhCong(xacThucResponse, "Đăng nhập thành công"));
    }

    @GetMapping("/kiem-tra-so-dien-thoai")
    public ResponseEntity<ApiResponse<Boolean>> kiemTraSoDienThoai(
            @RequestParam("soDienThoai") String soDienThoai) {
        boolean tonTai = xacThucService.kiemTraSoDienThoaiTonTai(soDienThoai);
        return ResponseEntity.ok(ApiResponse.thanhCong(tonTai, "Kiểm tra số điện thoại thành công"));
    }
}

