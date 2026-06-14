# FPGA-Based Smart Parking System

## Overview
This project implements an FPGA-based Smart Parking System using Verilog HDL and Xilinx Vivado.

The system automatically:

- Monitors vehicle entry and exit
- Tracks available parking slots
- Controls entry and exit gates
- Displays available slots on a 4-digit 7-segment display
- Shows "FULL" when parking is completely occupied

## Features

✔ Real-time parking slot monitoring

✔ Automatic gate control

✔ Parking capacity management

✔ Edge-detection based vehicle counting

✔ 7-Segment display multiplexing

✔ Finite State Machine (FSM) implementation

✔ Vivado simulation and RTL verification

## Hardware Requirements

- FPGA Board (Artix-7 / Basys-3)
- Xilinx Vivado
- 7-Segment Display
- IR Sensors (Entry & Exit)

## Software Used

- Verilog HDL
- Xilinx Vivado

## System Architecture

[Insert Block Diagram Image]

## Working Principle

1. Entry sensor detects vehicle.
2. Available slot count decreases.
3. Entry gate opens automatically.
4. Exit sensor detects vehicle leaving.
5. Available slot count increases.
6. Display updates continuously.
7. When slots reach zero, display shows FULL.

## Project Structure

src/
testbench/
docs/
images/

## Simulation Results

### Behavioral Simulation

![Waveform](images/waveform.png)

### RTL Schematic

![RTL](images/rtl_design.png)

## Future Enhancements

- IoT Integration
- Mobile Application
- Cloud Monitoring
- Number Plate Recognition
- AI-Based Parking Prediction

## Author

Mani Kandan
B.E Electrical and Electronics Engineering
