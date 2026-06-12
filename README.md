# Traffic Light Controller - Verilog HDL

A synthesizable, FSM-based Traffic Light Controller designed in Verilog HDL, simulated using Xilinx Vivado and Mentor ModelSim, and suitable for FPGA deployment.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Design Architecture](#design-architecture)
- [Getting Started](#getting-started)
- [Module Interface](#module-interface)
- [Simulation Results](#simulation-results)
- [Future Scope](#future-scope)
- [Author](#author)

---

## Overview

This project implements a two-street Traffic Light Controller as a clocked Finite State Machine (FSM) using Verilog HDL. The controller manages traffic signals for a main street and a cross street, cycling through green, yellow, and red phases in a coordinated and timed sequence.

The design follows a clean three-always-block RTL structure:
- One block for the timing counter
- One block for FSM state transitions
- One block for output light logic

The design is fully synthesizable and verified using behavioral simulation across multiple complete cycles, including mid-cycle asynchronous reset testing.

---

## Features

- Four-state FSM with clearly defined, counter-driven state transitions
- 5-bit free-running counter for precise phase timing across a 32-clock cycle
- 3-bit one-hot output encoding per street where Green=001, Yellow=010, Red=100
- Mutual exclusion guaranteed so both streets can never simultaneously show green
- Asynchronous reset that immediately returns the FSM to its initial state
- Clean synthesizable Verilog with no combinational feedback loops
- Verified in both Xilinx Vivado XSim and Mentor ModelSim
- FPGA-ready design that maps efficiently to flip-flops and LUTs

---

## Project Structure

    traffic_light_controller/
    |
    |-- src/
    |   |-- traffic_controller.v         # Top-level Verilog design module
    |
    |-- sim/
    |   |-- traffic_controller_tb.v      # Verilog testbench
    |
    |-- constraints/
    |   |-- traffic_light.xdc            # FPGA pin constraints for Vivado
    |
    |-- docs/
    |   |-- Traffic_Light_Controller_Report.pdf
    |
    |-- README.md

---

## Design Architecture

### FSM States

The controller uses a 2-bit state register encoding four states:

| State Name | Encoding | Main Street | Cross Street | Duration  |
|------------|----------|-------------|--------------|-----------|
| g_to_r     | 2b00     | Green       | Red          | 15 clocks |
| y_to_r     | 2b01     | Yellow      | Red          | 3 clocks  |
| r_to_g     | 2b10     | Red         | Green        | 10 clocks |
| r_to_y     | 2b11     | Red         | Yellow       | 3 clocks  |

### Timing Sequence

    light_count : 0 ----------- 14 | 15 -- 17 | 18 ---------- 27 | 28 -- 30 | wrap to 0
    State       :  g_to_r (15s)    | y_to_r 3s|  r_to_g (10s)   | r_to_y 3s|
                 <------------------- 32-clock cycle ---------------------------->

### Output Encoding

    3-bit one-hot encoding:
    bit[2] = Red  |  bit[1] = Yellow  |  bit[0] = Green

    3b100 = Red
    3b010 = Yellow
    3b001 = Green

### State Transition Diagram

    [RESET] -----> [ g_to_r ] ---(count==15)---> [ y_to_r ]
                       ^                               |
                       |                          (count==18)
                       |                               |
                  [ r_to_y ] <--(count==28)--- [ r_to_g ]
                  (count==31)

---

## Getting Started

### Prerequisites

- Xilinx Vivado 2020.x or later for synthesis and XSim simulation
- Mentor ModelSim or QuestaSim for standalone HDL simulation
- Basic familiarity with Verilog HDL and FSM design

### Running Simulation in Vivado

1. Open Vivado and create a new RTL project
2. Add src/traffic_controller.v as a design source
3. Add sim/traffic_controller_tb.v as a simulation source
4. In the Flow Navigator click Run Simulation then Run Behavioral Simulation
5. In the waveform window add signals clk, rst, light_count, main_st, cross_st and run for at least 1000 ns
6. Verify state transitions at the expected light_count thresholds

To generate the RTL schematic:
- Click Run Synthesis then Open Synthesized Design then Schematic

### Running Simulation in ModelSim

    # Step 1 - Compile the design and testbench
    vlog src/traffic_controller.v sim/traffic_controller_tb.v

    # Step 2 - Load the simulation
    vsim traffic_controller_tb

    # Step 3 - Add waveforms
    add wave -r /*

    # Step 4 - Run simulation
    run 1000ns

The $monitor statement in the testbench prints a full signal-change log to the transcript automatically. The $finish statement terminates the simulation after all test cases complete.

---

## Module Interface

    module traffic_controller (
        input            clk,          // System clock - 1 clock equals 1 second in simulation
        input            rst,          // Asynchronous active-high reset
        output reg [2:0] main_st,      // Main street: 001=Green 010=Yellow 100=Red
        output reg [2:0] cross_st,     // Cross street: 001=Green 010=Yellow 100=Red
        output reg [4:0] light_count   // Internal timing counter 0 to 31
    );

| Port        | Direction | Width | Description                                      |
|-------------|-----------|-------|--------------------------------------------------|
| clk         | Input     | 1-bit | Clock signal, all logic is posedge-triggered     |
| rst         | Input     | 1-bit | Asynchronous reset, active high                  |
| main_st     | Output    | 3-bit | One-hot encoded main street light state          |
| cross_st    | Output    | 3-bit | One-hot encoded cross street light state         |
| light_count | Output    | 5-bit | Timing counter 0 to 31, exposed for monitoring   |

---

## Simulation Results

| Verification Check                                    | Result |
|-------------------------------------------------------|--------|
| Correct 4-state FSM sequencing                        | Pass   |
| Phase durations match spec 15 / 3 / 10 / 3 clocks    | Pass   |
| One-hot output encoding correct in all states         | Pass   |
| Both streets never simultaneously green               | Pass   |
| Asynchronous reset clears counter and state instantly | Pass   |
| No undefined X or high-Z output values                | Pass   |
| Consistent behavior across multiple 32-clock cycles   | Pass   |

---

## Future Scope

| Enhancement         | Description                                                           |
|---------------------|-----------------------------------------------------------------------|
| Pedestrian Crossing | Add a button input to insert a dedicated pedestrian crossing phase    |
| Emergency Override  | High-priority input that sets all vehicle lights red instantly        |
| Adaptive Timing     | Sensor-driven counter thresholds for real-time traffic optimization   |
| FPGA Deployment     | Map outputs to LEDs on Xilinx Basys 3 or Nexys A7 boards             |
| Multi-Intersection  | Network multiple controllers together for green-wave synchronization  |
| Fault Detection     | BIST logic to detect stuck-at faults and enter safe flashing-red mode |

---

## Author

Gayatri Galidevara  
Digital System Design Laboratory

---

This design is intended for academic study in digital systems engineering and FPGA prototyping.
It demonstrates sequential FSM design, Verilog best practices, and hardware simulation methodology.
