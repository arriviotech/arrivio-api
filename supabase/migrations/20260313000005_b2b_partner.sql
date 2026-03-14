-- ============================================================
-- MIGRATION 5 — B2B Partner
-- Tables: b2b_partners, b2b_contacts, b2b_employees,
--         b2b_partner_properties, addon_catalogue,
--         b2b_notifications, b2b_lead_requests
-- Also: wires up all deferred FKs from migrations 3 and 4
-- ============================================================

-- ── 30. b2b_partners ────────────────────────────────────────
CREATE TABLE b2b_partners (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name        TEXT NOT NULL,
  legal_name          TEXT NOT NULL,
  partner_type        TEXT NOT NULL CHECK (partner_type IN (
                        'employer', 'university', 'agency'
                      )),
  vat_id              TEXT,
  billing_email       TEXT NOT NULL,
  billing_address     TEXT,
  contract_signed_at  DATE,
  contract_pdf_url    TEXT,
  pricing_tier        TEXT NOT NULL DEFAULT 'standard'
                      CHECK (pricing_tier IN (
                        'standard', 'premium', 'enterprise'
                      )),
  discount_pct        NUMERIC(5,2) NOT NULL DEFAULT 0,
  account_manager_id  UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  status              TEXT NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active', 'suspended', 'churned')),
  deleted_at          TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 31. b2b_contacts ────────────────────────────────────────
CREATE TABLE b2b_contacts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  b2b_partner_id  UUID NOT NULL REFERENCES b2b_partners(id) ON DELETE CASCADE,
  profile_id      UUID REFERENCES profiles(id) ON DELETE SET NULL,
  full_name       TEXT NOT NULL,
  email           TEXT NOT NULL UNIQUE,
  phone           TEXT,
  job_title       TEXT,
  contact_role    TEXT NOT NULL DEFAULT 'primary'
                  CHECK (contact_role IN ('primary', 'finance', 'viewer')),
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 32. b2b_employees ───────────────────────────────────────
CREATE TABLE b2b_employees (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  b2b_partner_id            UUID NOT NULL REFERENCES b2b_partners(id) ON DELETE CASCADE,
  profile_id                UUID REFERENCES profiles(id) ON DELETE SET NULL,
  invited_email             TEXT NOT NULL,
  invite_token              TEXT UNIQUE,
  invite_token_expires_at   TIMESTAMPTZ,
  invite_status             TEXT NOT NULL DEFAULT 'invited'
                            CHECK (invite_status IN (
                              'invited',
                              'profile_complete',
                              'unit_selected',
                              'application_submitted',
                              'housed',
                              'departed'
                            )),
  full_name                 TEXT NOT NULL,
  job_title                 TEXT,
  accommodation_tier        TEXT NOT NULL DEFAULT 'standard'
                            CHECK (accommodation_tier IN (
                              'standard', 'premium', 'executive'
                            )),
  required_move_in_by       DATE,
  preferred_unit_id         UUID REFERENCES units(id) ON DELETE SET NULL,
  created_by                UUID REFERENCES b2b_contacts(id) ON DELETE SET NULL,
  deleted_at                TIMESTAMPTZ,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 33. b2b_partner_properties ──────────────────────────────
CREATE TABLE b2b_partner_properties (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  b2b_partner_id          UUID NOT NULL REFERENCES b2b_partners(id) ON DELETE CASCADE,
  property_id             UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  standard_allocation     INTEGER NOT NULL DEFAULT 0,
  premium_allocation      INTEGER NOT NULL DEFAULT 0,
  executive_allocation    INTEGER NOT NULL DEFAULT 0,
  notes                   TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (b2b_partner_id, property_id)
);

-- ── 34. addon_catalogue ─────────────────────────────────────
CREATE TABLE addon_catalogue (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL UNIQUE,
  description     TEXT,
  category        TEXT NOT NULL CHECK (category IN (
                    'transport', 'furniture', 'cleaning',
                    'laundry', 'wellness', 'other'
                  )),
  price_cents     INTEGER NOT NULL,
  available_for   TEXT[] NOT NULL DEFAULT ARRAY['b2b','b2c'],
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  display_order   INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 35. b2b_notifications ───────────────────────────────────
CREATE TABLE b2b_notifications (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  b2b_partner_id    UUID NOT NULL REFERENCES b2b_partners(id) ON DELETE CASCADE,
  b2b_contact_id    UUID REFERENCES b2b_contacts(id) ON DELETE CASCADE,
  type              TEXT NOT NULL CHECK (type IN (
                      'employee_invited',
                      'employee_approved',
                      'employee_rejected',
                      'employee_moved_in',
                      'employee_moved_out',
                      'invoice_ready',
                      'invoice_overdue',
                      'document_requested',
                      'customisation_complete',
                      'property_milestone'
                    )),
  title             TEXT NOT NULL,
  body              TEXT NOT NULL,
  reference_type    TEXT CHECK (reference_type IN (
                      'b2b_employee', 'b2b_invoice',
                      'property_progress_milestone',
                      'unit_customisation_request'
                    )),
  reference_id      UUID,
  is_read           BOOLEAN NOT NULL DEFAULT FALSE,
  read_at           TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 36. b2b_lead_requests ───────────────────────────────────
CREATE TABLE b2b_lead_requests (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name              TEXT NOT NULL,
  partner_type              TEXT CHECK (partner_type IN (
                              'employer', 'university', 'agency'
                            )),
  contact_name              TEXT NOT NULL,
  contact_email             TEXT NOT NULL,
  contact_phone             TEXT,
  employee_count            INTEGER,
  move_in_timeframe         TEXT,
  cities_needed             TEXT[],
  message                   TEXT,
  status                    TEXT NOT NULL DEFAULT 'new'
                            CHECK (status IN (
                              'new', 'contacted',
                              'meeting_scheduled',
                              'proposal_sent',
                              'deal_closed',
                              'rejected'
                            )),
  assigned_to               UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  next_follow_up_date       DATE,
  notes                     TEXT,
  converted_to_partner_id   UUID REFERENCES b2b_partners(id) ON DELETE SET NULL,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── WIRE UP DEFERRED FKs ────────────────────────────────────

-- bookings → b2b_partners
ALTER TABLE bookings
  ADD CONSTRAINT bookings_b2b_partner_id_fkey
  FOREIGN KEY (b2b_partner_id) REFERENCES b2b_partners(id) ON DELETE SET NULL;

-- monthly_rent_statements → b2b_partners
ALTER TABLE monthly_rent_statements
  ADD CONSTRAINT monthly_rent_statements_b2b_partner_id_fkey
  FOREIGN KEY (b2b_partner_id) REFERENCES b2b_partners(id) ON DELETE SET NULL;

-- b2b_invoices → b2b_partners
ALTER TABLE b2b_invoices
  ADD CONSTRAINT b2b_invoices_b2b_partner_id_fkey
  FOREIGN KEY (b2b_partner_id) REFERENCES b2b_partners(id) ON DELETE RESTRICT;

-- applications → b2b_employees
ALTER TABLE applications
  ADD CONSTRAINT applications_b2b_employee_id_fkey
  FOREIGN KEY (b2b_employee_id) REFERENCES b2b_employees(id) ON DELETE SET NULL;

-- enquiries → b2b_employees
ALTER TABLE enquiries
  ADD CONSTRAINT enquiries_b2b_employee_id_fkey
  FOREIGN KEY (b2b_employee_id) REFERENCES b2b_employees(id) ON DELETE SET NULL;

-- addon_orders → addon_catalogue
ALTER TABLE addon_orders
  ADD CONSTRAINT addon_orders_addon_id_fkey
  FOREIGN KEY (addon_id) REFERENCES addon_catalogue(id) ON DELETE RESTRICT;

-- addon_orders → b2b_employees
ALTER TABLE addon_orders
  ADD CONSTRAINT addon_orders_b2b_employee_id_fkey
  FOREIGN KEY (b2b_employee_id) REFERENCES b2b_employees(id) ON DELETE SET NULL;

-- addon_orders → b2b_invoices
ALTER TABLE addon_orders
  ADD CONSTRAINT addon_orders_included_in_invoice_id_fkey
  FOREIGN KEY (included_in_invoice_id) REFERENCES b2b_invoices(id) ON DELETE SET NULL;

-- ── TRIGGERS ────────────────────────────────────────────────
CREATE TRIGGER b2b_partners_updated_at
  BEFORE UPDATE ON b2b_partners
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER b2b_contacts_updated_at
  BEFORE UPDATE ON b2b_contacts
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER b2b_employees_updated_at
  BEFORE UPDATE ON b2b_employees
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER b2b_partner_properties_updated_at
  BEFORE UPDATE ON b2b_partner_properties
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER addon_catalogue_updated_at
  BEFORE UPDATE ON addon_catalogue
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER b2b_lead_requests_updated_at
  BEFORE UPDATE ON b2b_lead_requests
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── RLS ──────────────────────────────────────────────────────
ALTER TABLE b2b_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE addon_catalogue ENABLE ROW LEVEL SECURITY;

-- Anyone can read addon catalogue
CREATE POLICY "addon_catalogue_public_read"
  ON addon_catalogue FOR SELECT
  USING (is_active = TRUE);

-- B2B contact can read their own company
CREATE POLICY "b2b_partners_read_own"
  ON b2b_partners FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_contacts bc
      WHERE bc.b2b_partner_id = b2b_partners.id
        AND bc.profile_id = auth.uid()
    )
  );

-- B2B contact can read their company's employees
CREATE POLICY "b2b_employees_read_own_company"
  ON b2b_employees FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_contacts bc
      WHERE bc.b2b_partner_id = b2b_employees.b2b_partner_id
        AND bc.profile_id = auth.uid()
    )
  );

-- B2B contact can read their notifications
CREATE POLICY "b2b_notifications_read_own"
  ON b2b_notifications FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_contacts bc
      WHERE bc.b2b_partner_id = b2b_notifications.b2b_partner_id
        AND bc.profile_id = auth.uid()
    )
  );

