#CMS IP XDC constraints file

#Satellite UART
set_property PACKAGE_PIN BJ42 [get_ports satellite_uart_rxd]
set_property -dict {IOSTANDARD LVCMOS18} [get_ports satellite_uart_rxd]
set_property PACKAGE_PIN BH42 [get_ports satellite_uart_txd]
set_property -dict {IOSTANDARD LVCMOS18} [get_ports satellite_uart_txd]

#Satellite GPIO
set_property PACKAGE_PIN BE46 [get_ports satellite_gpio[0]]
set_property -dict {IOSTANDARD LVCMOS18} [get_ports satellite_gpio[0]]
set_property PACKAGE_PIN BH46 [get_ports satellite_gpio[1]]
set_property -dict {IOSTANDARD LVCMOS18} [get_ports satellite_gpio[1]]
set_property PACKAGE_PIN BF45 [get_ports satellite_gpio[2]]
set_property -dict {IOSTANDARD LVCMOS18} [get_ports satellite_gpio[2]]
set_property PACKAGE_PIN BF46 [get_ports satellite_gpio[3]]
set_property -dict {IOSTANDARD LVCMOS18} [get_ports satellite_gpio[3]]
