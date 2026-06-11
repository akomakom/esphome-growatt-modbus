# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview
ESPHome YAML configurations for Growatt SPH 10000TL-HU-US-B solar inverter integration via RS485 Modbus and CAN bus. No build system - files are deployed directly to ESPHome Builder/Dashboard.

## File Structure and Workflow

### Root Level YAML Files
Root level `.yaml` files (e.g., `esphome-growatt-sph1000tl-hu-us-b.yaml`) are **fragments** meant to be appended to user's ESPHome config AFTER the ESPHome-generated header containing secure variables (WiFi credentials, API keys, etc.). These are committed to the repository.

### .wip/ Directory (Gitignored)
`.wip/*.yaml` files contain the EXACT same configuration WITH the user's sensitive secure header prepended, making them complete and ready to paste directly into ESPHome. These are NOT committed.

**Important**: When making changes, update BOTH versions in sync:
- Root level file (for committing)
- `.wip/` file (for testing)

### CAN Bus Variants
Files with `can` in the name are **unfinished and untested**. Primary development focus is on plain Modbus variants.

## Critical Hardware-Specific Requirements

### RS485 Modbus Configuration (Non-Standard)
- **Baud rate MUST be 115200** (not the typical 9600) - SPH 10000TL-HU-US uses non-standard rate
- **send_wait_time: 100ms** is critical - inverter needs significantly more time between commands than typical Modbus devices
- **command_throttle: 50ms** must match send_wait_time for consistency
- **rx_buffer_size: 256** required for reliable operation with 50+ sensors
- **Terminating resistor is mandatory** on RS485 module side
- **Ground connection (RJ45 pin 5)** is optional but dramatically improves reliability

### RJ45 Pinout (Non-Standard)
CN5 "Upper Computer" port uses custom pinout:
- Pin 1: RS485 B- (Orange/White in T568B)
- Pin 2: RS485 A+ (Orange in T568B)  
- Pin 5: RS485 Ground (Blue/White in T568B) - recommended for stability

### Time Sync Sequence (Critical Order)
Modbus time writes to registers 45-50 MUST be sequential with seconds LAST:
1. Write registers 45-49 (year, month, day, hour, minute)
2. Write register 50 (seconds) - acts as internal latch/execution trigger
Writing out of order or using batch writes will fail silently.

Holding register 48 contains current hour for verification.

## ESPHome YAML Patterns

### Outlier Filter Pattern
Custom lambda filter `&outlier_lambda` rejects >1000x spikes (common with cheap RS485 modules):
```yaml
.outlier_lambda: &outlier_lambda
  lambda: |-
    static float last_valid = NAN;
    if (!isnan(last_valid) && last_valid > 0.0f && x > last_valid * 1000.0f) {
      return {};  // reject extreme outlier
    }
    last_valid = x;
    return x;
```
Apply with `<<: *outlier_lambda` in sensor filters.

### Skip Updates Pattern
Use `skip_updates: ${skip_count_for_counters}` for infrequently-changing values to reduce Modbus load. Substitutions define skip counts for different sensor types (counters, temperature, less-used).

### YAML Section Structure (Critical)
**Each YAML section type (sensor:, switch:, text_sensor:, etc.) must appear ONLY ONCE** in the file. Add new items as list entries under the existing section, never create duplicate sections. This is a YAML requirement that will cause parsing errors if violated.

**Within each sensor/component definition, each property key must also appear only once.** Duplicate keys like `value_type:` appearing twice in the same sensor will cause parsing errors. When editing, ensure you're not leaving duplicate properties behind.

### Display Staleness Detection
Display configs track `last_update_time` global variable updated via `on_value` callbacks to detect stale data (>60s = offline indicator).

## CAN Bus (Arduino/ESP32-C6)

### TWAI v2 API Required
ESP32-C6 uses TWAI driver v2 API (`twai_driver_install_v2`, `twai_transmit_v2`, etc.) - v1 API will not compile.

### Transceiver Control Pins
GPIO 0-3 control TJA1051T/3 transceivers - MUST be driven LOW before CAN init:
- GPIO 0: CAN0 RS (High-Speed mode)
- GPIO 1: CAN1 RS (High-Speed mode)
- GPIO 2: CAN1 Shutdown (Wake)
- GPIO 3: CAN0 Shutdown (Wake)

### Timing Configuration
500kbps on ESP32-C6 requires specific timing (not auto-calculated):
```c
twai_timing_config_t t_config = {
    .clk_src = TWAI_CLK_SRC_DEFAULT,
    .brp = 8, .tseg_1 = 8, .tseg_2 = 3, .sjw = 3
};
```

## Additional Files
- Display configs: `displays/oled-127x64/` - separate from main config, references Home Assistant entities
- Arduino CAN: `canbus-mim-arduino/` - man-in-middle for CAN bus manipulation
- Reference docs: `reference/` - Modbus protocol PDFs and CSV register maps

## Modbus Register Addresses
Addresses determined by trial-and-error and reference CSV files (not official Growatt docs). Register 0 = inverter status is reliable anchor point. Many addresses in protocol docs are incorrect for this model.