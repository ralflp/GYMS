import { getClient } from '../config/db';
import { runTenantMigrations } from './dbMigrator';

export const createDatabaseForTenant = async (dbName: string) => {
  const client = await getClient();
  try {
    const sanitizedDbName = dbName.replace(/[^a-zA-Z0-9_]/g, '');
    const checkDbQuery = `SELECT 1 FROM pg_database WHERE datname = '${sanitizedDbName}'`;
    const result = await client.query(checkDbQuery);

    if (result.rowCount === 0) {
      await client.query(`CREATE DATABASE ${sanitizedDbName}`);
      console.log(`Database ${sanitizedDbName} created successfully.`);

      // Run migrations on the new tenant database
      await runTenantMigrations(sanitizedDbName);
    } else {
      console.log(`Database ${sanitizedDbName} already exists.`);
    }
    return sanitizedDbName;
  } catch (error) {
    console.error(`Error creating database ${dbName}:`, error);
    throw error;
  } finally {
    client.release();
  }
};
