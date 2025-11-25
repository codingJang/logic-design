# Vivado Project Rebuild Script
# Logic Design Term Project - FPGA Game System

# Project name and directories
set project_name "logic_design_project"
set project_root [file normalize .]
set project_dir  [file normalize "$project_root/project_1"]

# Create (or recreate) the project directory
file mkdir $project_dir

# Create project
create_project $project_name $project_dir -part xc7a35tcpg236-1 -force

# Project properties
set_property target_language     Verilog [current_project]
set_property simulator_language  Verilog [current_project]

# Add Verilog source files
add_files -norecurse [list \
    [file normalize "rtl/top_module.v"] \
    [file normalize "rtl/mode1_number_baseball.v"] \
    [file normalize "rtl/mode2_led_count.v"] \
    [file normalize "rtl/mode3_credits.v"] \
    [file normalize "rtl/seg_display_controller.v"] \
    [file normalize "rtl/button_debouncer.v"] \
]

# Add constraints file
add_files -fileset constrs_1 -norecurse [file normalize "cons/constraints.xdc"]

# Set top module
set_property top top_module [current_fileset]

# Update compile order
update_compile_order -fileset sources_1

puts "Vivado project created successfully."
puts "Project location: $project_dir"
puts ""
puts "Next steps in Vivado GUI:"
puts "  1. Open the project at: $project_dir"
puts "  2. Run Synthesis"
puts "  3. Run Implementation"
puts "  4. Generate Bitstream"
puts "  5. Program FPGA (Basys3)"

