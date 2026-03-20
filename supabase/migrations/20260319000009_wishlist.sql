-- ============================================================
-- MIGRATION 9 — Wishlist
-- Table: wishlist (user saved/liked properties)
-- ============================================================

CREATE TABLE wishlist (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, property_id)
);

-- ── RLS ──────────────────────────────────────────────────────
ALTER TABLE wishlist ENABLE ROW LEVEL SECURITY;

-- User can read their own wishlist
CREATE POLICY "wishlist_read_own"
  ON wishlist FOR SELECT
  USING (auth.uid() = user_id);

-- User can add to their own wishlist
CREATE POLICY "wishlist_insert_own"
  ON wishlist FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- User can remove from their own wishlist
CREATE POLICY "wishlist_delete_own"
  ON wishlist FOR DELETE
  USING (auth.uid() = user_id);
