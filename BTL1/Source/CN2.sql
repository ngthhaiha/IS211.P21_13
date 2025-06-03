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
 

-- PHÂN QUYỀN CHO QUANLY2 
GRANT SELECT, INSERT, UPDATE ON SANPHAM TO QuanLy2; 
GRANT SELECT, INSERT, UPDATE ON TONKHO TO QuanLy2; 
GRANT SELECT, INSERT, UPDATE ON HOADON TO QuanLy2; 
GRANT SELECT, INSERT, UPDATE ON CTHD TO QuanLy2; 
GRANT SELECT, INSERT, UPDATE ON KHACHHANG TO QuanLy2; 
GRANT SELECT ON NHANVIEN_PUBLIC TO QuanLy2; 
GRANT SELECT ON NHANVIEN_PRIVATE TO QuanLy2; 

 

-- PHÂN QUYỀN CHO NHANVIEN: SELECT, INSERT, UPDATE KHACHHANG, HOADON, CTHD; SELECT SANPHAM, TONKHO 
GRANT SELECT, INSERT, UPDATE ON KHACHHANG TO NhanVien2; 
GRANT SELECT, INSERT, UPDATE ON HOADON TO NhanVien2; 
GRANT SELECT, INSERT, UPDATE ON CTHD TO NhanVien2; 
GRANT SELECT ON SANPHAM TO NhanVien2; 
GRANT SELECT ON TONKHO TO NhanVien2; 

 

-- PHÂN QUYỀN CHO QUẢN LÝ CHI NHÁNH 1, 3: SELECT NHANVIEN_PUBLIC, TONKHO 
GRANT SELECT ON NHANVIEN_PUBLIC TO QuanLy1, QuanLy3; 
GRANT SELECT ON TONKHO TO QuanLy1, QuanLy3; 

-- PHÂN QUYỀN CHO NHÂN VIÊN CHI NHÁNH 1, 3: SELECT TONKHO 
GRANT SELECT ON TONKHO TO NhanVien1, NhanVien3; 



/*================================================================= QUERRY ===================================================================================*/
------------------------------ CAU 5 -------------------------------
SELECT   
  MASP,  
  TENSANPHAM,  
  GIABAN, 
  SUM(CASE WHEN MACHINHANH = 'CN1' THEN SOLUONG ELSE 0 END) AS CN1,  
  SUM(CASE WHEN MACHINHANH = 'CN2' THEN SOLUONG ELSE 0 END) AS CN2,  
  SUM(CASE WHEN MACHINHANH = 'CN3' THEN SOLUONG ELSE 0 END) AS CN3,  
  SUM(SOLUONG) AS TONG  
FROM (  
  SELECT T.MASP, S.TENSANPHAM, S.GIABAN, T.MACHINHANH, T.SOLUONG  
  FROM CN1.TONKHO@CN1_NhanVien2 T  
  JOIN CN1.SANPHAM@CN1_NhanVien2 S ON T.MASP = S.MASP  
  WHERE T.TINHTRANG = 'Còn Hàng'  
    AND S.DANHMUC = 'Vợt cầu lông'  
    AND S.GIABAN > 2000000 AND S.GIABAN < 3000000  
    AND S.ISDELETE = 0  

  UNION ALL  

  SELECT T.MASP, S.TENSANPHAM, S.GIABAN, T.MACHINHANH, T.SOLUONG  
  FROM CN2.TONKHO T  
  JOIN CN2.SANPHAM S ON T.MASP = S.MASP  
  WHERE T.TINHTRANG = 'Còn Hàng'  
    AND S.DANHMUC = 'Vợt cầu lông'  
    AND S.GIABAN > 2000000 AND S.GIABAN < 3000000  
    AND S.ISDELETE = 0  

  UNION ALL  

  SELECT T.MASP, S.TENSANPHAM, S.GIABAN, T.MACHINHANH, T.SOLUONG  
  FROM CN3.TONKHO@CN3_NhanVien2 T  
  JOIN CN3.SANPHAM@CN3_NhanVien2 S ON T.MASP = S.MASP  
  WHERE T.TINHTRANG = 'Còn Hàng'  
    AND S.DANHMUC = 'Vợt cầu lông'  
    AND S.GIABAN > 2000000 AND S.GIABAN < 3000000  
    AND S.ISDELETE = 0  
)  

