# Execution record — CHRONOS-SIM-001-RUN-001

- **Experiment:** Simulation 001 — Special-relativistic time dilation
- **Status:** FAIL — script file not found
- **Environment:** Windows PowerShell; Python command invoked
- **Source hash:** Not applicable; script was not found at the requested path
- **Raw-output provenance:** Error text preserved in the project session.

## Objective

Start the first CHRONOS Python simulation.

## Reported error

```text
can't open file '...chronos_01_time_dilation.py': [Errno 2] No such file or directory
```

The path in the historical console transcript was abbreviated in the conversation summary; the exact full command line is therefore not reconstructed here.

## Interpretation

Python could not open the requested script because it was not present at the path used for that invocation. This is a setup/path failure, not a failure of the relativistic equations or simulation logic.

## Next action

Create/save the script at the intended project path and rerun under a new execution ID. The later successful execution is recorded separately as CHRONOS-SIM-001-RUN-002.
