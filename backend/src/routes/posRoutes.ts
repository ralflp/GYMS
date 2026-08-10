import { Router } from 'express';
import { getProducts, getMemberships, processSale } from '../controllers/posController';
import { getClients, createClient } from '../controllers/clientController';
import { resolveTenant } from '../middleware/tenant';

const router = Router();

// Todos los endpoints de este router requieren conocer a qué tenant/gimnasio pertenecen
router.use(resolveTenant);

// Clients
router.get('/clients', getClients);
router.post('/clients', createClient);

// Products & Memberships
router.get('/products', getProducts);
router.get('/memberships', getMemberships);

// Sales (POS)
router.post('/sales', processSale);

export default router;
