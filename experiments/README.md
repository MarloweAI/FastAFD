# Experiments by architecture

Architecture-specific benchmark recipes live in separate directories:

- [`mi300x/`](mi300x/README.md): `gfx942` serving, decode-grid, prefill, and
  ROCm profiling recipes.
- [`mi355x/`](mi355x/README.md): `gfx950` AITER FastAFD, colocated, vLLM, and
  Pareto comparison recipes.

The token-alignment gate and its checked-in Hugging Face reference remain at
this directory's top level because both architectures use them. Top-level
MI300X command files are compatibility entrypoints; new commands and docs use
the paths under `mi300x/`.
