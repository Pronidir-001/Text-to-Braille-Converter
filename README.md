# Text-to-Braille-Converter
A text-to-braille converter that takes the input text via keyboard (Putty is used this case) and output the relevant braille pattern for each letter and letter by letter though a six-solenoid braille element.

## Overview
This project is a hardware-based system designed to convert standard text input into Braille output for the visually impaired. It utilizes a microcontroller to process characters and drive a Braille display consisting of magnetic solenoids.

The project includes the firmware code written in Assembly and a full hardware simulation using Proteus Design Suite.

## Features
- **Real-time Conversion:** Instantly converts alphanumeric characters to Braille patterns.
- **Hardware Simulation:** Fully testable circuit design included (`.pdsprj` file).
- **Efficient Firmware:** Optimized Assembly code for  ATmega328p.
- **Accessible Output** Braille Element cosisting of 6 magnetic solenoids for "feel"

## Technology Stack
- **IDE:** Atmel Studio (Microchip Studio)
- **Simulation:** Proteus Design Suite 8
- **Language:** Assembly
- **Microcontroller:** ATmega328p

## Project Structure
```text
├── code_file/          # Source code and Atmel Studio solution
├── simulation/         # Proteus simulation files (.pdsprj)
└── README.md           # Project documentation
