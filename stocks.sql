CREATE SCHEMA IF NOT EXISTS stocks;

CREATE TABLE stocks.stocks (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticker          TEXT NOT NULL,
    company_name    TEXT NOT NULL,
    sector          TEXT,
    industry        TEXT,
    exchange        TEXT NOT NULL,
    isin            TEXT UNIQUE,
    status          TEXT DEFAULT 'listed' CHECK (status IN ('listed','delisted','suspended')),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now(),
    UNIQUE(exchange, ticker)
);

CREATE INDEX idx_stocks_ticker ON stocks.stocks(ticker);
CREATE INDEX idx_stocks_exchange_ticker ON stocks.stocks(exchange, ticker);

CREATE TRIGGER trg_stocks_updated
BEFORE UPDATE ON stocks.stocks
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- Embeddings
CREATE TABLE stocks.stock_embeddings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stock_id        UUID NOT NULL REFERENCES stocks.stocks(id) ON DELETE CASCADE,
    model           TEXT NOT NULL,
    embedding       vector(1536) NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_stock_embeddings_stock_id ON stocks.stock_embeddings(stock_id);
CREATE INDEX idx_stock_embeddings_model ON stocks.stock_embeddings(model);
CREATE INDEX idx_stock_embeddings_vector ON stocks.stock_embeddings
    USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