-- ── SEED — addon catalogue ───────────────────────────────────
INSERT INTO addon_catalogue (name, description, category, price_cents, available_for, display_order) VALUES
  ('Airport Pickup',      'Private transfer from any Berlin airport',    'transport',  8900,  ARRAY['b2b','b2c'], 1),
  ('Airport Drop-off',    'Private transfer to any Berlin airport',      'transport',  8900,  ARRAY['b2b','b2c'], 2),
  ('Furniture Upgrade',   'Premium mattress, ergonomic chair, desk lamp','furniture',  15000, ARRAY['b2b','b2c'], 3),
  ('Standing Desk',       'Height-adjustable standing desk',             'furniture',  12000, ARRAY['b2b'],       4),
  ('Weekly Cleaning',     'Professional clean every week',               'cleaning',   6000,  ARRAY['b2b','b2c'], 5),
  ('Deep Clean',          'One-time thorough deep clean',                'cleaning',   9500,  ARRAY['b2b','b2c'], 6),
  ('Laundry Bundle 10x',  '10 laundry credits',                          'laundry',    2500,  ARRAY['b2b','b2c'], 7),
  ('Laundry Bundle 30x',  '30 laundry credits',                          'laundry',    6500,  ARRAY['b2b','b2c'], 8),
  ('Gym Membership 1mo',  'Access to partner gym for 1 month',           'wellness',   4500,  ARRAY['b2b','b2c'], 9),
  ('Yoga Class Pack 5x',  '5 yoga classes at partner studio',            'wellness',   7500,  ARRAY['b2b','b2c'], 10);
