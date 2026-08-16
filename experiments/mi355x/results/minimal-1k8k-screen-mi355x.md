# Minimal MI355X 1K/8K screen

This is a fast steady-state screen of GPT-OSS-120B at 1,024 input tokens and
8,192 requested output tokens. It compares the InferenceX vLLM TP8 baseline,
FastAFD's colocated TP8 server, two FastAFD splits, and the upstream vLLM AFD
plugin adapted for GPT-OSS on ROCm. It is intentionally not part of the
8K-input/1K-output Pareto dataset.

## Workload

- Eight physical MI355X GPUs per server.
- InferenceX random dataset, range ratio 0.8, infinite request rate, ignore EOS.
- Concurrency 4 and 8.
- One measured wave: 4 or 8 measured requests per point. All original points
  and plugin c4 used one warmup wave; the plugin c8 exception is noted below.
- GPT-OSS-120B revision `b5c939de8f754692c1647ca79fbf85e8c1e70f8a`.
- InferenceX revision `770268c51c2b368e9d669096041c003520f14c3a`.
- Container digest
  `sha256:c3f18c9baf778cb4f9456a0f161e658fb45d70e3cd534dc3d1c55fac478d03bd`.

## Results

| System | Layout | C | Output tok/s | Median TTFT | Median TPOT | Correctness |
|---|---:|---:|---:|---:|---:|---|
| vLLM InferenceX | TP8 | 4 | 1,191.4 | 42.4 ms | 3.20 ms | Baseline |
| FastAFD colocated | TP8 | 4 | 663.4 | 57.9 ms | 5.70 ms | Not alignment-gated |
| FastAFD AFD | 7:1 | 4 | 138.1 | 360.6 ms | 27.80 ms | Passed |
| FastAFD AFD | 4:4 | 4 | 151.4 | 289.4 ms | 25.40 ms | Provisional: failed |
| vLLM AFD plugin | 4:4 | 4 | 54.9 | 553.2 ms | 69.64 ms | Native smoke passed |
| vLLM InferenceX | TP8 | 8 | 2,194.5 | 64.7 ms | 3.35 ms | Baseline |
| FastAFD colocated | TP8 | 8 | 1,171.1 | 969.8 ms | 6.13 ms | Not alignment-gated |
| FastAFD AFD | 7:1 | 8 | 156.4 | 403.7 ms | 49.41 ms | Passed |
| FastAFD AFD | 4:4 | 8 | 227.5 | 353.9 ms | 33.01 ms | Provisional: failed |
| vLLM AFD plugin | 4:4 | 8 | 107.9 | 183.7 ms | 67.45 ms | Native smoke passed |

FastAFD colocated reaches 55.7% of vLLM output throughput at c4 and 53.4% at
c8. The correctness-passing 7:1 AFD split reaches 20.8% and 13.4% of FastAFD
colocated throughput, respectively. The c8 colocated TTFT is anomalously high
and needs repetition before it is used for a TTFT conclusion.

The 7:1 AFD alignment gate passed with three exact prompts and one exact-logit
near-tie. The 4:4 gate had two real divergences, so its timing numbers are
retained only as provisional diagnostics. The colocated FastAFD screen did not
run the token-alignment gate.

The correctness-passing vLLM AFD plugin 4:4 result reaches 39.7% and 69.0% of
the correctness-passing FastAFD 7:1 output throughput at c4 and c8. Against the
provisional same-layout FastAFD 4:4 timings, it reaches 36.3% and 47.4%. It is
only 4.6% and 4.9% of the original vLLM TP8 baseline, so this initial plugin
port is functional but not performance-competitive on MI355X. Its c8 TTFT is
lower than both FastAFD split points, but its roughly 67-70 ms TPOT is the main
throughput bottleneck.

## Provenance and limitations

- vLLM jobs 578 and 580 ran on `marlowe-mi355x-4`.
- FastAFD colocated job 616 ran on `marlowe-mi355x-3` at source commit
  `be4a1b5a6add22404a65f7baeac5b8d25ffefc18` and completed in 4m39s.
- AFD 4:4 job 567 ran on `marlowe-mi355x-3`; AFD 7:1 job 568 ran on
  `marlowe-mi355x-4`. Their runtime manifests recorded AITER 0.1.13, ROCm
  7.2.53211, PyTorch `2.10.0+git8514f05`, and the packed
  `aiter_ck_a16w4` backend, but recorded the source revision as `unknown`.
- The vLLM AFD plugin 4:4 c4 point came from job 635 and the c8 point from job
  642, both on `marlowe-mi355x-1`. The port is commit
  `5a0143fe1d6858cc9a954e1a10e834be29ba9689`, based on upstream plugin commit
  `a04d9da356eedfdfbd7a062054173eeae11e497b`, using the Colovore ROCm vLLM
  0.26.0 image. The plugin's 7:1 probe failed during RCCL
  `ncclCommInitRank`, before serving, so there is no 7:1 plugin result.
- GPT-OSS MXFP4 returns a 2,880-wide hidden-state view backed by a padded
  3,072-wide row. The original connector sent that strided view as flat
  storage and produced corrupt tokens; the MI355X port materializes
  non-contiguous wire tensors. After the fix, the plugin and native vLLM
  produced the same deterministic `Paris` smoke completion.

Because this screen uses minimal samples, spans nominally identical nodes, and
lacks full alignment for the plugin and colocated points, it answers only
whether performance is in the ballpark. The plugin uses vLLM 0.26.0 while the
original baseline and FastAFD measurements use the earlier pinned stack, so
this is also a cross-version comparison. Plugin c4 used one warmup wave; c8
used no long-shape warmup after a fresh start, although its long decode
amortizes one-time compilation. This is not release-quality Pareto evidence.
Exact raw artifact paths and normalized values are recorded in
[`minimal-1k8k-screen-mi355x.csv`](minimal-1k8k-screen-mi355x.csv).
