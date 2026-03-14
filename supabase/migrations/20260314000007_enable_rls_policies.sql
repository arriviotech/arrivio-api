-- ============================================================
-- MIGRATION 7 — Enable RLS on all remaining tables
--               + Fix function search_path warnings
--               + Add missing RLS policies
-- Run: supabase db push
-- ============================================================

-- ── ENABLE RLS ON ALL REMAINING TABLES ──────────────────────

ALTER TABLE unit_amenities                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE amenity_catalogue               ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_profiles                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_permissions               ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_progress_milestones    ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_photos                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE enquiries                       ENABLE ROW LEVEL SECURITY;
ALTER TABLE application_notes               ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_deposits               ENABLE ROW LEVEL SECURITY;
ALTER TABLE move_in_records                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE move_out_records                ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental_agreements               ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_holds                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_invoices                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_payments                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_disputes                ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_rent_statements         ENABLE ROW LEVEL SECURITY;
ALTER TABLE addon_orders                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_contacts                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_partner_properties          ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_lead_requests               ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_pricing_rules              ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_availability               ENABLE ROW LEVEL SECURITY;
ALTER TABLE outside_hosts                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE space_bookings                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_customisation_requests     ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_ticket_messages         ENABLE ROW LEVEL SECURITY;
ALTER TABLE direct_messages                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_spaces                ENABLE ROW LEVEL SECURITY;

-- ── ADMIN TABLES — service role only ────────────────────────
-- These tables must NEVER be directly accessible by tenants
-- or B2B users. Only the backend API (service role) can access.

CREATE POLICY "admin_profiles_service_role_only"
  ON admin_profiles FOR ALL
  USING (FALSE);

CREATE POLICY "audit_logs_service_role_only"
  ON audit_logs FOR ALL
  USING (FALSE);

CREATE POLICY "admin_permissions_service_role_only"
  ON admin_permissions FOR ALL
  USING (FALSE);

CREATE POLICY "b2b_lead_requests_service_role_only"
  ON b2b_lead_requests FOR ALL
  USING (FALSE);

CREATE POLICY "application_notes_service_role_only"
  ON application_notes FOR ALL
  USING (FALSE);

CREATE POLICY "move_out_records_service_role_only"
  ON move_out_records FOR ALL
  USING (FALSE);

CREATE POLICY "b2b_payments_service_role_only"
  ON b2b_payments FOR ALL
  USING (FALSE);

-- ── PUBLIC READ POLICIES ─────────────────────────────────────

-- Unit amenities — public read (shown on listings)
CREATE POLICY "unit_amenities_public_read"
  ON unit_amenities FOR SELECT
  USING (TRUE);

-- Amenity catalogue — public read (filter options)
CREATE POLICY "amenity_catalogue_public_read"
  ON amenity_catalogue FOR SELECT
  USING (is_active = TRUE);

-- Property photos — public read
CREATE POLICY "property_photos_public_read"
  ON property_photos FOR SELECT
  USING (TRUE);

-- Unit pricing rules — public read
CREATE POLICY "unit_pricing_rules_public_read"
  ON unit_pricing_rules FOR SELECT
  USING (is_active = TRUE);

-- Unit availability — public read (date picker)
CREATE POLICY "unit_availability_public_read"
  ON unit_availability FOR SELECT
  USING (TRUE);

-- Property progress milestones — public read (B2B progress tracker)
CREATE POLICY "milestones_public_read"
  ON property_progress_milestones FOR SELECT
  USING (TRUE);

-- Outside hosts — public read for verified hosts
CREATE POLICY "outside_hosts_public_read"
  ON outside_hosts FOR SELECT
  USING (is_verified = TRUE AND is_active = TRUE);

-- ── TENANT POLICIES ──────────────────────────────────────────

-- Enquiries — tenant can see their own
CREATE POLICY "enquiries_read_own"
  ON enquiries FOR SELECT
  USING (auth.uid() = profile_id);

-- Security deposits — tenant can see their own
CREATE POLICY "security_deposits_read_own"
  ON security_deposits FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = booking_id
        AND b.profile_id = auth.uid()
    )
  );

-- Move in records — tenant can see their own
CREATE POLICY "move_in_records_read_own"
  ON move_in_records FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bookings b
      WHERE b.id = booking_id
        AND b.profile_id = auth.uid()
    )
  );

-- Unit holds — user can see their own
CREATE POLICY "unit_holds_read_own"
  ON unit_holds FOR SELECT
  USING (auth.uid() = profile_id);

-- Addon orders — tenant can see their own
CREATE POLICY "addon_orders_read_own"
  ON addon_orders FOR SELECT
  USING (auth.uid() = ordered_by_id);

