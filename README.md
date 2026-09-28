# DXVK ARM64EC builds (branch `wcp`)

This branch only holds a build workflow. It builds **unmodified** upstream DXVK tags from
[doitsujin/dxvk](https://github.com/doitsujin/dxvk) with llvm-mingw and packages them as a
GameNative/Winlator `.wcp`:

- `system32/` – ARM64EC (native on ARM64 Wine, no x86 translation)
- `syswow64/` – 32-bit x86

To build another version, add it to the `matrix.dxvk` list in
`.github/workflows/build-dxvk-arm64ec.yml` and push. Releases are tagged `dxvk-<version>-arm64ec-<run>`.
`tools/pearch.py` checks that every `system32` DLL really is ARM64EC before packaging.
