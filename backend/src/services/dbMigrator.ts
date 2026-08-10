import { Pool } from 'pg';
import { getTenantPool } from '../config/tenantDb';

const initDbScript = `
CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    face_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS memberships (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    duration_days INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS client_memberships (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id),
    membership_id INTEGER REFERENCES memberships(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sales (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(id),
    total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sale_items (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER REFERENCES sales(id),
    product_id INTEGER REFERENCES products(id),
    membership_id INTEGER REFERENCES memberships(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);
`;

export const runTenantMigrations = async (dbName: string) => {
  const pool = getTenantPool(dbName);
  const client = await pool.connect();
  try {
    await client.query(initDbScript);
    console.log(`Migrations ran successfully for database: ${dbName}`);
  } catch (error) {
    console.error(`Error running migrations for ${dbName}:`, error);
    throw error;
  } finally {
    client.release();
  }
};
