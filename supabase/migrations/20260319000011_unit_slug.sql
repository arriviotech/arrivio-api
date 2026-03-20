-- ============================================================
-- MIGRATION 11 — Add slug column to units
-- ============================================================

ALTER TABLE units ADD COLUMN slug TEXT UNIQUE;

-- Generate slugs for all existing units
-- Format: {property-slug}-{unit-type}-{tier}-f{floor}-{unit_number}
UPDATE units u
SET slug = CONCAT(
  p.slug, '-',
  REPLACE(u.unit_type, '_', '-'), '-',
  u.tier, '-f',
  u.floor, '-',
  u.unit_number
)
FROM properties p
WHERE p.id = u.property_id;

-- Create index for slug lookups
CREATE INDEX units_slug_idx ON units (slug);
