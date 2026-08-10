CREATE TABLE IF NOT EXISTS super_admins (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tenants (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    db_name VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'paused', 'inactive')),
    email VARCHAR(255),
    phone VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Inserción de un súper administrador de prueba (password: admin123)
-- bcrypt hash para admin123: $2a$10$XU0k/Vv/U75k0Uf935n48eBq5i32.61X.T6wTq5uC0aLzF3q5X5e6
INSERT INTO super_admins (email, password_hash)
VALUES ('admin@gym.com', '$2y$10$Fz.H3Jv4c0r9r.VbH.9G4u9P4P7yK6w/1w1P9vP5.Y6k6K5K3P1Q6')
ON CONFLICT (email) DO NOTHING;
