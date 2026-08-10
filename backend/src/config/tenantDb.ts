import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pools: { [key: string]: Pool } = {};

export const getTenantPool = (dbName: string): Pool => {
  if (!pools[dbName]) {
    pools[dbName] = new Pool({
      user: process.env.DB_USER || 'postgres',
      host: process.env.DB_HOST || 'localhost',
      database: dbName,
      password: process.env.DB_PASSWORD || 'postgres',
      port: parseInt(process.env.DB_PORT || '5432', 10),
    });
  }
  return pools[dbName];
};
