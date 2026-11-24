// Antigravity's side of this hook: it always prints exactly one JSON object. The work lives in hooks-core.
import { antigravityHook } from '../../hooks-core/run.mjs';
import { save } from '../../hooks-core/save.mjs';

antigravityHook(p => { save('antigravity', p); return ''; });
