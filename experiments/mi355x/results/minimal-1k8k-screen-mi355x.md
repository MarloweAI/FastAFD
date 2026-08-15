# Minimal MI355X 1K/8K screen

This is a fast steady-state screen of GPT-OSS-120B at 1,024 input tokens and
8,192 requested output tokens. It compares the InferenceX vLLM TP8 baseline,
FastAFD's colocated TP8 server, and two AFD splits. It is intentionally not part
of the 8K-input/1K-output Pareto dataset.

## Workload

- Eight physical MI355X GPUs per server.
- InferenceX random dataset, range ratio 0.8, infinite request rate, ignore EOS.
- Concurrency 4 and 8.
- One warmup wave and one measured wave: 4 or 8 measured requests per point.
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
| vLLM InferenceX | TP8 | 8 | 2,194.5 | 64.7 ms | 3.35 ms | Baseline |
| FastAFD colocated | TP8 | 8 | 1,171.1 | 969.8 ms | 6.13 ms | Not alignment-gated |
| FastAFD AFD | 7:1 | 8 | 156.4 | 403.7 ms | 49.41 ms | Passed |
| FastAFD AFD | 4:4 | 8 | 227.5 | 353.9 ms | 33.01 ms | Provisional: failed |

FastAFD colocated reaches 55.7% of vLLM output throughput at c4 and 53.4% at
c8. The correctness-passing 7:1 AFD split reaches 20.8% and 13.4% of FastAFD
colocated throughput, respectively. The c8 colocated TTFT is anomalously high
and needs repetition before it is used for a TTFT conclusion.

The 7:1 AFD alignment gate passed with three exact prompts and one exact-logit
near-tie. The 4:4 gate had two real divergences, so its timing numbers are
retained only as provisional diagnostics. The colocated FastAFD screen did not
run the token-alignment gate.

## Provenance and limitations

- vLLM jobs 578 and 580 ran on `marlowe-mi355x-4`.
- FastAFD colocated job 616 ran on `marlowe-mi355x-3` at source commit
  `be4a1b5a6add22404a65f7baeac5b8d25ffefc18` and completed in 4m39s.
- AFD 4:4 job 567 ran on `marlowe-mi355x-3`; AFD 7:1 job 568 ran on
  `marlowe-mi355x-4`. Their runtime manifests recorded AITER 0.1.13, ROCm
  7.2.53211, PyTorch `2.10.0+git8514f05`, and the packed
  `aiter_ck_a16w4` backend, but recorded the source revision as `unknown`.

Because this screen uses minimal samples, spans two nominally identical nodes,
and lacks a colocated alignment result, it answers only whether performance is
in the ballpark. It is not release-quality Pareto evidence. Exact raw artifact
paths and normalized values are recorded in
[`minimal-1k8k-screen-mi355x.csv`](minimal-1k8k-screen-mi355x.csv).
