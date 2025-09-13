CREATE SCHEMA IF NOT EXISTS notes;

CREATE TABLE notes.notes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users.users(id) ON DELETE CASCADE,
    stock_id        UUID REFERENCES stocks.stocks(id) ON DELETE CASCADE,
    content         TEXT NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_notes_user ON notes.notes(user_id);
CREATE INDEX idx_notes_stock ON notes.notes(stock_id);

CREATE TRIGGER trg_notes_updated
BEFORE UPDATE ON notes.notes
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- Embeddings
CREATE TABLE notes.note_embeddings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    note_id         UUID NOT NULL REFERENCES notes.notes(id) ON DELETE CASCADE,
    model           TEXT NOT NULL,
    embedding       vector(1536) NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_note_embeddings_note_id ON notes.note_embeddings(note_id);
CREATE INDEX idx_note_embeddings_model ON notes.note_embeddings(model);
CREATE INDEX idx_note_embeddings_vector ON notes.note_embeddings
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
