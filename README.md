Direct Growatt - RS485 - Home Assistant integration
----

# What This Is

This project aims to interface `Home Assistant` with a Solar inverter (focusing on Growatt) directly via RS485 (Modbus),
eliminating intermediaries like SA.

# Status

Currently data for most telemetry can be extracted in realtime.  Controlling the inverter is not yet(?) supported.

Feel free to submit PRs to fix any issues.

Feel free to submit PRs to add support for other inverters.

# Hardware Requirements

* Currently only tested with the Growatt `SPH 10000TL-HU-US-B` running HMI Version `SK110.04-08051`
* A Microcontroller like an `ESP32`.
   (I used a generic `ESP32-C6`, but custom devices like LilyGO T-CAN485 may be simpler.  There are also DIN rail mount packaged units - search "DIN rail ESP32 RS485").  If your device is in a junction box, adding an external antenna is helpful (most ESP32 devices are easily solder-modded for an external SMA antenna)
* A separate RS485 module for the microcontroller (If not built-in).  I used a HiLetgo TTL to RS485 because it works at 3.3v like the ESP32.  It's connected via 4 pins (UART): TX (6), RX (7), GND, VCC (see yaml)
* A sacrificial ethernet cable, cut in half (pinout below), connected to the RS485 module.

# Pinout

| RJ45 Pin | Function | T568B Cable Color |
| --- | --- | --- |
| 1 | RS485 B- | Orange/White |
| 2 | RS485 A+ | Orange |
| 5 | RS485 Ground (recommended) | Blue/White | 

* Terminating resistor is important on the RS485 module side
* Ground connection is optional but improves reliability.
With both in place, 50 sensors can be polled at 5s interval without any modbus errors.

# Software Requirements

* Home Assistant (you can use docker)
* ESPHome Builder (you can use docker as well, can be installed on a different machine)

# Installation

* Follow the ESPHome Builder instructions to install ESPHome on your microcontroller.  You may need to use web.esphome.io to initialize a new MCU.
* Create a new ESPHome device in ESPHome Builder.  It will generate the top of your yaml file with MCU and authentication details.
* Ensure that the auto-generated config loads on the microcontroller (it will do nothing)  
* The device should appear in Home Assistant.
* Add the contents of the yaml file in this repo to the yaml file in ESPHome Builder, and reinstall.

# Notes

* There are additional commented out sensors that can be enabled if desired (see yaml).
* Addresses were determined by trial and error and this [datasheet](https://github.com/HotNoob/PythonProtocolGateway/blob/main/protocols/growatt/growatt_2020_v1.24.input_registry_map.csv) - a copy of this file is in the repo.


# Results

Manually Created Dashboard
![Example Visualization](readme/ha-graphs-example1.png)

Misc values |  More Values
:-------------------------:|:-------------------------:
![Example Data Values](readme/ha-overview-example1.png) | ![Example Data Values](readme/ha-overview-example4.png)

# References

* Modbus in ESPHome
   * https://esphome.io/components/modbus_controller/
   * https://esphome.io/components/sensor/
* 