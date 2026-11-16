-- MySQL 8 이상. 관리자 계정으로 실행합니다.
CREATE DATABASE IF NOT EXISTS daily_route
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 비밀번호를 바꾼 뒤 실행하고 .env에도 같은 값을 입력하세요.
CREATE USER IF NOT EXISTS 'daily_route'@'localhost'
  IDENTIFIED BY 'han0902131977@';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, REFERENCES
  ON daily_route.* TO 'daily_route'@'localhost';
