import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

// Pool para la base de datos principal (donde se guardan los tenants/gimnasios y el súper administrador)
const masterPool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'gym_master',
  password: process.env.DB_PASSWORD || 'postgres',
  port: parseInt(process.env.DB_PORT || '5432', 10),
});

export const query = (text: string, params?: any[]) => {
  return masterPool.query(text, params);
};

export const getClient = () => {
  return masterPool.connect();
};

export default masterPool;
