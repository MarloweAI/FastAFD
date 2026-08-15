# FastAFD experiments on MI300X

These recipes target AMD MI300X (`gfx942`, CDNA3) and the environment documented
in the repository's [MI300X guide](../../README.md#mi300x-gfx942).

| Recipe | Purpose |
|---|---|
| `serve_bench.py` | Measure TTFT, TPOT/ITL, and serving throughput. |
| `run_decode_grid.sh` | Reproduce the MI300X ISL/concurrency decode grid. |
| `prefill_ttft.py` | Measure exact-length, unique-prompt prefill TTFT. |
| `profile_steady_rocm.sh` | Capture a warmed steady-state ROCm profile. |
| `profile_report.py` | Summarize and inspect the captured profiler CSVs. |

Run these from the repository root. For example:

```bash
PORT=19295 CONFIG=colocated_tp4_packed \
  experiments/mi300x/run_decode_grid.sh

experiments/mi300x/profile_report.py results/profiles/RUN --view summary
```

Do not use these MI300X dependency pins or performance results as MI355X
evidence. MI355X experiments live in [`../mi355x/`](../mi355x/README.md).
