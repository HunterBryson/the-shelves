// Prints a chat back as plain conversation for a sleep. Usage is in hooks-core/readback.mjs.
import { readback } from '../../hooks-core/readback.mjs';

process.stdout.write(readback('claude', process.argv.slice(2)));
