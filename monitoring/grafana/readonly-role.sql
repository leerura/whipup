-- Grafana가 사용자 현황 dashboard에서 쓰는 읽기 전용 DB 역할.
-- 실행: psql -U <관리자> -d <DB> -v pw="'<비밀번호>'" -f readonly-role.sql
-- users의 집계용 컬럼에만 SELECT를 준다. 쓰기와 다른 테이블 접근은 없다.
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'grafana_ro') THEN
    CREATE ROLE grafana_ro LOGIN;
  END IF;
END
$$;
ALTER ROLE grafana_ro WITH PASSWORD :pw;
GRANT CONNECT ON DATABASE whipup TO grafana_ro;
GRANT USAGE ON SCHEMA public TO grafana_ro;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM grafana_ro;
GRANT SELECT (created_at, last_active_at, onboarding_completed) ON users TO grafana_ro;
