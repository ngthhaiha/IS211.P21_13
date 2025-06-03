-- TẠO NGƯỜI DÙNG 
CREATE USER GiamDoc IDENTIFIED BY giamdoc; 
CREATE USER QuanLy1 IDENTIFIED BY quanly1; 
CREATE USER NhanVien1 IDENTIFIED BY nhanvien1; 
CREATE USER QuanLy2 IDENTIFIED BY quanly2; 
CREATE USER QuanLy3 IDENTIFIED BY quanly3; 
CREATE USER NhanVien2 IDENTIFIED BY nhanvien2; 
CREATE USER NhanVien3 IDENTIFIED BY nhanvien3; 


-- CẤP QUYỀN KẾT NỐI CHO TẤT CẢ USER 
GRANT CONNECT TO GiamDoc, QuanLy1, NhanVien1; 
GRANT CONNECT TO QuanLy2, QuanLy3, NhanVien2, NhanVien3; 

 

-- PHÂN QUYỀN CHO GIAMDOC: SELECT, INSERT, UPDATE TẤT CẢ CÁC BẢNG 
GRANT SELECT, INSERT, UPDATE ON SANPHAM TO GiamDoc; 
GRANT SELECT, INSERT, UPDATE ON TONKHO TO GiamDoc; 
GRANT SELECT, INSERT, UPDATE ON HOADON TO GiamDoc; 
GRANT SELECT, INSERT, UPDATE ON CTHD TO   GiamDoc; 
GRANT SELECT, INSERT, UPDATE ON KHACHHANG TO GiamDoc; 
GRANT SELECT, INSERT, UPDATE ON NHANVIEN_PUBLIC TO GiamDoc; 
GRANT SELECT, INSERT, UPDATE ON NHANVIEN_PRIVATE TO GiamDoc; 
GRANT SELECT, INSERT, UPDATE ON CHINHANH TO GiamDoc; 

 

-- PHÂN QUYỀN CHO QUANLY3: SELECT, INSERT, UPDATE SANPHAM, TONKHO, HOADON, CTHD, KHACHHANG; SELECT NHANVIEN_PUBLIC, NHANVIEN_PRIVATE; SELECT NHANVIEN_PUBLIC và NHANVIEN_PRIVATE 
GRANT SELECT, INSERT, UPDATE ON SANPHAM TO QuanLy3; 
GRANT SELECT, INSERT, UPDATE ON TONKHO TO QuanLy3; 
GRANT SELECT, INSERT, UPDATE ON HOADON TO QuanLy3; 
GRANT SELECT, INSERT, UPDATE ON CTHD TO QuanLy3; 
GRANT SELECT, INSERT, UPDATE ON KHACHHANG TO QuanLy3; 
GRANT SELECT ON NHANVIEN_PUBLIC TO QuanLy3; 
GRANT SELECT ON NHANVIEN_PRIVATE TO QuanLy3; 
 

-- PHÂN QUYỀN CHO NHANVIEN: SELECT, INSERT, UPDATE KHACHHANG, HOADON, CTHD; SELECT SANPHAM, TONKHO 
GRANT SELECT, INSERT, UPDATE ON KHACHHANG TO NhanVien3; 
GRANT SELECT, INSERT, UPDATE ON HOADON TO NhanVien3; 
GRANT SELECT, INSERT, UPDATE ON CTHD TO NhanVien3; 
GRANT SELECT ON SANPHAM TO NhanVien3; 
GRANT SELECT ON TONKHO TO NhanVien3; 


-- PHÂN QUYỀN CHO QUẢN LÝ CHI NHÁNH 1, 2: SELECT NHANVIEN_PUBLIC, TONKHO 
GRANT SELECT ON NHANVIEN_PUBLIC TO QuanLy1, QuanLy2; 
GRANT SELECT ON TONKHO TO QuanLy1, QuanLy2; 
 

-- PHÂN QUYỀN CHO NHÂN VIÊN CHI NHÁNH 1, 2: SELECT TONKHO 
GRANT SELECT ON TONKHO TO NhanVien1, NhanVien2; 



/*================================================================= QUERRY ===================================================================================*/
--Câu 8

