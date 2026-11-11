"""
PROJECT CHRONOS
CHRONOS-01: Special Relativistic Time Dilation
Phase 1, Week 1, Simulation 001

Author: CHRONOS Research
Python: 3.11+
"""

import numpy as np
import matplotlib.pyplot as plt

# Fundamental constant
C = 299_792_458  # Speed of light (m/s)


def lorentz_factor(beta):
    """
    Calculate Lorentz factor.

    beta = v/c

    Valid domain: 0 <= |beta| < 1
    """
    if abs(beta) >= 1:
        raise ValueError("Velocity must be below the speed of light.")

    return 1 / np.sqrt(1 - beta**2)


def time_dilation(beta, earth_years):
    """
    Calculate proper time experienced by a moving observer.

    beta: velocity / speed of light
    earth_years: elapsed time in reference frame
    """

    if earth_years < 0:
        raise ValueError("Elapsed time cannot be negative.")

    gamma = lorentz_factor(beta)

    traveller_years = earth_years / gamma

    return gamma, traveller_years


def twin_paradox(beta, years_per_leg):
    """
    Idealized round trip with constant-speed outbound
    and inbound legs and instantaneous turnaround.

    Earth is treated as an inertial reference frame.
    """

    gamma = lorentz_factor(beta)

    earth_years = 2 * years_per_leg

    traveller_years = earth_years / gamma

    difference = earth_years - traveller_years

    return earth_years, traveller_years, difference


def proper_time_variable_velocity(beta_values, times):
    """
    Numerically integrate proper time for a
    velocity profile defined in the reference frame.

    beta_values = v(t)/c
    times = reference-frame time in years

    Uses midpoint values for numerical integration.
    """

    if len(beta_values) != len(times):
        raise ValueError("Arrays must have equal lengths.")

    if np.any(np.abs(beta_values) >= 1):
        raise ValueError("Velocity must remain below c.")

    if np.any(np.diff(times) <= 0):
        raise ValueError("Times must be strictly increasing.")

    beta_mid = (beta_values[:-1] + beta_values[1:]) / 2

    dt = np.diff(times)

    proper_time = np.sum(
        np.sqrt(1 - beta_mid**2) * dt
    )

    return proper_time


def run_simulation():

    print("=" * 55)
    print("       PROJECT CHRONOS - SIMULATION 001")
    print("          SPECIAL RELATIVISTIC TIME")
    print("=" * 55)

    # Experiment 1: Constant velocity

    beta = 0.99
    earth_years = 10

    gamma, traveller_years = time_dilation(
        beta, earth_years
    )

    print("\nEXPERIMENT 1: CONSTANT VELOCITY")

    print(f"Velocity       : {beta:.3f} c")
    print(f"Lorentz factor : {gamma:.6f}")
    print(f"Earth time     : {earth_years:.4f} years")
    print(f"Traveller time : {traveller_years:.4f} years")

    # Experiment 2: Idealized round trip

    print("\nEXPERIMENT 2: TWIN PARADOX")

    earth, traveller, difference = twin_paradox(
        beta, 5
    )

    print(f"Outbound time  : 5 years")
    print(f"Inbound time   : 5 years")
    print(f"Earth time     : {earth:.4f} years")
    print(f"Traveller time : {traveller:.4f} years")
    print(f"Time difference: {difference:.4f} years")

    # Experiment 3: Variable velocity

    print("\nEXPERIMENT 3: VARIABLE VELOCITY")

    times = np.linspace(0, 10, 10001)

    # Smooth velocity profile:
    # Starts at rest, reaches 0.99c,
    # reverses direction, returns to rest.

    beta_profile = 0.99 * np.sin(
        2 * np.pi * times / 10
    )

    proper = proper_time_variable_velocity(
        beta_profile, times
    )

    print(f"Reference time : 10.0000 years")
    print(f"Proper time    : {proper:.4f} years")

    # Experiment 4: Generate time dilation graph

    beta_range = np.linspace(0, 0.999, 1000)

    gamma_values = 1 / np.sqrt(
        1 - beta_range**2
    )

    plt.figure(figsize=(10, 6))

    plt.plot(
        beta_range,
        gamma_values,
        label="Lorentz factor"
    )

    plt.xlabel("Velocity (fraction of c)")
    plt.ylabel("Lorentz factor (gamma)")

    plt.title("CHRONOS-01: Relativistic Time Dilation")

    plt.grid(True)
    plt.legend()

    plt.tight_layout()

    plt.savefig(
        "chronos_01_time_dilation.png",
        dpi=200
    )

    plt.show()

    print("\nSimulation completed successfully.")
    print("Graph saved as chronos_01_time_dilation.png")


if __name__ == "__main__":
    run_simulation()
