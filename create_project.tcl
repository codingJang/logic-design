# Vivado Project Creation Script
# Logic Design Term Project - FPGA Game System
# Team: 장예준, 홍연수, 변준우

# Set project name and directory
set project_name "logic_design_project"
set project_dir "[file normalize .]"

# Create project
create_project ${project_name} ${project_dir}/${project_name} -part xc7a35tcpg236-1 -force

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Verilog [current_project]

# Add Verilog source files
add_files -norecurse {
    top_module.v
    mode1_number_baseball.v
    mode2_led_count.v
    mode3_credits.v
    seg_display_controller.v
    button_debouncer.v
}

# Add constraints file
add_files -fileset constrs_1 -norecurse constraints.xdc

# Set top module
set_property top top_module [current_fileset]

# Update compile order
update_compile_order -fileset sources_1

puts "Project created successfully!"
puts "Project location: ${project_dir}/${project_name}"
puts ""
puts "Next steps:"
puts "1. Review the source files"
puts "2. Run Synthesis: click 'Run Synthesis' in Vivado Flow Navigator"
puts "3. Run Implementation: click 'Run Implementation' after synthesis"
puts "4. Generate Bitstream: click 'Generate Bitstream' after implementation"
puts "5. Program FPGA: Connect your Basys3 board and click 'Program Device'"
puts ""
puts "Team Members:"
puts "  1. 장예준 (Jang Ye Jun) - JYJ"
puts "  2. 홍연수 (Hong Yeon Su) - HYS"
puts "  3. 변준우 (Byeon Jun U) - BJW"
