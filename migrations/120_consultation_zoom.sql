-- Zoom for consultation slots, embedded inside Brainixa like the availability-slot and
-- class_sessions live classes - a teacher or admin presses Start, a signed signature opens the
-- room inside the app, nobody is ever handed a zoom.us link.
ALTER TABLE consultation_slots
  ADD COLUMN IF NOT EXISTS zoom_meeting_id VARCHAR(32) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS zoom_password VARCHAR(64) DEFAULT NULL;
