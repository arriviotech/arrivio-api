-- ============================================================
-- MIGRATION 1 — Identity & Access
-- Tables: profiles, admin_profiles, admin_permissions,
--         audit_logs, user_sessions
-- ============================================================

-- ── 1. profiles ─────────────────────────────────────────────
CREATE TABLE profiles (
  id                  UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role                TEXT NOT NULL CHECK (role IN ('tenant', 'b2b_contact', 'outside_host')),
  full_name           TEXT NOT NULL,
  preferred_name      TEXT,
  email               TEXT NOT NULL UNIQUE,
  phone               TEXT,
  phone_verified      BOOLEAN NOT NULL DEFAULT FALSE,
  avatar_url          TEXT,
  date_of_birth       DATE,
  nationality         TEXT,
  language            TEXT NOT NULL DEFAULT 'en',
  status              TEXT NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active', 'suspended', 'deleted')),
  onboarding_complete BOOLEAN NOT NULL DEFAULT FALSE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 2. admin_profiles ───────────────────────────────────────
CREATE TABLE admin_profiles (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name       TEXT NOT NULL,
  email           TEXT NOT NULL UNIQUE,
  avatar_url      TEXT,
  role            TEXT NOT NULL CHECK (role IN (
                    'super_admin', 'ops', 'finance',
                    'support', 'property_manager'
                  )),
  status          TEXT NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active', 'suspended', 'deactivated')),
  last_login_at   TIMESTAMPTZ,
  last_login_ip   TEXT,
  created_by      UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 3. admin_permissions ────────────────────────────────────
CREATE TABLE admin_permissions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role        TEXT NOT NULL CHECK (role IN (
                'super_admin', 'ops', 'finance',
                'support', 'property_manager'
              )),
  resource    TEXT NOT NULL,
  can_view    BOOLEAN NOT NULL DEFAULT FALSE,
  can_create  BOOLEAN NOT NULL DEFAULT FALSE,
  can_edit    BOOLEAN NOT NULL DEFAULT FALSE,
  can_delete  BOOLEAN NOT NULL DEFAULT FALSE,
  can_approve BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (role, resource)
);

-- ── 4. audit_logs ───────────────────────────────────────────
CREATE TABLE audit_logs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id      UUID NOT NULL REFERENCES admin_profiles(id) ON DELETE RESTRICT,
  action        TEXT NOT NULL,
  target_table  TEXT NOT NULL,
  target_id     UUID,
  old_value     JSONB,
  new_value     JSONB,
  ip_address    TEXT,
  user_agent    TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert-only enforcement on audit_logs
CREATE RULE no_update_audit_logs AS
  ON UPDATE TO audit_logs DO INSTEAD NOTHING;
CREATE RULE no_delete_audit_logs AS
  ON DELETE TO audit_logs DO INSTEAD NOTHING;

-- ── 5. user_sessions ────────────────────────────────────────
CREATE TABLE user_sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  session_token   TEXT NOT NULL UNIQUE,
  device_type     TEXT CHECK (device_type IN ('mobile', 'desktop', 'tablet')),
  browser         TEXT,
  ip_address      TEXT,
  country         TEXT,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  last_active_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at      TIMESTAMPTZ NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TRIGGERS — updated_at ────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER admin_profiles_updated_at
  BEFORE UPDATE ON admin_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER admin_permissions_updated_at
  BEFORE UPDATE ON admin_permissions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── RLS ──────────────────────────────────────────────────────
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- User can read and update their own profile
CREATE POLICY "profiles_read_own"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- User can read their own sessions
CREATE POLICY "sessions_read_own"
  ON user_sessions FOR SELECT
  USING (auth.uid() = profile_id);

-- ── SEED — default admin permissions ─────────────────────────
INSERT INTO admin_permissions (role, resource, can_view, can_create, can_edit, can_delete, can_approve) VALUES
  ('super_admin', 'applications',  TRUE, TRUE,  TRUE,  TRUE,  TRUE),
  ('super_admin', 'bookings',      TRUE, TRUE,  TRUE,  TRUE,  TRUE),
  ('super_admin', 'properties',    TRUE, TRUE,  TRUE,  TRUE,  FALSE),
  ('super_admin', 'payments',      TRUE, TRUE,  TRUE,  TRUE,  FALSE),
  ('super_admin', 'b2b_partners',  TRUE, TRUE,  TRUE,  TRUE,  FALSE),
  ('super_admin', 'profiles',      TRUE, TRUE,  TRUE,  TRUE,  FALSE),
  ('ops',         'applications',  TRUE, FALSE, TRUE,  FALSE, TRUE),
  ('ops',         'bookings',      TRUE, TRUE,  TRUE,  FALSE, FALSE),
  ('ops',         'properties',    TRUE, FALSE, TRUE,  FALSE, FALSE),
  ('finance',     'payments',      TRUE, TRUE,  TRUE,  FALSE, FALSE),
  ('finance',     'b2b_partners',  TRUE, FALSE, FALSE, FALSE, FALSE),
  ('finance',     'applications',  TRUE, FALSE, FALSE, FALSE, FALSE),
  ('support',     'applications',  TRUE, FALSE, FALSE, FALSE, FALSE),
  ('support',     'profiles',      TRUE, FALSE, FALSE, FALSE, FALSE),
  ('support',     'bookings',      TRUE, FALSE, FALSE, FALSE, FALSE),
  ('property_manager', 'properties', TRUE, TRUE, TRUE, FALSE, FALSE),
  ('property_manager', 'units',      TRUE, TRUE, TRUE, FALSE, FALSE);
