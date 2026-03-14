-- ============================================================
-- MIGRATION 6 — Community + Support
-- Tables: community_members, community_posts,
--         community_post_likes, direct_messages,
--         outside_hosts, events, event_attendees,
--         clubs, club_members, community_spaces,
--         space_bookings, unit_customisation_requests,
--         support_tickets, support_ticket_messages
-- Also: auto community_member trigger on booking confirmed
-- ============================================================

-- ── 37. community_members ───────────────────────────────────
CREATE TABLE community_members (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id        UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  booking_id        UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
  property_id       UUID NOT NULL REFERENCES properties(id) ON DELETE RESTRICT,
  bio               TEXT,
  interests         TEXT[],
  hometown          TEXT,
  languages_spoken  TEXT[],
  linkedin_url      TEXT,
  is_profile_public BOOLEAN NOT NULL DEFAULT TRUE,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  joined_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 38. community_posts ─────────────────────────────────────
CREATE TABLE community_posts (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_member_id   UUID NOT NULL REFERENCES community_members(id) ON DELETE CASCADE,
  property_id           UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  post_type             TEXT NOT NULL DEFAULT 'general'
                        CHECK (post_type IN (
                          'general', 'event_teaser', 'tip',
                          'welcome', 'marketplace'
                        )),
  body                  TEXT,
  image_urls            TEXT[],
  like_count            INTEGER NOT NULL DEFAULT 0,
  is_flagged            BOOLEAN NOT NULL DEFAULT FALSE,
  is_removed            BOOLEAN NOT NULL DEFAULT FALSE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 39. community_post_likes ────────────────────────────────
CREATE TABLE community_post_likes (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id               UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
  community_member_id   UUID NOT NULL REFERENCES community_members(id) ON DELETE CASCADE,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, community_member_id)
);

-- ── 40. direct_messages ─────────────────────────────────────
CREATE TABLE direct_messages (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id                 UUID NOT NULL REFERENCES community_members(id) ON DELETE CASCADE,
  receiver_id               UUID NOT NULL REFERENCES community_members(id) ON DELETE CASCADE,
  body                      TEXT NOT NULL,
  image_url                 TEXT,
  is_read                   BOOLEAN NOT NULL DEFAULT FALSE,
  read_at                   TIMESTAMPTZ,
  is_deleted_by_sender      BOOLEAN NOT NULL DEFAULT FALSE,
  is_deleted_by_receiver    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 41. outside_hosts ───────────────────────────────────────
CREATE TABLE outside_hosts (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id          UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  display_name        TEXT NOT NULL,
  bio                 TEXT,
  category            TEXT NOT NULL CHECK (category IN (
                        'fitness', 'food', 'language',
                        'culture', 'wellness', 'other'
                      )),
  profile_photo_url   TEXT,
  is_verified         BOOLEAN NOT NULL DEFAULT FALSE,
  verified_by         UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  verified_at         TIMESTAMPTZ,
  bank_reference      TEXT,
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 42. community_spaces ────────────────────────────────────
-- Created before events since events references it
CREATE TABLE community_spaces (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id         UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  description         TEXT,
  category            TEXT NOT NULL CHECK (category IN (
                        'rooftop', 'gym', 'coworking',
                        'lounge', 'garden', 'other'
                      )),
  cover_image_url     TEXT,
  capacity            INTEGER NOT NULL,
  max_booking_hours   INTEGER NOT NULL DEFAULT 2,
  available_from      TIME NOT NULL DEFAULT '07:00',
  available_until     TIME NOT NULL DEFAULT '23:00',
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 43. events ──────────────────────────────────────────────
CREATE TABLE events (
  id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id                 UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  host_type                   TEXT NOT NULL CHECK (host_type IN (
                                'resident', 'outside_host'
                              )),
  host_community_member_id    UUID REFERENCES community_members(id) ON DELETE SET NULL,
  host_outside_host_id        UUID REFERENCES outside_hosts(id) ON DELETE SET NULL,
  title                       TEXT NOT NULL,
  description                 TEXT,
  category                    TEXT NOT NULL CHECK (category IN (
                                'fitness', 'food', 'language',
                                'culture', 'social', 'wellness', 'other'
                              )),
  cover_image_url             TEXT,
  location_type               TEXT NOT NULL CHECK (location_type IN (
                                'community_space', 'offsite'
                              )),
  community_space_id          UUID REFERENCES community_spaces(id) ON DELETE SET NULL,
  offsite_address             TEXT,
  starts_at                   TIMESTAMPTZ NOT NULL,
  ends_at                     TIMESTAMPTZ NOT NULL,
  capacity                    INTEGER,
  is_paid                     BOOLEAN NOT NULL DEFAULT FALSE,
  price_cents                 INTEGER NOT NULL DEFAULT 0,
  status                      TEXT NOT NULL CHECK (status IN (
                                'draft', 'published',
                                'cancelled', 'completed'
                              )),
  cancellation_reason         TEXT,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 44. event_attendees ─────────────────────────────────────
CREATE TABLE event_attendees (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id              UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  community_member_id   UUID NOT NULL REFERENCES community_members(id) ON DELETE CASCADE,
  status                TEXT NOT NULL DEFAULT 'registered'
                        CHECK (status IN (
                          'registered', 'attended',
                          'cancelled', 'no_show'
                        )),
  payment_id            UUID REFERENCES payments(id) ON DELETE SET NULL,
  qr_token              TEXT UNIQUE,
  registered_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  cancelled_at          TIMESTAMPTZ,
  UNIQUE (event_id, community_member_id)
);

-- ── 45. clubs ───────────────────────────────────────────────
CREATE TABLE clubs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id     UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  description     TEXT,
  category        TEXT NOT NULL CHECK (category IN (
                    'sports', 'food', 'culture', 'language',
                    'gaming', 'fitness', 'music', 'other'
                  )),
  cover_image_url TEXT,
  created_by      UUID REFERENCES community_members(id) ON DELETE SET NULL,
  member_count    INTEGER NOT NULL DEFAULT 0,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 46. club_members ────────────────────────────────────────
CREATE TABLE club_members (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id               UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  community_member_id   UUID NOT NULL REFERENCES community_members(id) ON DELETE CASCADE,
  role                  TEXT NOT NULL DEFAULT 'member'
                        CHECK (role IN ('admin', 'member')),
  joined_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (club_id, community_member_id)
);

-- ── 47. space_bookings ──────────────────────────────────────
CREATE TABLE space_bookings (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  community_space_id    UUID NOT NULL REFERENCES community_spaces(id) ON DELETE CASCADE,
  community_member_id   UUID NOT NULL REFERENCES community_members(id) ON DELETE CASCADE,
  starts_at             TIMESTAMPTZ NOT NULL,
  ends_at               TIMESTAMPTZ NOT NULL,
  status                TEXT NOT NULL DEFAULT 'confirmed'
                        CHECK (status IN ('confirmed', 'cancelled')),
  cancelled_at          TIMESTAMPTZ,
  cancellation_reason   TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 48. unit_customisation_requests ─────────────────────────
CREATE TABLE unit_customisation_requests (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  b2b_employee_id       UUID NOT NULL REFERENCES b2b_employees(id) ON DELETE CASCADE,
  booking_id            UUID REFERENCES bookings(id) ON DELETE SET NULL,
  requested_by          UUID REFERENCES b2b_contacts(id) ON DELETE SET NULL,
  customisation_items   JSONB NOT NULL DEFAULT '[]',
  status                TEXT NOT NULL DEFAULT 'requested'
                        CHECK (status IN (
                          'requested', 'in_progress',
                          'completed', 'rejected'
                        )),
  admin_notes           TEXT,
  completed_by          UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  completed_at          TIMESTAMPTZ,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 49. support_tickets ─────────────────────────────────────
CREATE TABLE support_tickets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  booking_id    UUID REFERENCES bookings(id) ON DELETE SET NULL,
  category      TEXT NOT NULL CHECK (category IN (
                  'maintenance', 'billing', 'noise',
                  'access', 'documents', 'general'
                )),
  subject       TEXT NOT NULL,
  priority      TEXT NOT NULL DEFAULT 'medium'
                CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  status        TEXT NOT NULL DEFAULT 'open'
                CHECK (status IN (
                  'open', 'in_progress', 'resolved', 'closed'
                )),
  assigned_to   UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  resolved_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── 50. support_ticket_messages ─────────────────────────────
CREATE TABLE support_ticket_messages (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id           UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
  sender_type         TEXT NOT NULL CHECK (sender_type IN ('tenant', 'admin')),
  sender_profile_id   UUID REFERENCES profiles(id) ON DELETE SET NULL,
  sender_admin_id     UUID REFERENCES admin_profiles(id) ON DELETE SET NULL,
  message             TEXT NOT NULL,
  attachment_urls     TEXT[],
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TRIGGERS ────────────────────────────────────────────────
CREATE TRIGGER community_members_updated_at
  BEFORE UPDATE ON community_members
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER community_posts_updated_at
  BEFORE UPDATE ON community_posts
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER events_updated_at
  BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER clubs_updated_at
  BEFORE UPDATE ON clubs
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER community_spaces_updated_at
  BEFORE UPDATE ON community_spaces
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER support_tickets_updated_at
  BEFORE UPDATE ON support_tickets
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER unit_customisation_requests_updated_at
  BEFORE UPDATE ON unit_customisation_requests
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── TRIGGER — auto-create community_member on booking confirmed
CREATE OR REPLACE FUNCTION auto_create_community_member()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'confirmed' AND OLD.status != 'confirmed' THEN
    INSERT INTO community_members (profile_id, booking_id, property_id)
    SELECT
      NEW.profile_id,
      NEW.id,
      u.property_id
    FROM units u WHERE u.id = NEW.unit_id
    ON CONFLICT (profile_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_community_member_on_booking
  AFTER UPDATE ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION auto_create_community_member();

-- ── TRIGGER — keep like_count in sync ───────────────────────
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE community_posts SET like_count = like_count + 1
    WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE community_posts SET like_count = like_count - 1
    WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_post_like_count
  AFTER INSERT OR DELETE ON community_post_likes
  FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

-- ── TRIGGER — keep club member_count in sync ────────────────
CREATE OR REPLACE FUNCTION update_club_member_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE clubs SET member_count = member_count + 1
    WHERE id = NEW.club_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE clubs SET member_count = member_count - 1
    WHERE id = OLD.club_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_club_member_count
  AFTER INSERT OR DELETE ON club_members
  FOR EACH ROW EXECUTE FUNCTION update_club_member_count();

-- ── RLS ──────────────────────────────────────────────────────
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE direct_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;

-- Community members can see other active members in same property
CREATE POLICY "community_members_read_same_property"
  ON community_members FOR SELECT
  USING (
    is_active = TRUE
    AND is_profile_public = TRUE
    AND property_id = (
      SELECT property_id FROM community_members
      WHERE profile_id = auth.uid()
      LIMIT 1
    )
  );

-- Community members can see posts in their property
CREATE POLICY "community_posts_read_same_property"
  ON community_posts FOR SELECT
  USING (
    is_removed = FALSE
    AND property_id = (
      SELECT property_id FROM community_members
      WHERE profile_id = auth.uid()
      LIMIT 1
    )
  );

-- Community members can write posts in their property
CREATE POLICY "community_posts_insert_own"
  ON community_posts FOR INSERT
  WITH CHECK (
    community_member_id = (
      SELECT id FROM community_members
      WHERE profile_id = auth.uid()
      LIMIT 1
    )
  );

-- Members can see events in their property
CREATE POLICY "events_read_same_property"
  ON events FOR SELECT
  USING (
    status = 'published'
    AND property_id = (
      SELECT property_id FROM community_members
      WHERE profile_id = auth.uid()
      LIMIT 1
    )
  );

-- Members can see clubs in their property
CREATE POLICY "clubs_read_same_property"
  ON clubs FOR SELECT
  USING (
    is_active = TRUE
    AND property_id = (
      SELECT property_id FROM community_members
      WHERE profile_id = auth.uid()
      LIMIT 1
    )
  );

-- Members can only see their own DMs
CREATE POLICY "direct_messages_read_own"
  ON direct_messages FOR SELECT
  USING (
    sender_id = (SELECT id FROM community_members WHERE profile_id = auth.uid() LIMIT 1)
    OR
    receiver_id = (SELECT id FROM community_members WHERE profile_id = auth.uid() LIMIT 1)
  );

-- Tenant can see their own support tickets
CREATE POLICY "support_tickets_read_own"
  ON support_tickets FOR SELECT
  USING (auth.uid() = profile_id);
