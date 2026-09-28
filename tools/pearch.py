#!/usr/bin/env python3
"""Print the architecture of Windows PE DLLs/EXEs: x86, x86_64 (runs under FEX), ARM64EC / ARM64X (native)."""
import struct, sys

def arch(path):
    d = open(path, 'rb').read()
    pe = struct.unpack_from('<I', d, 0x3c)[0]
    mach, nsec = struct.unpack_from('<HH', d, pe + 4)
    optsz = struct.unpack_from('<H', d, pe + 20)[0]
    opt = pe + 24
    if mach == 0x14c: return 'x86 (32-bit)'
    if mach == 0xaa64: return 'ARM64 / ARM64X (native)'
    if mach != 0x8664: return hex(mach)
    rva = struct.unpack_from('<I', d, opt + 112 + 10 * 8)[0]  # load config directory
    if not rva: return 'x86_64 (emulated by FEX)'
    for i in range(nsec):
        _, vs, va, rs, ro = struct.unpack_from('<8sIIII', d, opt + optsz + i * 40)
        if va <= rva < va + max(vs, rs):
            o = rva - va + ro
            if struct.unpack_from('<I', d, o)[0] > 0xC8 + 8 and struct.unpack_from('<Q', d, o + 0xC8)[0]:
                return 'ARM64EC (native)'
    return 'x86_64 (emulated by FEX)'

for p in sys.argv[1:]:
    print(f'{arch(p):26} {p}')
