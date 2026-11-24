// Antigravity's side of this hook: it always prints exactly one JSON object. The work lives in hooks-core.
import { antigravityHook } from '../../hooks-core/run.mjs';
import { wake } from '../../hooks-core/wake.mjs';
import { agMarkWoke } from '../../hooks-core/turn.mjs';

antigravityHook(p => { agMarkWoke(p); return wake('antigravity', p); });
