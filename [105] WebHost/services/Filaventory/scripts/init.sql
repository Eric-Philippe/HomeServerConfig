-- User account table
CREATE TABLE "user" (
   id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   email VARCHAR(254) NOT NULL UNIQUE,
   username VARCHAR(50) NOT NULL UNIQUE,
   password_hash VARCHAR(255) NOT NULL,
   currency VARCHAR(3) NOT NULL DEFAULT 'USD',
   api_key VARCHAR(64) UNIQUE,                  -- for RFID device authentication
   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Storage rack for organizing filaments
CREATE TABLE rack (
   id_rack BIGSERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL,
   description TEXT,
   max_capacity INT,
   id_user UUID NOT NULL REFERENCES "user"(id_user) ON DELETE CASCADE,
   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   UNIQUE(id_user, name)
);

-- Filament brand (either user-defined or system-provided)
CREATE TABLE brand (
   id_brand UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   id_origin UUID,                              -- NULL = system brand (TigerTag), UUID = user's custom brand
   name VARCHAR(100) NOT NULL,
   website VARCHAR(255),
   empty_spool_weight_grams NUMERIC(10, 2),
   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(id_origin) REFERENCES "user"(id_user) ON DELETE CASCADE,
);

-- Filament product catalog
CREATE TABLE filament (
   id_filament UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   title VARCHAR(255) NOT NULL,
   color_hex VARCHAR(7) NOT NULL,               -- Format: #RRGGBB
   color_info JSONB,                            -- { "type": "mono", "colors": ["#0E294BFF"] }
   weight_grams INT NOT NULL DEFAULT 1000,
   image_url VARCHAR(500),
   material_type VARCHAR(50) NOT NULL,          -- PLA, ABS, PETG, TPU, etc.
   filled_type VARCHAR(50),                     -- Carbon-filled, glass-filled, etc.
   density NUMERIC(5, 2) NOT NULL DEFAULT 1.24,
   product_id VARCHAR(100),                    -- TigerTag product ID for syncing
   nozzle_temp_min SMALLINT,
   nozzle_temp_max SMALLINT,
   bed_temp_min SMALLINT,
   bed_temp_max SMALLINT,
   dry_temp SMALLINT,
   dry_time SMALLINT,
   id_brand UUID NOT NULL,
   id_origin UUID,                              -- NULL = system filament, UUID = user's custom filament
   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(id_brand) REFERENCES brand(id_brand) ON DELETE RESTRICT,
   FOREIGN KEY(id_origin) REFERENCES "user"(id_user) ON DELETE CASCADE
   CHECK (color_hex ~ '^#[0-9A-Fa-f]{6}$'),
);

-- User preferences for specific filaments
CREATE TABLE filament_preference (
   id_user UUID NOT NULL,
   id_filament UUID NOT NULL,
   nozzle_temp_override SMALLINT,
   bed_temp_override SMALLINT,
   ironing_flow SMALLINT,                       -- percentage (0-100)
   ironing_speed SMALLINT,                      -- mm/s
   notes TEXT,
   PRIMARY KEY(id_user, id_filament),
   FOREIGN KEY(id_user) REFERENCES "user"(id_user) ON DELETE CASCADE,
   FOREIGN KEY(id_filament) REFERENCES filament(id_filament) ON DELETE CASCADE,
   CHECK (ironing_flow IS NULL OR (ironing_flow >= 0 AND ironing_flow <= 100))
);

-- User print queue / projects
CREATE TABLE user_print_queue (
   id_project BIGSERIAL PRIMARY KEY,
   id_user UUID NOT NULL,
   title VARCHAR(255) NOT NULL,
   priority SMALLINT DEFAULT 0,
   comment TEXT,
   target_person VARCHAR(100),
   model_url VARCHAR(500),
   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(id_user) REFERENCES "user"(id_user) ON DELETE CASCADE
);

-- User-defined tags for organising print projects
CREATE TABLE user_tag (
   id_tag BIGSERIAL PRIMARY KEY,
   id_user UUID NOT NULL,
   name VARCHAR(50) NOT NULL,
   color VARCHAR(7),
   icon VARCHAR(50),
   created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(id_user) REFERENCES "user"(id_user) ON DELETE CASCADE,
   UNIQUE(id_user, name)
);

-- Junction: projects ↔ tags
CREATE TABLE print_queue_tag (
   id_project BIGINT NOT NULL,
   id_tag     BIGINT NOT NULL,
   PRIMARY KEY(id_project, id_tag),
   FOREIGN KEY(id_project) REFERENCES user_print_queue(id_project) ON DELETE CASCADE,
   FOREIGN KEY(id_tag)     REFERENCES user_tag(id_tag)             ON DELETE CASCADE
);

-- Filaments owned by user (inventory)
CREATE TABLE user_filament_spool (
   id_spool BIGSERIAL PRIMARY KEY,
   id_user UUID NOT NULL,
   id_filament UUID NOT NULL,
   is_spooled BOOLEAN NOT NULL DEFAULT TRUE,
   is_dry BOOLEAN NOT NULL DEFAULT TRUE,
   weight_remaining_grams NUMERIC(10, 2) NOT NULL DEFAULT 1000.00,
   rfid_tag VARCHAR(100),                       -- RFID tag UID, null if not tagged
   id_rack BIGINT,                              -- nullable FK, not BIGSERIAL
   notes TEXT,
   acquired_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(id_user)    REFERENCES "user"(id_user)                ON DELETE CASCADE,
   FOREIGN KEY(id_filament) REFERENCES filament(id_filament)         ON DELETE RESTRICT,
   FOREIGN KEY(id_rack)    REFERENCES rack(id_rack)                  ON DELETE SET NULL,
   CHECK (weight_remaining_grams > 0)
);

-- Filaments user wants to purchase
CREATE TABLE user_filament_wishlist (
   id_wish BIGSERIAL PRIMARY KEY,
   id_user UUID NOT NULL,
   id_filament UUID NOT NULL,
   quantity_spools NUMERIC(5, 2) NOT NULL DEFAULT 1.0,
   desired_price NUMERIC(10, 2),
   purchase_url VARCHAR(500),
   comment TEXT,
   priority SMALLINT DEFAULT 0,                -- -1=low, 0=normal, 1=high
   added_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY(id_user)    REFERENCES "user"(id_user)      ON DELETE CASCADE,
   FOREIGN KEY(id_filament) REFERENCES filament(id_filament) ON DELETE RESTRICT,
   UNIQUE(id_user, id_filament),
   CHECK (quantity_spools > 0),
   CHECK (desired_price IS NULL OR desired_price > 0)
);

-- Junction: projects ↔ filament sources (owned spool OR wishlist item)
CREATE TABLE print_queue_filament (
   id_link    BIGSERIAL PRIMARY KEY,
   id_project BIGINT NOT NULL,
   id_spool   BIGINT,
   id_wish    BIGINT,
   FOREIGN KEY(id_project) REFERENCES user_print_queue(id_project)      ON DELETE CASCADE,
   FOREIGN KEY(id_spool)   REFERENCES user_filament_spool(id_spool)      ON DELETE CASCADE,
   FOREIGN KEY(id_wish)    REFERENCES user_filament_wishlist(id_wish)     ON DELETE CASCADE,
   CHECK ((id_spool IS NOT NULL AND id_wish IS NULL) OR (id_spool IS NULL AND id_wish IS NOT NULL))
);
