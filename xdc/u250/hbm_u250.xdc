# No HBM on the u250, fake the pin to keep compatibility with HBM boards
set_property PACKAGE_PIN AR20     [get_ports hbm_cattrip]; # Bank 64 VCCO - VCC1V8 Net "GPIO_MSP0" - IO_T0U_N12_VRP_64
set_property IOSTANDARD  LVCMOS12 [get_ports hbm_cattrip]; # Bank 64 VCCO - VCC1V8 Net "GPIO_MSP0" - IO_T0U_N12_VRP_64
set_property PULLTYPE PULLDOWN    [get_ports hbm_cattrip]
