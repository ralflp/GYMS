import { getClient } from '../config/db';

export const createDatabaseForTenant = async (dbName: string) => {
  const client = await getClient();
  try {
    // Only superusers can create databases, usually.
    // Note: Parameterized queries don't work for database names. We must sanitize it carefully.
    const sanitizedDbName = dbName.replace(/[^a-zA-Z0-9_]/g, '');

    // Check if database exists
    const checkDbQuery = `SELECT 1 FROM pg_database WHERE datname = '${sanitizedDbName}'`;
    const result = await client.query(checkDbQuery);

    if (result.rowCount === 0) {
      await client.query(`CREATE DATABASE ${sanitizedDbName}`);
      console.log(`Database ${sanitizedDbName} created successfully.`);
      // In a real scenario, you'd also run migrations on this new database here
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
