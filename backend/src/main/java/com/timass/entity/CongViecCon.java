package com.timass.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(
    name = "cong_viec_con",
    indexes = {
        @Index(name = "idx_cong_viec_con_cong_viec_thu_tu", columnList = "ma_cong_viec, thu_tu")
    }
)
public class CongViecCon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ma_cong_viec", nullable = false)
    private CongViec congViec;

    @Column(name = "ten_cong_viec_con", nullable = false, length = 255)
    private String tenCongViecCon;

    @Column(name = "da_hoan_thanh", nullable = false)
    private Boolean daHoanThanh = false;

    @Column(name = "thu_tu", nullable = false)
    private Integer thuTu = 0;

    @Column(name = "ngay_tao", nullable = false, updatable = false)
    private LocalDateTime ngayTao;

    public CongViecCon() {
    }

    public CongViecCon(Long id, CongViec congViec, String tenCongViecCon, Boolean daHoanThanh, Integer thuTu, LocalDateTime ngayTao) {
        this.id = id;
        this.congViec = congViec;
        this.tenCongViecCon = tenCongViecCon;
        this.daHoanThanh = daHoanThanh != null ? daHoanThanh : false;
        this.thuTu = thuTu != null ? thuTu : 0;
        this.ngayTao = ngayTao;
    }

    @PrePersist
    public void prePersist() {
        if (this.ngayTao == null) {
            this.ngayTao = LocalDateTime.now();
        }
        if (this.daHoanThanh == null) {
            this.daHoanThanh = false;
        }
        if (this.thuTu == null) {
            this.thuTu = 0;
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public CongViec getCongViec() {
        return congViec;
    }

    public void setCongViec(CongViec congViec) {
        this.congViec = congViec;
    }

    public String getTenCongViecCon() {
        return tenCongViecCon;
    }

    public void setTenCongViecCon(String tenCongViecCon) {
        this.tenCongViecCon = tenCongViecCon;
    }

    public Boolean getDaHoanThanh() {
        return daHoanThanh;
    }

    public void setDaHoanThanh(Boolean daHoanThanh) {
        this.daHoanThanh = daHoanThanh;
    }

    public Integer getThuTu() {
        return thuTu;
    }

    public void setThuTu(Integer thuTu) {
        this.thuTu = thuTu;
    }

    public LocalDateTime getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(LocalDateTime ngayTao) {
        this.ngayTao = ngayTao;
    }
}
