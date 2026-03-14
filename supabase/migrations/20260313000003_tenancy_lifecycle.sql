-- ============================================================
-- MIGRATION 3 — Tenancy Lifecycle
-- Tables: enquiries, applications, application_documents,
--         application_notes, bookings, rental_agreements,
--         unit_holds, security_deposits,
--         move_in_records, move_out_records
-- ============================================================

-- ── 14. enquiries ───────────────────────────────────────────
-- NOTE: b2b_employee_id FK added in migration 5
--       converted_to_application_id FK added after applications
CREATE TABLE enquiries (
  id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id                      UUID REFERENCES profiles(id) ON DELETE SET NULL,
  name                            TEXT NOT NULL,
  email                           TEXT NOT NULL,
  phone                           TEXT,
  city                            TEXT,
  move_in_date                    DATE,
  budget_min_cents                INTEGER,
  budget_max_cents                INTEGER,
  tenant_type                     TEXT CHECK (tenant_type IN (
                                    'professional', 'azubi', 'student'
                                  )),
  message                         TEXT,
  source                          TEXT NOT NULL CHECK (source IN (
                                    'website_form', 'chatbot', 'b2b_referral',
                                    'phone', 'email', 'other'
                                  )),
  b2b_employee_id                 UUID,
  status                          TEXT NOT NULL DEFAULT 'new'
                                  CHECK (status IN (
                                    'new', 'contacted', 'converted', 'closed'
                                  )),
  converted_to_application_id     UUID,
  created_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 15. applications ────────────────────────────────────────
CREATE TABLE applications (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  b2b_employee_id   UUID,
  unit_id           UUID REFERENCES units(id) ON DELETE RESTRICT,
  preferred_unit_id UUID REFERENCES units(id) ON DELETE SET NULL,
  tenant_type       TEXT NOT NULL CHECK (tenant_type IN (
                      'professional', 'azubi', 'student'
                    )),
  move_in_date      DATE NOT NULL,
  move_out_date     DATE NOT NULL,
  occupants         INTEGER NOT NULL DEFAULT 1
                    CHECK (occupants BETWEEN 1 AND 6),
  source            TEXT NOT NULL DEFAULT 'b2c'
                    CHECK (source IN ('b2c', 'b2b')),
  status            TEXT NOT NULL DEFAULT 'pending_payment'
                    CHECK (status IN (
                      'pending_payment',
                      'pending_profile',
                      'pending_signature',
                      'pending_approval',
                      'under_review',
                      'approved',
                      'rejected',
                      'withdrawn',
                      'cancelled'
                    )),
  rejection_reason  TEXT,
  rejected_by       UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  rejected_at       TIMESTAMPTZ,
  enquiry_id        UUID REFERENCES enquiries(id) ON DELETE SET NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Now add the FK from enquiries back to applications
ALTER TABLE enquiries
  ADD CONSTRAINT enquiries_converted_to_application_id_fkey
  FOREIGN KEY (converted_to_application_id)
  REFERENCES applications(id) ON DELETE SET NULL;

-- ── 16. application_documents ───────────────────────────────
CREATE TABLE application_documents (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id    UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  document_type     TEXT NOT NULL CHECK (document_type IN (
                      'passport',
                      'national_id',
                      'residence_permit',
                      'employment_contract',
                      'payslip',
                      'work_visa',
                      'ausbildungsvertrag',
                      'azubi_stipend_proof',
                      'student_visa',
                      'enrollment_letter',
                      'financial_support_proof'
                    )),
  storage_path      TEXT NOT NULL,
  file_name         TEXT NOT NULL,
  file_size_bytes   INTEGER,
  mime_type         TEXT,
  is_verified       BOOLEAN NOT NULL DEFAULT FALSE,
  verified_by       UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  verified_at       TIMESTAMPTZ,
  rejection_reason  TEXT,
  expires_at        DATE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 17. application_notes ───────────────────────────────────
CREATE TABLE application_notes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id  UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
  admin_id        UUID NOT NULL REFERENCES admin_profiles(id) ON DELETE RESTRICT,
  note            TEXT NOT NULL,
  is_flagged      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 18. bookings ────────────────────────────────────────────
CREATE TABLE bookings (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id          UUID NOT NULL REFERENCES applications(id) ON DELETE RESTRICT,
  profile_id              UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  unit_id                 UUID NOT NULL REFERENCES units(id) ON DELETE RESTRICT,
  b2b_partner_id          UUID,
  move_in_date            DATE NOT NULL,
  move_out_date           DATE NOT NULL,
  monthly_rent_cents      INTEGER NOT NULL,
  security_deposit_cents  INTEGER NOT NULL,
  holding_deposit_cents   INTEGER NOT NULL,
  rent_payer              TEXT NOT NULL DEFAULT 'tenant'
                          CHECK (rent_payer IN ('tenant', 'b2b')),
  status                  TEXT NOT NULL DEFAULT 'pending_signature'
                          CHECK (status IN (
                            'pending_signature',
                            'pending_payment',
                            'confirmed',
                            'active',
                            'completed',
                            'cancelled'
                          )),
  cancelled_at            TIMESTAMPTZ,
  cancellation_reason     TEXT,
  cancelled_by            UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Now add the FK from unit_availability to bookings
ALTER TABLE unit_availability
  ADD CONSTRAINT unit_availability_booking_id_fkey
  FOREIGN KEY (booking_id)
  REFERENCES bookings(id) ON DELETE SET NULL;

-- ── 19. rental_agreements ───────────────────────────────────
CREATE TABLE rental_agreements (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id            UUID NOT NULL UNIQUE REFERENCES bookings(id) ON DELETE RESTRICT,
  docusign_envelope_id  TEXT UNIQUE,
  document_url          TEXT,
  status                TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN (
                          'pending',
                          'sent',
                          'tenant_signed',
                          'completed',
                          'voided',
                          'declined'
                        )),
  sent_at               TIMESTAMPTZ,
  tenant_signed_at      TIMESTAMPTZ,
  arrivio_signed_at     TIMESTAMPTZ,
  countersigned_by      UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 20. unit_holds ──────────────────────────────────────────
CREATE TABLE unit_holds (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id         UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
  profile_id      UUID REFERENCES profiles(id) ON DELETE CASCADE,
  session_token   TEXT,
  status          TEXT NOT NULL DEFAULT 'active'
                  CHECK (status IN (
                    'active', 'expired', 'converted_to_booking'
                  )),
  expires_at      TIMESTAMPTZ NOT NULL
                  DEFAULT (NOW() + INTERVAL '2 hours'),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 21. security_deposits ───────────────────────────────────
-- NOTE: payment_id FKs added in migration 4 after payments table
CREATE TABLE security_deposits (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id          UUID NOT NULL UNIQUE REFERENCES bookings(id) ON DELETE RESTRICT,
  amount_cents        INTEGER NOT NULL,
  deduction_cents     INTEGER NOT NULL DEFAULT 0,
  refund_cents        INTEGER,
  status              TEXT NOT NULL DEFAULT 'pending'
                      CHECK (status IN (
                        'pending', 'held', 'released', 'forfeited'
                      )),
  payment_id          UUID,
  refund_payment_id   UUID,
  deduction_reason    TEXT,
  paid_at             TIMESTAMPTZ,
  released_at         TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 22. move_in_records ─────────────────────────────────────
CREATE TABLE move_in_records (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id            UUID NOT NULL UNIQUE REFERENCES bookings(id) ON DELETE RESTRICT,
  keys_handed_over      BOOLEAN NOT NULL DEFAULT FALSE,
  welcome_pack_given    BOOLEAN NOT NULL DEFAULT FALSE,
  unit_condition_ok     BOOLEAN NOT NULL DEFAULT FALSE,
  condition_photo_urls  TEXT[],
  notes                 TEXT,
  processed_by          UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  moved_in_at           TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 23. move_out_records ────────────────────────────────────
CREATE TABLE move_out_records (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id            UUID NOT NULL UNIQUE REFERENCES bookings(id) ON DELETE RESTRICT,
  inspection_passed     BOOLEAN NOT NULL DEFAULT FALSE,
  damage_found          BOOLEAN NOT NULL DEFAULT FALSE,
  damage_description    TEXT,
  condition_photo_urls  TEXT[],
  deduction_approved    BOOLEAN NOT NULL DEFAULT FALSE,
  deduction_cents       INTEGER NOT NULL DEFAULT 0,
  deduction_reason      TEXT,
  keys_returned         BOOLEAN NOT NULL DEFAULT FALSE,
  processed_by          UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  moved_out_at          TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TRIGGERS ────────────────────────────────────────────────
CREATE TRIGGER enquiries_updated_at
  BEFORE UPDATE ON enquiries
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER applications_updated_at
  BEFORE UPDATE ON applications
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER application_documents_updated_at
  BEFORE UPDATE ON application_documents
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER bookings_updated_at
  BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER rental_agreements_updated_at
  BEFORE UPDATE ON rental_agreements
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER security_deposits_updated_at
  BEFORE UPDATE ON security_deposits
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER move_in_records_updated_at
  BEFORE UPDATE ON move_in_records
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER move_out_records_updated_at
  BEFORE UPDATE ON move_out_records
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── pg_cron — auto expire unit holds ────────────────────────
SELECT cron.schedule('release-expired-holds', '*/15 * * * *', $$
  UPDATE unit_holds
  SET status = 'expired'
  WHERE status = 'active'
    AND expires_at < NOW();
$$);

-- ── RLS ──────────────────────────────────────────────────────
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE application_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental_agreements ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_holds ENABLE ROW LEVEL SECURITY;

-- Tenant can see their own applications
CREATE POLICY "applications_read_own"
  ON applications FOR SELECT
  USING (auth.uid() = profile_id);

-- Tenant can see their own documents
CREATE POLICY "documents_read_own"
  ON application_documents FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM applications a
      WHERE a.id = application_id
        AND a.profile_id = auth.uid()
    )
  );

-- Tenant can see their own bookings
CREATE POLICY "bookings_read_own"
  ON bookings FOR SELECT
  USING (auth.uid() = profile_id);

-- Tenant can see their own rental agreements
CREATE POLICY "rental_agreements_read_own"
  ON rental_agreements FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = booking_id
        AND b.profile_id = auth.uid()
    )
  );
