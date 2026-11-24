// Claude's side of this hook. Everything it does lives in hooks-core, shared with Antigravity.
import { claudeHook } from '../../hooks-core/run.mjs';
import { save } from '../../hooks-core/save.mjs';

claudeHook(p => save('claude', p));
