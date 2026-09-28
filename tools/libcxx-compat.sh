#!/usr/bin/env bash
# Small source fixups needed when building DXVK with llvm-mingw (libc++ and its newer headers).
# Each fix only applies when the pattern is present, so it is a no-op on versions that don't need it.
set -euo pipefail
cd "${1:?dxvk source dir}"
TC_INC=$(dirname "$(command -v i686-w64-mingw32-clang)")/../generic-w64-mingw32/include

# llvm-mingw's d3d9types.h already defines D3DDEVINFO_RESOURCEMANAGER
if grep -qs '_D3DDEVINFO_RESOURCEMANAGER' "$TC_INC/d3d9types.h" && grep -q 'typedef struct _D3DDEVINFO_RESOURCEMANAGER' src/d3d9/d3d9_include.h 2>/dev/null; then
  perl -i -0777 -pe 's/^\s*typedef\s+struct\s+_D3DDEVINFO_RESOURCEMANAGER\s*\{.*?\}\s*D3DDEVINFO_RESOURCEMANAGER[^;]*;//ms' src/d3d9/d3d9_include.h
  echo "compat: dropped duplicate D3DDEVINFO_RESOURCEMANAGER"
fi
# ...and the ID3D10StateBlock UUID
if grep -Rqs '__CRT_UUID_DECL(ID3D10StateBlock' "$TC_INC"/d3d10* && grep -qs '__CRT_UUID_DECL(ID3D10StateBlock' src/d3d10/d3d10_interfaces.h; then
  perl -i -ne 'print unless /^\s*__CRT_UUID_DECL\(ID3D10StateBlock,/' src/d3d10/d3d10_interfaces.h
  echo "compat: dropped duplicate ID3D10StateBlock UUID"
fi
# libc++ rejects piecewise emplace with an empty key tuple
if [ -f src/dxvk/dxvk_pipemanager.cpp ] && grep -qzP 'std::piecewise_construct,\s*std::tuple\(\)\s*,' src/dxvk/dxvk_pipemanager.cpp; then
  perl -0777 -i -pe 's/(std::piecewise_construct,\s*)std::tuple\(\)(\s*,)/${1}std::tuple(key)${2}/g' src/dxvk/dxvk_pipemanager.cpp
  echo "compat: fixed empty-tuple piecewise emplace"
fi
