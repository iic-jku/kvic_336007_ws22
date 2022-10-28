# User config
set ::env(DESIGN_NAME) audiodac
#set ::env(DESIGN_IS_CORE) "0"

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# Fill this
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk_i"

# Set pin order in file
set ::env(FP_PIN_ORDER_CFG) $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/pin_order.cfg
#set ::env(FP_IO_MIN_DISTANCE) "2"
set ::env(FP_IO_MODE) "0"

# Enable a power ring around the macro
set ::env(FP_PDN_CORE_RING) "1"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
