# CHRONOS research log

## 2026-11-10 — Simulation 001: special-relativistic time

**Status:** Numerical results and plot generation verified from the project session.

The simulation reported:
- Constant speed: 0.99 c; Lorentz factor: 7.088812.
- Earth-frame coordinate time: 10.0000 years.
- Traveller proper time: 1.4107 years.
- Idealized twin-paradox case: 5 years outbound and 5 years inbound in the Earth frame; traveller proper time 1.4107 years; difference 8.5893 years.
- Prescribed variable-speed profile: reference time 10.0000 years; integrated proper time 6.5475 years.

The plot `chronos_01_time_dilation.png` was confirmed to exist locally at `D:\\CHRONOS\\03_Simulations\\Python\\chronos_01_time_dilation.png` (61,341 bytes; last modified 2026-11-10 02:45, as reported in the session).

### Interpretation and limitations

These are outputs of an idealized special-relativistic calculation, not a physical time-travel experiment. The twin-paradox calculation assumes inertial coasting legs and an instantaneous turnaround. The variable-velocity case uses a prescribed one-dimensional sinusoidal velocity profile and midpoint numerical integration; it is not a dynamically derived acceleration or propulsion model. Reversing spatial direction does not reverse the direction of time.

The source file and image have not yet been transferred into this repository. No source hash was captured at the time of execution.

## Historical execution preservation

The initial attempt to run the Python script failed because the file was not present at the path supplied to Python. This is recorded separately as a failed setup execution in [execution record](../results/execution_logs/simulation_001_setup_failure.md). A later package-installation attempt had no preserved console output, so its outcome is marked undetermined rather than inferred.

## Publication policy

Every future execution must be recorded immediately after it completes, regardless of outcome. Failed, interrupted, and inconclusive runs are retained. Fixes and reruns receive new execution IDs; prior records are never silently replaced.
