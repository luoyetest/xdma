#############SPI Configurate Setting##################
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


set_property PACKAGE_PIN B18 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
###############################################################################
set_false_path -from [get_ports sys_rst_n]
################################################################################

set_property LOC IBUFDS_GTE2_X0Y1 [get_cells refclk_ibuf]
set_property PACKAGE_PIN U8 [get_ports sys_clk_p]

###############################################################################
# Timing Constraints
###############################################################################

create_clock -period 10.000 -name sys_clk [get_ports sys_clk_p]


set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN A22 [get_ports {led[0]}]
set_property PACKAGE_PIN C19 [get_ports {led[1]}]
set_property PACKAGE_PIN B19 [get_ports {led[2]}]
set_property PACKAGE_PIN E18 [get_ports {led[3]}]