SELECT MACHINHANH, SOLUONGNHANVIEN
FROM (
SELECT MACHINHANH, COUNT(MANV) AS SOLUONGNHANVIEN
FROM CN1.NHANVIEN_PUBLIC@CN1_QuanLy3
WHERE ISDELETE = 0 AND MACHINHANH = 'CN1'
GROUP BY MACHINHANH
UNION ALL
SELECT MACHINHANH, COUNT(MANV) AS SOLUONGNHANVIEN
FROM CN2.NHANVIEN_PUBLIC@CN2_QuanLy3
WHERE ISDELETE = 0 AND MACHINHANH = 'CN2'
GROUP BY MACHINHANH
UNION ALL
SELECT MACHINHANH, COUNT(MANV) AS SOLUONGNHANVIEN
FROM CN3.NHANVIEN_PUBLIC
WHERE ISDELETE = 0 AND MACHINHANH = 'CN3'
GROUP BY MACHINHANH
);

-- Câu 9
SELECT MASP, TENSANPHAM
FROM (
    SELECT T.MASP, S.TENSANPHAM 
    FROM CN1.TONKHO@CN1_NhanVien3 T
    JOIN CN1.SANPHAM@CN1_NhanVien3 S ON T.MASP = S.MASP
    WHERE T.TINHTRANG = 'Còn Hàng' AND S.ISDELETE = 0  
    INTERSECT
    SELECT T.MASP, S.TENSANPHAM
    FROM CN2.TONKHO@CN2_NhanVien3 T
    JOIN CN2.SANPHAM@CN2_NhanVien3 S ON T.MASP = S.MASP
    WHERE T.TINHTRANG = 'Còn Hàng' AND S.ISDELETE = 0
)
MINUS 
SELECT T.MASP, S.TENSANPHAM 
FROM CN3.TONKHO T
JOIN CN3.SANPHAM S ON T.MASP = S.MASP
WHERE T.TINHTRANG = 'Còn Hàng' AND S.ISDELETE = 0
GROUP BY T.MASP, S.TENSANPHAM


-- Câu 10
SELECT MASP, TENSANPHAM, SUM(SOLUONG) AS TONG_SOLUONG
FROM (
  SELECT C.MASP, S.TENSANPHAM, C.SOLUONG
  FROM CN1.CTHD@CN1_GiamDoc C
  JOIN CN1.SANPHAM@CN1_GiamDoc S ON C.MASP = S.MASP
  WHERE C.ISDELETE = 0 AND S.ISDELETE = 0
  UNION ALL
  SELECT C.MASP, S.TENSANPHAM, C.SOLUONG
  FROM CN2.CTHD@CN2_GiamDoc C
  JOIN CN2.SANPHAM@CN2_GiamDoc S ON C.MASP = S.MASP
  WHERE C.ISDELETE = 0 AND S.ISDELETE = 0
  UNION ALL
  SELECT C.MASP, S.TENSANPHAM, C.SOLUONG
  FROM CN3.CTHD C
  JOIN CN3.SANPHAM S ON C.MASP = S.MASP
  WHERE C.ISDELETE = 0 AND S.ISDELETE = 0
)
GROUP BY MASP, TENSANPHAM
ORDER BY TONG_SOLUONG DESC
FETCH FIRST 5 ROWS WITH TIES;

/*=================================================================FUNCTION - PROCEDURE - TRIGGER ===================================================================================*/
------------------------------------------------------------------ FUNCTION ------------------------------------------------------------------
--Function thống kê mua hàng khách hàng
CREATE OR REPLACE FUNCTION ThongKeMuaHangKhachHang(p_makh IN VARCHAR2)
RETURN NUMBER
IS
  v_count_cn1 NUMBER := 0;
  v_sum_cn1   NUMBER := 0;
  v_count_cn2 NUMBER := 0;
  v_sum_cn2   NUMBER := 0;
  v_count_cn3 NUMBER := 0;
  v_sum_cn3   NUMBER := 0;
  v_total_hd  NUMBER := 0;
  v_total_tien NUMBER := 0;
