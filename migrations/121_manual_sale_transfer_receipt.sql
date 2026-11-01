-- Proof of the transfer, on a manual sale.
--
-- The sheet records money that arrived outside the platform - a bank transfer, an instaPay
-- screenshot, a wallet receipt. Until now the only record of it was whatever the person who
-- wrote the row remembered, which is exactly the kind of claim an owner later needs to check
-- and cannot. The file is the evidence.
--
-- One column, nullable: a row is still written the moment the sale is agreed, usually before
-- any receipt exists, and a required attachment would make the sheet unusable for that.
--
-- VARCHAR(255) holding a path under uploads/, the same as every other file column here - never
-- the file itself. Images and PDFs both land in it; which one it is, is the extension's job to
-- say, and the dashboard reads it from there.

ALTER TABLE `manual_sales`
    ADD COLUMN IF NOT EXISTS `transfer_receipt` VARCHAR(255) DEFAULT NULL
        COMMENT 'Path to the transfer proof - image or PDF' AFTER `note`;
