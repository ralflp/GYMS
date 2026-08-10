import { Response } from 'express';
import { TenantRequest } from '../middleware/tenant';
import { getTenantPool } from '../config/tenantDb';

export const getClients = async (req: TenantRequest, res: Response) => {
  const pool = getTenantPool(req.tenantDb!);
  try {
    const result = await pool.query('SELECT * FROM clients ORDER BY first_name ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching clients:', error);
    res.status(500).json({ message: 'Error fetching clients' });
  }
};

export const createClient = async (req: TenantRequest, res: Response) => {
  const pool = getTenantPool(req.tenantDb!);
  const { first_name, last_name, email, phone, face_id } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO clients (first_name, last_name, email, phone, face_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [first_name, last_name, email, phone, face_id]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating client:', error);
    res.status(500).json({ message: 'Error creating client' });
  }
};
