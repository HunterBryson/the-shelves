// Claude's side of this hook. Everything it does lives in hooks-core, shared with Antigravity.
import { claudeHook } from '../../hooks-core/run.mjs';
import { wake } from '../../hooks-core/wake.mjs';

claudeHook(p => wake('claude', p));