BEGIN
  -- CN1
  BEGIN
    SELECT COUNT(*), NVL(SUM(TONGTIEN), 0)
    INTO v_count_cn1, v_sum_cn1
    FROM CN1.HOADON@CN1_GiamDoc
    WHERE MAKH = p_makh AND ISDELETE = 0;
  EXCEPTION WHEN OTHERS THEN
    v_count_cn1 := 0;
    v_sum_cn1 := 0;
  END;
 
  -- CN2 
  BEGIN
    SELECT COUNT(*), NVL(SUM(TONGTIEN), 0)
    INTO v_count_cn2, v_sum_cn2
    FROM CN2.HOADON@CN2_GiamDoc
    WHERE MAKH = p_makh AND ISDELETE = 0;
  EXCEPTION WHEN OTHERS THEN
    v_count_cn2 := 0;
    v_sum_cn2 := 0;
  END;
 
  -- CN3 (local)
  BEGIN
    SELECT COUNT(*), NVL(SUM(TONGTIEN), 0)
    INTO v_count_cn3, v_sum_cn3
    FROM CN3.HOADON 
    WHERE MAKH = p_makh AND ISDELETE = 0;
  EXCEPTION WHEN OTHERS THEN
    v_count_cn3 := 0;
    v_sum_cn3 := 0;
  END;
  -- Tổng
  v_total_hd := v_count_cn1 + v_count_cn2 + v_count_cn3;
  v_total_tien := v_sum_cn1 + v_sum_cn2 + v_sum_cn3;
  -- In kết quả
  DBMS_OUTPUT.PUT_LINE('--- THỐNG KÊ CHO KHÁCH HÀNG: ' || p_makh || ' ---');
  DBMS_OUTPUT.PUT_LINE('CN1: ' || v_count_cn1 || ' hóa đơn - ' || TO_CHAR(v_sum_cn1, 'FM999G999G999G999G999') || ' VNĐ');
  DBMS_OUTPUT.PUT_LINE('CN2: ' || v_count_cn2 || ' hóa đơn - ' || TO_CHAR(v_sum_cn2, 'FM999G999G999') || ' VNĐ');
  DBMS_OUTPUT.PUT_LINE('CN3: ' || v_count_cn3 || ' hóa đơn - ' || TO_CHAR(v_sum_cn3, 'FM999G999G999') || ' VNĐ');
  DBMS_OUTPUT.PUT_LINE('=> TỔNG: ' || v_total_hd || ' hóa đơn - ' || TO_CHAR(v_total_tien, 'FM999G999G999G999G999') || ' VNĐ');
 
  RETURN v_total_tien;
END;
/

SET SERVEROUTPUT ON; 
DECLARE
  tong_tien NUMBER;
BEGIN
  tong_tien := ThongKeMuaHangKhachHang('KH1000');
  DBMS_OUTPUT.PUT_LINE('Tổng tiền trả về từ function: ' || TO_CHAR(tong_tien, 'FM999G999G999G999G999') || ' VNĐ');
END;
/


