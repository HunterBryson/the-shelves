// Antigravity's side of this hook: it always prints exactly one JSON object. The work lives in hooks-core.
import { antigravityHook } from '../../hooks-core/run.mjs';
import { agTurn } from '../../hooks-core/turn.mjs';

// Runs before every model call, and speaks once per message.
antigravityHook((p, raw) => agTurn(p, raw));
