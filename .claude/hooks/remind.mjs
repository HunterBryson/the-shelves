// Claude's side of this hook. Everything it does lives in hooks-core, shared with Antigravity.
import { claudeHook } from '../../hooks-core/run.mjs';
import { remind } from '../../hooks-core/turn.mjs';

claudeHook((p, raw) => remind('claude', p, raw));
