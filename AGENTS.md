# Coding-agent instructions: FastAFD on AMD Instinct

Scope: maintain MI300X (`gfx942`) and MI355X (`gfx950`) implementations in the
same repository. Keep architecture-specific launchers, runtime checks, pins,
and benchmark claims explicit. Shared code may support both through runtime
dispatch; never force one architecture to emulate another architecture's
native datapath.

## MI355X benchmark work

Prefer native CDNA4/AITER MXFP4 kernels and change the serving implementation
when that is the right MI355X design. MI300X behavior is not a compatibility
contract for the MI355X backend, but MI300X entrypoints must remain distinct and
must not silently select MI355X-only kernels.

1. Run GPU work through Slurm on one 8-GPU Colovore MI355X node. Record the node,
   image digest, ROCm, PyTorch, AITER, source commit, and exact command in every run.
2. Keep GPT-OSS expert weights packed. The benchmark path must use AITER's gfx950
   MXFP4 MoE kernels and fail loudly if it falls back or dequantizes the weights.
3. Treat an `A:B` split as `A` TP1 attention workers plus `B` TP1 expert workers.
   Use full expert parallelism across the `B` workers. Uneven partitions are valid:
   pad the final local expert shard and mask its nonexistent experts.
4. Exercise all full-node splits `7:1` through `1:7`. Correctness must cover every
   split; performance uses concurrency `4,8,16,32,64,128` on the InferenceX
   8192-input/1024-output random workload.
5. Reproduce the pinned vLLM baseline on the same physical node. Do not compare an
   AFD rerun on one node against only published numbers from another node.
6. Plot total token throughput per physical GPU on x and median interactivity
   output tokens/s (`1 / median TPOT`) on y. Show published vLLM, same-node vLLM,
   every AFD point, per-split frontiers, and the combined AFD Pareto envelope.
7. Never set both `HIP_VISIBLE_DEVICES` and `ROCR_VISIBLE_DEVICES`. Do not install
   NVIDIA NCCL/CUDA packages into the ROCm environment.

The reproducibility entrypoint is `experiments/mi355x/README.md`; update it when
the benchmark contract or pinned dependencies change.

## MI300X maintenance

Use `bootstrap_rocm.sh`, `scripts/check_rocm_runtime.py`, `run_col_rocm.sh`, and
`run_afd_rocm.sh` for `gfx942`. Keep the validated MI300X environment and Slurm
workflow in `tools/slurm/`. Never publish an MI300X correctness or performance
claim based only on an MI355X run.
