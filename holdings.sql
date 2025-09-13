CREATE SCHEMA IF NOT EXISTS holdings;

CREATE TABLE holdings.holdings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users.users(id) ON DELETE CASCADE,
    stock_id        UUID NOT NULL REFERENCES stocks.stocks(id) ON DELETE CASCADE,
    shares          NUMERIC(20,6) NOT NULL DEFAULT 0,
    cost_basis      NUMERIC(20,6),
    purchase_date   DATE,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, stock_id)
);

CREATE INDEX idx_holdings_user ON holdings.holdings(user_id);
CREATE INDEX idx_holdings_stock ON holdings.holdings(stock_id);

CREATE TRIGGER trg_holdings_updated
BEFORE UPDATE ON holdings.holdings
FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();
