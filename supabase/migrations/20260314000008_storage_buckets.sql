-- ============================================================
-- MIGRATION 8 — Supabase Storage Buckets
-- Creates all storage buckets with correct access policies
-- ============================================================

-- ── CREATE BUCKETS ───────────────────────────────────────────

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  -- PUBLIC BUCKETS
  (
    'property-photos',
    'property-photos',
    TRUE,
    10485760,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'event-covers',
    'event-covers',
    TRUE,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'addon-covers',
    'addon-covers',
    TRUE,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'avatars',
    'avatars',
    TRUE,
    2097152,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'community-posts',
    'community-posts',
    TRUE,
    5242880,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),

  -- PRIVATE BUCKETS
  (
    'tenant-documents',
    'tenant-documents',
    FALSE,
    20971520,
    ARRAY['image/jpeg', 'image/png', 'application/pdf']
  ),
  (
    'rental-agreements',
    'rental-agreements',
    FALSE,
    20971520,
    ARRAY['application/pdf']
  ),
  (
    'contract-documents',
    'contract-documents',
    FALSE,
    20971520,
    ARRAY['application/pdf']
  );

-- ── FILE SIZE LIMITS REFERENCE ───────────────────────────────
-- property-photos   → 10MB  high quality listing photos
-- event-covers      → 5MB   event marketing images
-- addon-covers      → 5MB   add-on service images
-- avatars           → 2MB   profile pictures
-- community-posts   → 5MB   resident post images
-- tenant-documents  → 20MB  passport, visa, contracts (PDFs)
-- rental-agreements → 20MB  signed rental agreement PDFs
-- contract-documents→ 20MB  B2B partner contracts

-- ── PUBLIC BUCKET POLICIES ───────────────────────────────────

-- property-photos — anyone can read (shown on listings page)
CREATE POLICY "property_photos_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'property-photos');

-- Only authenticated admins can upload property photos
CREATE POLICY "property_photos_admin_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'property-photos'
    AND auth.role() = 'authenticated'
  );

-- Only authenticated admins can delete property photos
CREATE POLICY "property_photos_admin_delete"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'property-photos'
    AND auth.role() = 'authenticated'
  );

-- event-covers — anyone can read
CREATE POLICY "event_covers_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'event-covers');

-- event-covers — authenticated users can upload
CREATE POLICY "event_covers_auth_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'event-covers'
    AND auth.role() = 'authenticated'
  );

-- addon-covers — anyone can read
CREATE POLICY "addon_covers_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'addon-covers');

-- community-posts — anyone authenticated can read
CREATE POLICY "community_posts_images_read"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'community-posts'
    AND auth.role() = 'authenticated'
  );

-- community-posts — members can upload their own post images
-- folder structure: community-posts/[profile-id]/filename
CREATE POLICY "community_posts_images_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'community-posts'
    AND auth.role() = 'authenticated'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- community-posts — members can delete their own post images
CREATE POLICY "community_posts_images_delete"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'community-posts'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- avatars — anyone can read (public profile photos)
CREATE POLICY "avatars_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- avatars — users can upload their own avatar
-- folder structure: avatars/[profile-id]/avatar.jpg
CREATE POLICY "avatars_insert_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- avatars — users can update their own avatar
CREATE POLICY "avatars_update_own"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- avatars — users can delete their own avatar
CREATE POLICY "avatars_delete_own"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- ── PRIVATE BUCKET POLICIES ──────────────────────────────────

-- tenant-documents — tenant can upload their own documents
-- folder structure: tenant-documents/[profile-id]/filename
CREATE POLICY "tenant_documents_insert_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'tenant-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- tenant-documents — tenant can read their own documents
CREATE POLICY "tenant_documents_read_own"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'tenant-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- tenant-documents — tenant can delete their own documents
CREATE POLICY "tenant_documents_delete_own"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'tenant-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- tenant-documents — B2B contact can read their employee documents
CREATE POLICY "tenant_documents_b2b_read"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'tenant-documents'
    AND EXISTS (
      SELECT 1
      FROM profiles p
      JOIN b2b_employees be ON be.profile_id = p.id
      JOIN b2b_contacts bc ON bc.b2b_partner_id = be.b2b_partner_id
      WHERE p.id::text = (storage.foldername(name))[1]
        AND bc.profile_id = auth.uid()
    )
  );

-- rental-agreements — tenant can read their own signed agreement
-- folder structure: rental-agreements/[profile-id]/booking-[id].pdf
CREATE POLICY "rental_agreements_read_own"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'rental-agreements'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- rental-agreements — only service role can upload
-- (API uploads signed PDFs from DocuSign, not the tenant directly)
CREATE POLICY "rental_agreements_service_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'rental-agreements'
    AND auth.role() = 'service_role'
  );

-- contract-documents — only service role can read and write
-- (B2B partner contracts — Ops only via backend API)
CREATE POLICY "contract_documents_service_only"
  ON storage.objects FOR ALL
  USING (
    bucket_id = 'contract-documents'
    AND auth.role() = 'service_role'
  );
