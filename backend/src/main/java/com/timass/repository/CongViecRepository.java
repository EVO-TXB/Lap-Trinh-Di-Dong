package com.timass.repository;

import com.timass.entity.CongViec;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CongViecRepository extends JpaRepository<CongViec, Long> {

    List<CongViec> findByNguoiDungId(Long maNguoiDung);

    @Query("SELECT c FROM CongViec c WHERE c.nguoiDung.id = :maNguoiDung " +
           "AND c.thoiGianBatDau >= :tuNgay AND c.thoiGianKetThuc <= :denNgay " +
           "ORDER BY c.thoiGianBatDau ASC")
    List<CongViec> findByNguoiDungVaKhoangThoiGian(
            @Param("maNguoiDung") Long maNguoiDung,
            @Param("tuNgay") LocalDateTime tuNgay,
            @Param("denNgay") LocalDateTime denNgay
    );

    List<CongViec> findByQuyTacLapId(Long maQuyTacLap);

    void deleteByQuyTacLapId(Long maQuyTacLap);
}