-- Support ticket messages — tenant can see messages on their tickets
CREATE POLICY "ticket_messages_read_own"
  ON support_ticket_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM support_tickets st
      WHERE st.id = ticket_id
        AND st.profile_id = auth.uid()
    )
  );

-- ── B2B CONTACT POLICIES ─────────────────────────────────────

-- B2B contacts — contact can see others in their company
CREATE POLICY "b2b_contacts_read_own_company"
  ON b2b_contacts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_contacts bc
      WHERE bc.b2b_partner_id = b2b_contacts.b2b_partner_id
        AND bc.profile_id = auth.uid()
    )
  );

-- B2B partner properties — contact can see their company allocations
CREATE POLICY "b2b_partner_properties_read_own"
  ON b2b_partner_properties FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_contacts bc
      WHERE bc.b2b_partner_id = b2b_partner_properties.b2b_partner_id
        AND bc.profile_id = auth.uid()
    )
  );

-- B2B invoices — contact can see their company invoices
CREATE POLICY "b2b_invoices_read_own_company"
  ON b2b_invoices FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_contacts bc
      WHERE bc.b2b_partner_id = b2b_invoices.b2b_partner_id
        AND bc.profile_id = auth.uid()
    )
  );

-- Monthly rent statements — B2B contact can see their company statements
CREATE POLICY "statements_read_own_company"
  ON monthly_rent_statements FOR SELECT
  USING (
    auth.uid() = profile_id
    OR
    EXISTS (
      SELECT 1 FROM b2b_contacts bc
      WHERE bc.b2b_partner_id = monthly_rent_statements.b2b_partner_id
        AND bc.profile_id = auth.uid()
    )
  );

-- Unit customisation requests — B2B contact can see their company requests
CREATE POLICY "customisation_requests_read_own"
  ON unit_customisation_requests FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_employees be
      JOIN b2b_contacts bc ON bc.b2b_partner_id = be.b2b_partner_id
      WHERE be.id = b2b_employee_id
        AND bc.profile_id = auth.uid()
    )
  );

-- ── COMMUNITY POLICIES ───────────────────────────────────────

-- Event attendees — member can see their own RSVPs
CREATE POLICY "event_attendees_read_own"
  ON event_attendees FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM community_members cm
      WHERE cm.id = community_member_id
        AND cm.profile_id = auth.uid()
    )
  );

-- Club members — member can see clubs they joined
CREATE POLICY "club_members_read_own"
  ON club_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM community_members cm
      WHERE cm.id = community_member_id
        AND cm.profile_id = auth.uid()
    )
  );

-- Space bookings — member can see their own bookings
CREATE POLICY "space_bookings_read_own"
  ON space_bookings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM community_members cm
      WHERE cm.id = community_member_id
        AND cm.profile_id = auth.uid()
    )
  );

-- Community spaces — members can see spaces in their property
CREATE POLICY "community_spaces_read_same_property"
  ON community_spaces FOR SELECT
  USING (
    is_active = TRUE
    AND property_id IN (
      SELECT property_id FROM community_members
      WHERE profile_id = auth.uid()
    )
  );

  -- Members can see likes on posts in their property
CREATE POLICY "post_likes_read_same_property"
  ON community_post_likes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM community_posts cp
      JOIN community_members cm ON cm.property_id = cp.property_id
      WHERE cp.id = post_id
        AND cm.profile_id = auth.uid()
    )
  );

-- Members can like posts
CREATE POLICY "post_likes_insert_own"
  ON community_post_likes FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM community_members cm
      WHERE cm.id = community_member_id
        AND cm.profile_id = auth.uid()
    )
  );

-- Members can unlike (delete) their own likes
CREATE POLICY "post_likes_delete_own"
  ON community_post_likes FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM community_members cm
      WHERE cm.id = community_member_id
        AND cm.profile_id = auth.uid()
    )
  );
-- ── FIX FUNCTION SEARCH PATH WARNINGS ───────────────────────
-- Fixes the 4 "Function Search Path Mutable" warnings
-- shown in Supabase Security Advisor

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public;

CREATE OR REPLACE FUNCTION public.auto_create_community_member()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'confirmed' AND OLD.status != 'confirmed' THEN
    INSERT INTO public.community_members (profile_id, booking_id, property_id)
    SELECT
      NEW.profile_id,
      NEW.id,
      u.property_id
    FROM public.units u WHERE u.id = NEW.unit_id
    ON CONFLICT (profile_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public;

CREATE OR REPLACE FUNCTION public.update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.community_posts
    SET like_count = like_count + 1
    WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.community_posts
    SET like_count = like_count - 1
    WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public;

CREATE OR REPLACE FUNCTION public.update_club_member_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.clubs
    SET member_count = member_count + 1
    WHERE id = NEW.club_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.clubs
    SET member_count = member_count - 1
    WHERE id = OLD.club_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path = public;