------------------------------------------------------------------ PROCEDURE ------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DongBoKhachHang(
  p_makh      IN VARCHAR2,
  p_hoten     IN VARCHAR2,
  p_diachi    IN VARCHAR2,
  p_sdt       IN VARCHAR2,
  p_tongtien  IN NUMBER DEFAULT 0
)
IS
  v_exists NUMBER := 0;
  v_da_ton_tai BOOLEAN := FALSE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== BẮT ĐẦU ĐỒNG BỘ KHÁCH HÀNG: ' || p_makh || ' ===');
 
  -- CN3 (local)
  BEGIN
    SELECT COUNT(*) INTO v_exists FROM KHACHHANG WHERE MAKH = p_makh;
    IF v_exists = 0 THEN
      INSERT INTO KHACHHANG(MAKH, HOTEN, DIACHI, SODIENTHOAI, TONGTIEN, ISDELETE)
      VALUES (p_makh, p_hoten, p_diachi, p_sdt, p_tongtien, 0);
      DBMS_OUTPUT.PUT_LINE('Đã thêm vào chi nhánh hiện tại (CN3)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Khách hàng đã tồn tại tại CN3');
      v_da_ton_tai := TRUE;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Lỗi khi xử lý tại CN3');
  END;
 
  -- CN1
  BEGIN
    SELECT COUNT(*) INTO v_exists FROM CN1.KHACHHANG@CN1_GiamDoc WHERE MAKH = p_makh;
    IF v_exists = 0 THEN
      INSERT INTO CN1.KHACHHANG@CN1_GiamDoc(MAKH, HOTEN, DIACHI, SODIENTHOAI, TONGTIEN, ISDELETE)
      VALUES (p_makh, p_hoten, p_diachi, p_sdt, p_tongtien, 0);
      DBMS_OUTPUT.PUT_LINE('Đồng bộ vào CN1');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Khách hàng đã tồn tại tại CN1');
      v_da_ton_tai := TRUE;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Không thể truy cập hoặc đồng bộ CN1');
  END;
 
  -- CN2
  BEGIN
    SELECT COUNT(*) INTO v_exists FROM CN2.KHACHHANG@CN2_GiamDoc WHERE MAKH = p_makh;
    IF v_exists = 0 THEN
      INSERT INTO CN2.KHACHHANG@CN2_GiamDoc(MAKH, HOTEN, DIACHI, SODIENTHOAI, TONGTIEN, ISDELETE)
      VALUES (p_makh, p_hoten, p_diachi, p_sdt, p_tongtien, 0);
      DBMS_OUTPUT.PUT_LINE('Đồng bộ vào CN2');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Khách hàng đã tồn tại tại CN2');
      v_da_ton_tai := TRUE;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Không thể truy cập hoặc đồng bộ CN2');
  END;
 
  IF v_da_ton_tai THEN
    DBMS_OUTPUT.PUT_LINE('Khách hàng đã có ở ít nhất một chi nhánh. Không ghi đè.');
  END IF;
 
  COMMIT;
END;
/

BEGIN 
  DongBoKhachHang( 
    p_makh     => 'KH1006', 
    p_hoten    => 'Nguyễn Thanh Nhàn', 
    p_diachi   => 'HCM', 
    p_sdt      => '0909009190', 
    p_tongtien => 0 
  ); 
END; 
/



------------------------------------------------------------------ TRIGGER ------------------------------------------------------------------
CREATE OR REPLACE TRIGGER check_inventory_before_selling 
BEFORE INSERT ON CTHD 
FOR EACH ROW 

DECLARE 
  v_soluong_tonkho TONKHO.SOLUONG%TYPE; 
  v_machinhanh NHANVIEN_PUBLIC.MACHINHANH%TYPE; 

BEGIN 
  SELECT MACHINHANH INTO v_machinhanh 
  FROM HOADON H JOIN NHANVIEN_PUBLIC NV ON H.MANV = NV.MANV 
  WHERE H.MAHD = :NEW.MAHD; 
  SELECT SOLUONG INTO v_soluong_tonkho 
  FROM TONKHO 
  WHERE MASP = :NEW.MASP AND MACHINHANH = v_machinhanh; 

  IF v_soluong_tonkho < :NEW.SOLUONG THEN 
    RAISE_APPLICATION_ERROR(-20001, 'Số lượng tồn kho không đủ để bán.'); 
  END IF; 

EXCEPTION 
  WHEN NO_DATA_FOUND THEN 
    RAISE_APPLICATION_ERROR(-20002, 'Không tìm thấy sản phẩm trong tồn kho tại chi nhánh.'); 
END; 

---------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER update_inventory_after_selling 
AFTER INSERT ON CTHD 
FOR EACH ROW 

DECLARE 
  v_machinhanh NHANVIEN_PUBLIC.MACHINHANH%TYPE; 

BEGIN 
  SELECT NV.MACHINHANH INTO v_machinhanh 
  FROM HOADON H 
  JOIN NHANVIEN_PUBLIC NV ON H.MANV = NV.MANV 
  WHERE H.MAHD = :NEW.MAHD; 
  UPDATE TONKHO 
  SET SOLUONG = SOLUONG - :NEW.SOLUONG, 
      TINHTRANG = CASE 
                    WHEN SOLUONG - :NEW.SOLUONG <= 0 THEN 'Hết Hàng' 
                    ELSE 'Còn Hàng' 
                  END, 
      NGAYCAPNHAT = SYSDATE 
  WHERE MASP = :NEW.MASP AND MACHINHANH = v_machinhanh; 
END;



