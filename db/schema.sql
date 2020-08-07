CREATE TABLE IF NOT EXISTS "secrets" (
    id         TEXT NOT NULL,
    passphrase TEXT NOT NULL,
    secret     TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
