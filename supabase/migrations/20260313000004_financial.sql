-- ============================================================
-- MIGRATION 4 — Financial
-- Tables: payments, monthly_rent_statements, payment_disputes,
--         b2b_invoices, b2b_payments, addon_orders
-- ============================================================

-- ── 24. payments ────────────────────────────────────────────
CREATE TABLE payments (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payer_id                    UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  payment_type                TEXT NOT NULL CHECK (payment_type IN (
                                'holding_deposit',
                                'security_deposit',
                                'monthly_rent',
                                'b2b_invoice',
                                'addon',
                                'event_ticket',
                                'deposit_refund',
                                'holding_deposit_refund'
                              )),
  reference_type              TEXT CHECK (reference_type IN (
                                'booking', 'b2b_invoice',
                                'addon_order', 'event_attendee'
                              )),
  reference_id                UUID,
  amount_cents                INTEGER NOT NULL,
  currency                    TEXT NOT NULL DEFAULT 'EUR',
  stripe_payment_intent_id    TEXT UNIQUE,
  stripe_refund_id            TEXT,
  status                      TEXT NOT NULL DEFAULT 'pending'
                              CHECK (status IN (
                                'pending', 'processing', 'succeeded',
                                'failed', 'refunded',
                                'partially_refunded', 'disputed'
                              )),
  refund_amount_cents         INTEGER,
  refund_reason               TEXT,
  refunded_at                 TIMESTAMPTZ,
  payment_method              TEXT CHECK (payment_method IN (
                                'card', 'sepa_debit', 'bank_transfer'
                              )),
  description                 TEXT,
  paid_at                     TIMESTAMPTZ,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Now add payment FKs to security_deposits
ALTER TABLE security_deposits
  ADD CONSTRAINT security_deposits_payment_id_fkey
  FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE SET NULL;

ALTER TABLE security_deposits
  ADD CONSTRAINT security_deposits_refund_payment_id_fkey
  FOREIGN KEY (refund_payment_id) REFERENCES payments(id) ON DELETE SET NULL;

-- ── 25. monthly_rent_statements ─────────────────────────────
-- NOTE: b2b_partner_id FK added in migration 5
CREATE TABLE monthly_rent_statements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id      UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
  profile_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  b2b_partner_id  UUID,
  period_year     INTEGER NOT NULL,
  period_month    INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  amount_cents    INTEGER NOT NULL,
  status          TEXT NOT NULL DEFAULT 'unpaid'
                  CHECK (status IN (
                    'unpaid', 'paid', 'overdue', 'waived'
                  )),
  due_date        DATE NOT NULL,
  paid_at         TIMESTAMPTZ,
  payment_id      UUID REFERENCES payments(id) ON DELETE SET NULL,
  generated_by    TEXT NOT NULL DEFAULT 'system'
                  CHECK (generated_by IN ('system', 'manual')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (booking_id, period_year, period_month)
);

-- ── 26. payment_disputes ────────────────────────────────────
CREATE TABLE payment_disputes (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id        UUID NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
  raised_by         UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  reason            TEXT NOT NULL CHECK (reason IN (
                      'incorrect_amount',
                      'duplicate_charge',
                      'service_not_received',
                      'unauthorised_payment',
                      'other'
                    )),
  description       TEXT NOT NULL,
  evidence_urls     TEXT[],
  status            TEXT NOT NULL DEFAULT 'open'
                    CHECK (status IN (
                      'open', 'under_review',
                      'resolved_refund',
                      'resolved_no_refund',
                      'closed'
                    )),
  resolution_notes  TEXT,
  resolved_by       UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  resolved_at       TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 27. b2b_invoices ────────────────────────────────────────
-- NOTE: b2b_partner_id FK added in migration 5
CREATE TABLE b2b_invoices (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  b2b_partner_id    UUID NOT NULL,
  period_year       INTEGER NOT NULL,
  period_month      INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
  invoice_number    TEXT NOT NULL UNIQUE,
  line_items        JSONB NOT NULL DEFAULT '[]',
  subtotal_cents    INTEGER NOT NULL,
  tax_cents         INTEGER NOT NULL DEFAULT 0,
  total_cents       INTEGER NOT NULL,
  status            TEXT NOT NULL DEFAULT 'draft'
                    CHECK (status IN (
                      'draft', 'sent', 'paid', 'overdue', 'cancelled'
                    )),
  due_date          DATE NOT NULL,
  paid_at           TIMESTAMPTZ,
  invoice_pdf_url   TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 28. b2b_payments ────────────────────────────────────────
CREATE TABLE b2b_payments (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  b2b_invoice_id    UUID NOT NULL REFERENCES b2b_invoices(id) ON DELETE RESTRICT,
  payment_id        UUID NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
  amount_cents      INTEGER NOT NULL,
  payment_method    TEXT CHECK (payment_method IN (
                      'bank_transfer', 'card', 'sepa_debit'
                    )),
  bank_reference    TEXT,
  notes             TEXT,
  paid_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 29. addon_orders ────────────────────────────────────────
-- NOTE: b2b_employee_id and included_in_invoice_id FKs added in migration 5
CREATE TABLE addon_orders (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ordered_by_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  ordered_by_type           TEXT NOT NULL CHECK (ordered_by_type IN (
                              'tenant', 'b2b_contact'
                            )),
  booking_id                UUID REFERENCES bookings(id) ON DELETE SET NULL,
  b2b_employee_id           UUID,
  addon_id                  UUID NOT NULL,
  quantity                  INTEGER NOT NULL DEFAULT 1,
  unit_price_cents          INTEGER NOT NULL,
  total_cents               INTEGER NOT NULL,
  status                    TEXT NOT NULL DEFAULT 'pending'
                            CHECK (status IN (
                              'pending', 'confirmed',
                              'delivered', 'cancelled'
                            )),
  notes                     TEXT,
  payment_id                UUID REFERENCES payments(id) ON DELETE SET NULL,
  included_in_invoice_id    UUID,
  delivered_at              TIMESTAMPTZ,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TRIGGERS ────────────────────────────────────────────────
CREATE TRIGGER payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER monthly_rent_statements_updated_at
  BEFORE UPDATE ON monthly_rent_statements
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER payment_disputes_updated_at
  BEFORE UPDATE ON payment_disputes
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER b2b_invoices_updated_at
  BEFORE UPDATE ON b2b_invoices
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER addon_orders_updated_at
  BEFORE UPDATE ON addon_orders
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── pg_cron — auto generate monthly rent statements ─────────
SELECT cron.schedule('generate-rent-statements', '1 0 1 * *', $$
  INSERT INTO monthly_rent_statements
    (booking_id, profile_id, b2b_partner_id,
     period_year, period_month, amount_cents, due_date)
  SELECT
    b.id,
    b.profile_id,
    b.b2b_partner_id,
    EXTRACT(YEAR FROM NOW())::INTEGER,
    EXTRACT(MONTH FROM NOW())::INTEGER,
    b.monthly_rent_cents,
    (DATE_TRUNC('month', NOW()) + INTERVAL '7 days')::DATE
  FROM bookings b
  WHERE b.status = 'active'
  ON CONFLICT (booking_id, period_year, period_month) DO NOTHING;
$$);

-- ── RLS ──────────────────────────────────────────────────────
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_rent_statements ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_disputes ENABLE ROW LEVEL SECURITY;

-- Tenant can see their own payments
CREATE POLICY "payments_read_own"
  ON payments FOR SELECT
  USING (auth.uid() = payer_id);

-- Tenant can see their own rent statements
CREATE POLICY "statements_read_own"
  ON monthly_rent_statements FOR SELECT
  USING (auth.uid() = profile_id);

-- Tenant can see their own disputes
CREATE POLICY "disputes_read_own"
  ON payment_disputes FOR SELECT
  USING (auth.uid() = raised_by);
