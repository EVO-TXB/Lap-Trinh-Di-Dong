package com.timass.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
    name = "cong_viec",
    indexes = {
        @Index(name = "idx_cong_viec_nguoi_dung_thoi_gian", columnList = "ma_nguoi_dung, thoi_gian_bat_dau, thoi_gian_ket_thuc"),
        @Index(name = "idx_cong_viec_quy_tac_lap", columnList = "ma_quy_tac_lap"),
        @Index(name = "idx_cong_viec_thoi_gian_bat_dau", columnList = "thoi_gian_bat_dau")
    }
)
public class CongViec {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ma_nguoi_dung", nullable = false)
    private NguoiDung nguoiDung;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ma_quy_tac_lap", nullable = true)
    private QuyTacLap quyTacLap;

    @Column(name = "ten_cong_viec", nullable = false, length = 255)
    private String tenCongViec;

    @Column(name = "thoi_gian_bat_dau", nullable = false)
    private LocalDateTime thoiGianBatDau;

    @Column(name = "thoi_gian_ket_thuc", nullable = false)
    private LocalDateTime thoiGianKetThuc;

    @Column(name = "dia_diem", length = 255)
    private String diaDiem;

    @Column(name = "la_thiet_yeu", nullable = false)
    private Boolean laThietYeu = false;

    @Column(name = "da_hoan_thanh", nullable = false)
    private Boolean daHoanThanh = false;

    @Column(name = "nhac_nho_truoc_phut", nullable = false)
    private Integer nhacNhoTruocPhut = 15;

    @Column(name = "ngay_tao", nullable = false, updatable = false)
    private LocalDateTime ngayTao;

    @OneToMany(mappedBy = "congViec", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<CongViecCon> danhSachCongViecCon = new ArrayList<>();

    public CongViec() {
    }

    public CongViec(Long id, NguoiDung nguoiDung, QuyTacLap quyTacLap, String tenCongViec,
                   LocalDateTime thoiGianBatDau, LocalDateTime thoiGianKetThuc, String diaDiem,
                   Boolean laThietYeu, Boolean daHoanThanh, Integer nhacNhoTruocPhut,
                   LocalDateTime ngayTao) {
        this.id = id;
        this.nguoiDung = nguoiDung;
        this.quyTacLap = quyTacLap;
        this.tenCongViec = tenCongViec;
        this.thoiGianBatDau = thoiGianBatDau;
        this.thoiGianKetThuc = thoiGianKetThuc;
        this.diaDiem = diaDiem;
        this.laThietYeu = laThietYeu != null ? laThietYeu : false;
        this.daHoanThanh = daHoanThanh != null ? daHoanThanh : false;
        this.nhacNhoTruocPhut = nhacNhoTruocPhut != null ? nhacNhoTruocPhut : 15;
        this.ngayTao = ngayTao;
    }

    @PrePersist
    public void prePersist() {
        if (this.ngayTao == null) {
            this.ngayTao = LocalDateTime.now();
        }
        if (this.laThietYeu == null) {
            this.laThietYeu = false;
        }
        if (this.daHoanThanh == null) {
            this.daHoanThanh = false;
        }
        if (this.nhacNhoTruocPhut == null) {
            this.nhacNhoTruocPhut = 15;
        }
    }

    public void themCongViecCon(CongViecCon congViecCon) {
        this.danhSachCongViecCon.add(congViecCon);
        congViecCon.setCongViec(this);
    }

    public void xoaCongViecCon(CongViecCon congViecCon) {
        this.danhSachCongViecCon.remove(congViecCon);
        congViecCon.setCongViec(null);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public NguoiDung getNguoiDung() {
        return nguoiDung;
    }

    public void setNguoiDung(NguoiDung nguoiDung) {
        this.nguoiDung = nguoiDung;
    }

    public QuyTacLap getQuyTacLap() {
        return quyTacLap;
    }

    public void setQuyTacLap(QuyTacLap quyTacLap) {
        this.quyTacLap = quyTacLap;
    }

    public String getTenCongViec() {
        return tenCongViec;
    }

    public void setTenCongViec(String tenCongViec) {
        this.tenCongViec = tenCongViec;
    }

    public LocalDateTime getThoiGianBatDau() {
        return thoiGianBatDau;
    }

    public void setThoiGianBatDau(LocalDateTime thoiGianBatDau) {
        this.thoiGianBatDau = thoiGianBatDau;
    }

    public LocalDateTime getThoiGianKetThuc() {
        return thoiGianKetThuc;
    }

    public void setThoiGianKetThuc(LocalDateTime thoiGianKetThuc) {
        this.thoiGianKetThuc = thoiGianKetThuc;
    }

    public String getDiaDiem() {
        return diaDiem;
    }

    public void setDiaDiem(String diaDiem) {
        this.diaDiem = diaDiem;
    }

    public Boolean getLaThietYeu() {
        return laThietYeu;
    }

    public void setLaThietYeu(Boolean laThietYeu) {
        this.laThietYeu = laThietYeu;
    }

    public Boolean getDaHoanThanh() {
        return daHoanThanh;
    }

    public void setDaHoanThanh(Boolean daHoanThanh) {
        this.daHoanThanh = daHoanThanh;
    }

    public Integer getNhacNhoTruocPhut() {
        return nhacNhoTruocPhut;
    }

    public void setNhacNhoTruocPhut(Integer nhacNhoTruocPhut) {
        this.nhacNhoTruocPhut = nhacNhoTruocPhut;
    }

    public LocalDateTime getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(LocalDateTime ngayTao) {
        this.ngayTao = ngayTao;
    }

    public List<CongViecCon> getDanhSachCongViecCon() {
        return danhSachCongViecCon;
    }

    public void setDanhSachCongViecCon(List<CongViecCon> danhSachCongViecCon) {
        this.danhSachCongViecCon = danhSachCongViecCon;
    }
}
