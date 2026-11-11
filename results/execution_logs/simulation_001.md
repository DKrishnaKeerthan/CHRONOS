# Execution record — CHRONOS-SIM-001-RUN-002

- **Experiment:** Simulation 001 — Special-relativistic time dilation
- **Execution date:** 2026-11-10 (local date reported in project session)
- **Status:** PASS — numerical output and plot artifact existence verified
- **Runtime:** Python 3.11.9
- **Dependencies reported:** NumPy 2.4.6; Matplotlib 3.11.2
- **Operating environment:** Windows PowerShell
- **Source file:** `chronos_01_time_dilation.py`
- **Source hash:** Not captured for this historical execution
- **Raw-output provenance:** Console output preserved in the project conversation; exact output transcribed below.

## Objective

Evaluate special-relativistic proper time for constant and variable one-dimensional velocity profiles, and compare Earth-frame coordinate time with traveller proper time in an idealized twin-paradox scenario.

## Reported console output

```text
PROJECT CHRONOS - SIMULATION 001
SPECIAL RELATIVISTIC TIME

EXPERIMENT 1: CONSTANT VELOCITY
Velocity       : 0.990 c
Lorentz factor : 7.088812
Earth time     : 10.0000 years
Traveller time : 1.4107 years

EXPERIMENT 2: TWIN PARADOX
Outbound time  : 5 years
Inbound time   : 5 years
Earth time     : 10.0000 years
Traveller time : 1.4107 years
Time difference: 8.5893 years

EXPERIMENT 3: VARIABLE VELOCITY
Reference time : 10.0000 years
Proper time    : 6.5475 years
```

## Artifact verification

The user verified that `chronos_01_time_dilation.png` existed at:

`D:\\CHRONOS\\03_Simulations\\Python\\chronos_01_time_dilation.png`

Reported file size: 61,341 bytes. Reported last-modified time: 2026-11-10 02:45. The image itself is not yet included in this commit.

## Scientific interpretation

For constant speed, the result is consistent with

`Delta_tau = Delta_t * sqrt(1 - beta^2)`

at `beta = 0.99`, giving approximately 1.4107 years of proper time over 10 years of coordinate time.

The twin-paradox result is an idealized symmetric trip with instantaneous turnaround. It omits finite acceleration and any gravitational effects.

The variable-velocity result is based on a prescribed sinusoidal one-dimensional speed profile and numerical integration. It should be treated as a model output, not a measured physical result. A reversal in spatial velocity is not backward time travel.

## Limitations and missing provenance

- Original source bytes and source hash were not captured alongside this historical run.
- Full raw terminal capture, process exit code, CPU model, and operating-system build were not preserved.
- Plot existence was checked locally, but the image is not yet in this repository.
- The reported console output is a transcription from the project session, not a byte-for-byte terminal log.

## Next action

Add the exact local source file and generated plot to the repository, then establish a PowerShell runner that captures stdout, stderr, exit code, timestamp, source hash, and environment metadata for every future run.
