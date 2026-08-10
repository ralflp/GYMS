import { Router } from 'express';
import { createTenant, getTenants, updateTenantStatus } from '../controllers/tenantController';
import { authenticateToken, authorizeSuperAdmin } from '../middleware/auth';

const router = Router();

router.use(authenticateToken);
router.use(authorizeSuperAdmin);

router.post('/', createTenant);
router.get('/', getTenants);
router.patch('/:id/status', updateTenantStatus);

export default router;
