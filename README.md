Direct Growatt - RS485 - Home Assistant integration
----

# What This Is

This project aims to interface Home Assistant with a Solar inverter (focusing on Growatt) directly via RS485 (Modbus),
eliminating intermediaries like SA.

Currently data for most telemetry can be extracted in realtime.  Controlling the inverter is not yet supported.

# Hardware Requirements

* Currently only tested with the Growatt SPH 10000TL-HU-US-B
* A Microcontroller like an ESP32  (This example uses a generic ESP32-C6, but custom devices like LilyGO T-CAN485 may be simpler)
* A RS485 module for the microcontroller (If not built-in).  I used a HiLetgo TTL to RS485 because it works at 3.3v like the ESP32.

# Pinout

| Pin | Function | T568B Cable Colors |
| --- | --- | --- |
| 1 | RS485 B- | Orange/White |
| 2 | RS485 A+ | Orange |


# Software Requirements

* Home Assistant (you can use docker)
* ESPHome Builder (you can use docker)

# Installation

* Follow the ESPHome Builder instructions to install ESPHome on your microcontroller.  You may need to use web.esphome.io to initialize a new MCU.
* Create a new ESPHome device in ESPHome Builder.  
* Ensure that the auto-generated config loads on the microcontroller.  
* Add the contents of the yaml file in this repo to the yaml file in ESPHome Builder, and reinstall.
* The device should appear in Home Assistant.



