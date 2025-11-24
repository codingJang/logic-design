## This file is a constraints template for the Basys3 board
## To use it in your project, uncomment and modify the appropriate lines

## Clock signal (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
    create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Switches
set_property PACKAGE_PIN V17 [get_ports {mode_sw[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {mode_sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {mode_sw[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {mode_sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {mode_sw[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {mode_sw[2]}]
set_property PACKAGE_PIN W17 [get_ports reset]
    set_property IOSTANDARD LVCMOS33 [get_ports reset]

## LEDs
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
set_property PACKAGE_PIN V3 [get_ports {led[9]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
set_property PACKAGE_PIN W3 [get_ports {led[10]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
set_property PACKAGE_PIN U3 [get_ports {led[11]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
set_property PACKAGE_PIN P3 [get_ports {led[12]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
set_property PACKAGE_PIN N3 [get_ports {led[13]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
set_property PACKAGE_PIN P1 [get_ports {led[14]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
set_property PACKAGE_PIN L1 [get_ports {led[15]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]

## 7-Segment Display
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

set_property PACKAGE_PIN U2 [get_ports {an[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

## Buttons (5-way directional + GO/STOP)
set_property PACKAGE_PIN U18 [get_ports btn_confirm]
    set_property IOSTANDARD LVCMOS33 [get_ports btn_confirm]
set_property PACKAGE_PIN T18 [get_ports btn_up]
    set_property IOSTANDARD LVCMOS33 [get_ports btn_up]
set_property PACKAGE_PIN W19 [get_ports btn_left]
    set_property IOSTANDARD LVCMOS33 [get_ports btn_left]
set_property PACKAGE_PIN T17 [get_ports btn_right]
    set_property IOSTANDARD LVCMOS33 [get_ports btn_right]
set_property PACKAGE_PIN U17 [get_ports btn_down]
    set_property IOSTANDARD LVCMOS33 [get_ports btn_down]
set_property PACKAGE_PIN N17 [get_ports btn_go_stop]
    set_property IOSTANDARD LVCMOS33 [get_ports btn_go_stop]

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]


## ==============================================================
## IMPORTANT NOTES:
## ==============================================================
##
## 1. This constraints file is configured for the Basys3 FPGA board
##    If you are using a different board, you MUST modify the pin assignments
##
## 2. Pin assignments in this file:
##    - clk: W5 (100 MHz system clock)
##    - reset: W17 (leftmost switch - SW3)
##    - mode_sw[2:0]: W16, V16, V17 (SW2, SW1, SW0)
##    - led[15:0]: 16 LEDs on the board
##    - seg[6:0]: 7-segment cathodes
##    - an[3:0]: 7-segment anodes
##    - Buttons: 5-way directional pad + 1 additional button
##
## 3. Mode selection:
##    - Mode1: mode_sw = 001 (SW0 up)
##    - Mode2: mode_sw = 011 (SW0, SW1 up)
##    - Mode3: mode_sw = 111 (SW0, SW1, SW2 up)
##
## 4. Reset operation:
##    - Reset switch UP: reset active (holds reset)
##    - Reset switch DOWN: reset inactive (normal operation)
##
## 5. Button debouncing:
##    - This design does not include hardware debouncing
##    - You may need to add button debouncing logic if you experience issues
##
## ==============================================================
