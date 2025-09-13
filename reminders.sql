CREATE SCHEMA IF NOT EXISTS reminders;

CREATE TABLE reminders.reminders (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users.users(id) ON DELETE CASCADE,
    stock_id        UUID REFERENCES stocks.stocks(id) ON DELETE CASCADE,
    title           TEXT NOT NULL,
    remind_at       TIMESTAMPTZ NOT NULL,
    status          TEXT DEFAULT 'pending' CHECK (status IN ('pending','done','dismissed')),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_reminders_user ON reminders.reminders(user_id);
CREATE INDEX idx_reminders_stock ON reminders.reminders(stock_id);
CREATE INDEX idx_reminders_due ON reminders.reminders(remind_at);

CREATE TRIGGER trg_reminders_updated
BEFORE UPDATE ON reminders.reminders
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- Embeddings
CREATE TABLE reminders.reminder_embeddings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reminder_id     UUID NOT NULL REFERENCES reminders.reminders(id) ON DELETE CASCADE,
    model           TEXT NOT NULL,
    embedding       vector(1536) NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_reminder_embeddings_reminder_id ON reminders.reminder_embeddings(reminder_id);
CREATE INDEX idx_reminder_embeddings_model ON reminders.reminder_embeddings(model);
CREATE INDEX idx_reminder_embeddings_vector ON reminders.reminder_embeddings
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
