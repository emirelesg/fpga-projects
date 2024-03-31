/*
 * Generate the ROM table for a signed 16-bit sine wave.
 */

const path = require('path');
const fs = require('fs');

const MEM_FILE = path.join(__dirname, 'sin_rom.mem');

const NUM_SAMPLES = 2 ** 11; // 2048
const AMPLITUDE = 2 ** (16 - 1) - 1; // 32767

const sin16 = Buffer.alloc(2);
const rom = [];

for (let n = 0; n < NUM_SAMPLES; n += 1) {
    const sin = AMPLITUDE * Math.sin((2 * Math.PI / NUM_SAMPLES) * n);

    sin16.writeInt16BE(sin, 0);

    rom.push(sin16.toString('hex').padStart(4, '0'));

    console.log(n, sin, `0x${rom[rom.length - 1]}`);
}

fs.writeFileSync(MEM_FILE, rom.join('\n'), 'utf-8');
