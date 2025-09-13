CREATE SCHEMA IF NOT EXISTS users;

CREATE TABLE users.users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           TEXT UNIQUE NOT NULL,
    display_name    TEXT,
    preferences     JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_users_email ON users.users(email);

CREATE TRIGGER trg_users_updated
BEFORE UPDATE ON users.users
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();
