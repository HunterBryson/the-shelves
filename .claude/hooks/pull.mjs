// Claude's side of this hook. Everything it does lives in hooks-core, shared with Antigravity.
import { claudeHook } from '../../hooks-core/run.mjs';
import { pullPiece } from '../../hooks-core/wake.mjs';

// One numbered piece of the blocks the footing asks for (settings.json runs this with 1 to 6).
claudeHook(p => pullPiece(p, Number(process.argv[2] || 1)));
