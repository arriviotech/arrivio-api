-- ============================================================
-- MIGRATION 2 — Property & Inventory
-- Tables: properties, units, amenity_catalogue, unit_amenities,
--         unit_pricing_rules, unit_availability,
--         property_progress_milestones, property_photos
-- ============================================================

-- ── 6. properties ───────────────────────────────────────────
CREATE TABLE properties (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  slug            TEXT NOT NULL UNIQUE,
  description     TEXT,
  address_line1   TEXT NOT NULL,
  address_line2   TEXT,
  city            TEXT NOT NULL,
  postal_code     TEXT NOT NULL,
  district        TEXT,
  latitude        NUMERIC(9,6),
  longitude       NUMERIC(9,6),
  property_type   TEXT NOT NULL CHECK (property_type IN (
                    'apartment_building',
                    'student_residence',
                    'shared_house',
                    'serviced_apartments'
                  )),
  available_for   TEXT[] NOT NULL DEFAULT ARRAY['professional','azubi','student'],
  house_rules     TEXT,
  manager_name    TEXT,
  manager_phone   TEXT,
  manager_email   TEXT,
  status          TEXT NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active', 'coming_soon', 'inactive')),
  deleted_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 7. units ────────────────────────────────────────────────
CREATE TABLE units (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id     UUID NOT NULL REFERENCES properties(id) ON DELETE RESTRICT,
  unit_number     TEXT NOT NULL,
  floor           INTEGER,
  unit_type       TEXT NOT NULL CHECK (unit_type IN (
                    'studio', 'one_bedroom',
                    'two_bedroom', 'shared_room'
                  )),
  available_for   TEXT[] NOT NULL DEFAULT ARRAY['professional','azubi','student'],
  max_occupants   INTEGER NOT NULL DEFAULT 1,
  size_sqm        NUMERIC(6,2),
  description     TEXT,
  status          TEXT NOT NULL DEFAULT 'available'
                  CHECK (status IN (
                    'available', 'occupied',
                    'maintenance', 'reserved'
                  )),
  tier            TEXT NOT NULL DEFAULT 'standard'
                  CHECK (tier IN ('standard', 'premium', 'executive')),
  is_furnished    BOOLEAN NOT NULL DEFAULT TRUE,
  deleted_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (property_id, unit_number)
);

-- ── 8. amenity_catalogue ────────────────────────────────────
CREATE TABLE amenity_catalogue (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL UNIQUE,
  icon_key    TEXT,
  category    TEXT NOT NULL CHECK (category IN (
                'connectivity', 'appliances', 'furniture',
                'building', 'services', 'security'
              )),
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 9. unit_amenities ───────────────────────────────────────
CREATE TABLE unit_amenities (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id     UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
  amenity_id  UUID NOT NULL REFERENCES amenity_catalogue(id) ON DELETE CASCADE,
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (unit_id, amenity_id)
);

-- ── 10. unit_pricing_rules ──────────────────────────────────
CREATE TABLE unit_pricing_rules (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id                 UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
  tenant_type             TEXT NOT NULL CHECK (tenant_type IN (
                            'professional', 'azubi', 'student', 'b2b'
                          )),
  monthly_rent_cents      INTEGER NOT NULL,
  security_deposit_cents  INTEGER NOT NULL,
  holding_deposit_cents   INTEGER NOT NULL DEFAULT 15000,
  discount_pct            NUMERIC(5,2) NOT NULL DEFAULT 0,
  min_stay_months         INTEGER NOT NULL DEFAULT 3,
  max_stay_months         INTEGER NOT NULL DEFAULT 24,
  valid_from              DATE NOT NULL DEFAULT CURRENT_DATE,
  valid_until             DATE,
  is_active               BOOLEAN NOT NULL DEFAULT TRUE,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (unit_id, tenant_type, valid_from)
);

-- ── 11. unit_availability ───────────────────────────────────
-- NOTE: booking_id FK added in migration 3 after bookings table exists
CREATE TABLE unit_availability (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id     UUID NOT NULL REFERENCES units(id) ON DELETE CASCADE,
  date        DATE NOT NULL,
  status      TEXT NOT NULL CHECK (status IN (
                'occupied', 'maintenance', 'held', 'blocked'
              )),
  booking_id  UUID,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (unit_id, date)
);

-- ── 12. property_progress_milestones ────────────────────────
CREATE TABLE property_progress_milestones (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id     UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  description     TEXT,
  category        TEXT NOT NULL CHECK (category IN (
                    'construction', 'furnishing', 'utilities',
                    'inspection', 'handover'
                  )),
  completion_pct  INTEGER NOT NULL DEFAULT 0
                  CHECK (completion_pct BETWEEN 0 AND 100),
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN (
                    'pending', 'in_progress',
                    'completed', 'delayed'
                  )),
  target_date     DATE,
  completed_at    TIMESTAMPTZ,
  photo_urls      TEXT[],
  notes           TEXT,
  updated_by      UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 13. property_photos ─────────────────────────────────────
CREATE TABLE property_photos (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id     UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  unit_id         UUID REFERENCES units(id) ON DELETE CASCADE,
  storage_path    TEXT NOT NULL,
  alt_text        TEXT,
  caption         TEXT,
  is_primary      BOOLEAN NOT NULL DEFAULT FALSE,
  display_order   INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TRIGGERS ────────────────────────────────────────────────
CREATE TRIGGER properties_updated_at
  BEFORE UPDATE ON properties
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER units_updated_at
  BEFORE UPDATE ON units
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER unit_pricing_rules_updated_at
  BEFORE UPDATE ON unit_pricing_rules
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER property_progress_milestones_updated_at
  BEFORE UPDATE ON property_progress_milestones
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── RLS ──────────────────────────────────────────────────────
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE units ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_pricing_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_photos ENABLE ROW LEVEL SECURITY;

-- Anyone can read active properties and units (public listings)
CREATE POLICY "properties_public_read"
  ON properties FOR SELECT
  USING (status IN ('active', 'coming_soon') AND deleted_at IS NULL);

CREATE POLICY "units_public_read"
  ON units FOR SELECT
  USING (status != 'maintenance' AND deleted_at IS NULL);

CREATE POLICY "pricing_public_read"
  ON unit_pricing_rules FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "availability_public_read"
  ON unit_availability FOR SELECT
  USING (TRUE);

CREATE POLICY "photos_public_read"
  ON property_photos FOR SELECT
  USING (TRUE);

-- ── SEED — amenity catalogue ─────────────────────────────────
INSERT INTO amenity_catalogue (name, icon_key, category) VALUES
  ('WiFi',                  'wifi',            'connectivity'),
  ('Ethernet Port',         'ethernet',        'connectivity'),
  ('Washing Machine',       'washing-machine', 'appliances'),
  ('Dishwasher',            'dishwasher',      'appliances'),
  ('Oven',                  'oven',            'appliances'),
  ('Refrigerator',          'fridge',          'appliances'),
  ('Desk',                  'desk',            'furniture'),
  ('Wardrobe',              'wardrobe',        'furniture'),
  ('Double Bed',            'bed-double',      'furniture'),
  ('Single Bed',            'bed-single',      'furniture'),
  ('Gym Access',            'gym',             'building'),
  ('Rooftop Terrace',       'rooftop',         'building'),
  ('Co-working Space',      'coworking',       'building'),
  ('Parking',               'parking',         'building'),
  ('Bike Storage',          'bike',            'building'),
  ('Weekly Cleaning',       'cleaning',        'services'),
  ('Laundry Service',       'laundry',         'services'),
  ('Key Fob Entry',         'keyfob',          'security'),
  ('CCTV',                  'cctv',            'security'),
  ('Concierge',             'concierge',       'security');
