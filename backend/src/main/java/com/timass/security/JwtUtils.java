package com.timass.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
public class JwtUtils {

    // Khoa bi mat HMAC-SHA (toi thieu 256 bits)
    private static final String CHUOI_BI_MAT = "TimassSecretKeyForJwtAuthentication2026SecureKeyWithAtLeast256Bits";
    // Thoi han token: 24 gio = 24 * 60 * 60 * 1000 ms
    private static final long THOI_HAN_TOKEN_MS = 24L * 60 * 60 * 1000;

    private Key getSigningKey() {
        byte[] keyBytes = CHUOI_BI_MAT.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String generateToken(String soDienThoai) {
        Date ngayHienTai = new Date();
        Date ngayHetHan = new Date(ngayHienTai.getTime() + THOI_HAN_TOKEN_MS);

        return Jwts.builder()
                .setSubject(soDienThoai)
                .setIssuedAt(ngayHienTai)
                .setExpiration(ngayHetHan)
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String getSoDienThoaiTuToken(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
        return claims.getSubject();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public long getThoiGianHetHanGiay() {
        return THOI_HAN_TOKEN_MS / 1000;
    }
}

