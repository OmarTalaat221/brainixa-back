-- Give every payment attempt a reference that is unique for all time.
--
-- `customerReference` was the row's auto-increment id. EasyKash consumes a reference permanently
-- and per MERCHANT ACCOUNT, not per site, so an id is the wrong thing to send:
--
--   * Brainixa and Najeh share one EasyKash account, so both were spending the same 1, 2, 3...
--   * every rebuild of this database restarts the counter onto references already spent;
--   * a failed attempt still burns its reference, so the retry collides too.
--
-- The result was HTTP 200 carrying {"error":"Error the 'customerReference' is already used!"} and
-- no redirectUrl - checkout refusing every payment, with transaction 8 the one seen live.
--
-- The row id stays the local key; `gateway_reference` is what travels to EasyKash, and its random
-- tail keeps it unique across rebuilds and across sites sharing the account.

ALTER TABLE `payment_transactions`
  ADD COLUMN IF NOT EXISTS `gateway_reference` VARCHAR(64) DEFAULT NULL
  COMMENT 'The customerReference sent to EasyKash. Unique for all time; never reuse.'
  AFTER `easykash_ref`;

-- Unique so a collision is refused by the database rather than discovered at the gateway.
-- NULLs are exempt from a UNIQUE index in MariaDB, so rows predating this stay valid.
ALTER TABLE `payment_transactions`
  ADD UNIQUE KEY IF NOT EXISTS `uq_payment_transactions_gateway_reference` (`gateway_reference`);

-- Backfill is deliberately omitted. A reference the gateway has already seen cannot be made
-- usable by writing it down here, and inventing one for a settled row would break the lookup that
-- resolves an incoming callback. Old rows resolve by id; new ones by this column.