GROUP BY MASP, TENSANPHAM, GIABAN  
ORDER BY TENSANPHAM; 


------------------------------- CAU 6 -------------------------------
SELECT KH.MAKH, KH.HOTEN, SP.MASP, SP.TENSANPHAM 
FROM CN2.KHACHHANG KH 
JOIN ( 
  SELECT MAKH 
  FROM ( 
    SELECT H.MAKH, C.MASP 
    FROM CN1.HOADON@CN1_GiamDoc H 
    JOIN CN1.CTHD@CN1_GiamDoc C ON H.MAHD = C.MAHD 
    WHERE H.ISDELETE = 0 AND C.ISDELETE = 0 
      AND C.MASP IN (SELECT MASP FROM CN2.SANPHAM WHERE THUONGHIEU = 'VNB' AND ISDELETE = 0) 
    UNION 
    SELECT H.MAKH, C.MASP 
    FROM CN2.HOADON H 
    JOIN CN2.CTHD C ON H.MAHD = C.MAHD 
    WHERE H.ISDELETE = 0 AND C.ISDELETE = 0 
      AND C.MASP IN (SELECT MASP FROM CN2.SANPHAM WHERE THUONGHIEU = 'VNB' AND ISDELETE = 0) 
    UNION 
    SELECT H.MAKH, C.MASP 
    FROM CN3.HOADON@CN3_GiamDoc H 
    JOIN CN3.CTHD@CN3_GiamDoc C ON H.MAHD = C.MAHD 
    WHERE H.ISDELETE = 0 AND C.ISDELETE = 0 
      AND C.MASP IN (SELECT MASP FROM CN2.SANPHAM WHERE THUONGHIEU = 'VNB' AND ISDELETE = 0) 
  ) 
  GROUP BY MAKH 
  HAVING COUNT(DISTINCT MASP) = (SELECT COUNT(*) FROM CN2.SANPHAM WHERE THUONGHIEU = 'VNB' AND ISDELETE = 0) 
) KD ON KH.MAKH = KD.MAKH 
JOIN CN2.SANPHAM SP ON SP.THUONGHIEU = 'VNB' AND SP.ISDELETE = 0 
ORDER BY KH.MAKH, SP.MASP; 



------------------------------- CAU 7 -------------------------------
WITH DOANHTHU AS ( 
  SELECT 'CN1' AS MACHINHANH, 'FULL' AS KY, SUM(TONGTIEN) AS DOANHTHU 
  FROM CN1.HOADON@CN1_GiamDoc 
  WHERE EXTRACT(YEAR FROM NGAYTAO) = 2024 AND ISDELETE = 0 

  UNION ALL 

  SELECT 'CN2' AS MACHINHANH, 'FULL', SUM(TONGTIEN) 
  FROM CN2.HOADON 
  WHERE EXTRACT(YEAR FROM NGAYTAO) = 2024 AND ISDELETE = 0 

  UNION ALL 

  SELECT 'CN3' AS MACHINHANH, 'FULL', SUM(TONGTIEN) 
  FROM CN3.HOADON@CN3_GiamDoc 
  WHERE EXTRACT(YEAR FROM NGAYTAO) = 2024 AND ISDELETE = 0 

  UNION ALL

  SELECT 'CN1' AS MACHINHANH, 'FIRST6', SUM(TONGTIEN) 
  FROM CN1.HOADON@CN1_GiamDoc 
  WHERE EXTRACT(YEAR FROM NGAYTAO) = 2024 AND EXTRACT(MONTH FROM NGAYTAO) BETWEEN 1 AND 6 AND ISDELETE = 0 

  UNION ALL 

  SELECT 'CN2' AS MACHINHANH, 'FIRST6', SUM(TONGTIEN) 
  FROM CN2.HOADON 
  WHERE EXTRACT(YEAR FROM NGAYTAO) = 2024 AND EXTRACT(MONTH FROM NGAYTAO) BETWEEN 1 AND 6 AND ISDELETE = 0 

  UNION ALL 

  SELECT 'CN3' AS MACHINHANH, 'FIRST6', SUM(TONGTIEN) 
  FROM CN3.HOADON@CN3_GiamDoc 
  WHERE EXTRACT(YEAR FROM NGAYTAO) = 2024 AND EXTRACT(MONTH FROM NGAYTAO) BETWEEN 1 AND 6 AND ISDELETE = 0 
) 

 

SELECT MACHINHANH, 
       MAX(CASE WHEN KY = 'FULL' THEN DOANHTHU ELSE 0 END) AS DOANHTHU_NAM, 
       MAX(CASE WHEN KY = 'FIRST6' THEN DOANHTHU ELSE 0 END) AS DOANHTHU_6THANG, 
       MAX(CASE WHEN KY = 'FULL' THEN DOANHTHU ELSE 0 END) - 
       MAX(CASE WHEN KY = 'FIRST6' THEN DOANHTHU ELSE 0 END) AS TANGTRUONG 
FROM DOANHTHU 
GROUP BY MACHINHANH 
ORDER BY TANGTRUONG DESC 
FETCH FIRST 1 ROW ONLY; 
 

/*=================================================================FUNCTION - PROCEDURE - TRIGGER ===================================================================================*/
------------------------------------------------------------------ FUNCTION ------------------------------------------------------------------
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


  -- CN2 (local) 
  BEGIN 
    SELECT COUNT(*), NVL(SUM(TONGTIEN), 0) 
    INTO v_count_cn2, v_sum_cn2 
    FROM HOADON 
    WHERE MAKH = p_makh AND ISDELETE = 0; 

  EXCEPTION WHEN OTHERS THEN 
    v_count_cn2 := 0; 
    v_sum_cn2 := 0; 
  END; 

  
  -- CN3 
  BEGIN 
    SELECT COUNT(*), NVL(SUM(TONGTIEN), 0) 
    INTO v_count_cn3, v_sum_cn3 
    FROM CN3.HOADON@CN3_GiamDoc 
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

DECLARE 
  tong_tien NUMBER; 

BEGIN 
  tong_tien := ThongKeMuaHangKhachHang('KH0001'); 
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

  -- CN2 (local) 
  BEGIN
    SELECT COUNT(*) INTO v_exists FROM KHACHHANG WHERE MAKH = p_makh; 
    IF v_exists = 0 THEN 
      INSERT INTO KHACHHANG(MAKH, HOTEN, DIACHI, SODIENTHOAI, TONGTIEN, ISDELETE) 
      VALUES (p_makh, p_hoten, p_diachi, p_sdt, p_tongtien, 0); 
      DBMS_OUTPUT.PUT_LINE('Đã thêm vào chi nhánh hiện tại (CN2)'); 

    ELSE 
      DBMS_OUTPUT.PUT_LINE('Khách hàng đã tồn tại tại CN2'); 
      v_da_ton_tai := TRUE; 
    END IF; 

  EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Lỗi khi xử lý tại CN2'); 
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


  -- CN3 
  BEGIN 
    SELECT COUNT(*) INTO v_exists FROM CN3.KHACHHANG@CN3_GiamDoc WHERE MAKH = p_makh; 
    IF v_exists = 0 THEN 
      INSERT INTO CN3.KHACHHANG@CN3_GiamDoc(MAKH, HOTEN, DIACHI, SODIENTHOAI, TONGTIEN, ISDELETE) 
      VALUES (p_makh, p_hoten, p_diachi, p_sdt, p_tongtien, 0); 
      DBMS_OUTPUT.PUT_LINE('Đồng bộ vào CN3'); 

    ELSE 
      DBMS_OUTPUT.PUT_LINE('Khách hàng đã tồn tại tại CN3'); 
      v_da_ton_tai := TRUE; 
    END IF; 

  EXCEPTION WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Không thể truy cập hoặc đồng bộ CN3'); 
  END; 

  IF v_da_ton_tai THEN 
    DBMS_OUTPUT.PUT_LINE('Khách hàng đã có ở ít nhất một chi nhánh. Không ghi đè.'); 
  END IF;

  COMMIT; 
END; 
/ 

 
BEGIN  
  DongBoKhachHang(  
    p_makh     => 'KH1004',  
    p_hoten    => 'Nguyễn Thanh Bảo',  
    p_diachi   => 'HCM',  
    p_sdt      => '0909009090',  
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



