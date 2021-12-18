#------------------------------------------------------------------------
# reportCriticalPaths
#------------------------------------------------------------------------
# Assigns the results of the report_timing command to the
# $report Tcl variable, using -return_string. The string is processed to extract the start
# point, end point, path group and path type of each path. After the path information is
# extracted, a summary of that path is printed to the Tcl console.
#------------------------------------------------------------------------

proc showCriticalPath { } {

	set report [report_timing -return_string -max_paths 10]
	set startPoint {}
	set endPoint {}
	set pathGroup {}
	set pathType {}

	# Write the header for string output
	puts [format " %-12s %-12s %-20s -> %-20s" "Path Type" "Path Group" "Start Point" "End Point"]
	puts [format " %-12s %-12s %-20s -> %-20s" "---------" "----------" "-----------" "---------"]
	# Split the return string into multiple lines to allow line by line processing
	foreach line [split $report \n] {
		if {[regexp -nocase -- {^\s*Source:\s*([^[:blank:]]+)((\s+\(?)|$)} $line - startPoint]} {
		} elseif {[regexp -nocase -- {^\s*Destination:\s*([^[:blank:]]+)((\s+\(?)|$)} $line - endPoint]} {
		} elseif {[regexp -nocase -- {^\s*Path Group:\s*([^[:blank:]]+)\s*$} $line - pathGroup]} {
		} elseif {[regexp -nocase -- {^\s*Path Type:\s*([^[:blank:]]+)((\s+\(?)|$)} $line - pathType]} {
		puts [format " %-12s %-12s %-20s -> %-20s" $pathType $pathGroup $startPoint $endPoint]
		}
	}

}

#------------------------------------------------------------------------
# reportCriticalPaths
#------------------------------------------------------------------------
# This function generates a CSV file that provides a summary of the first
# 50 violations for both Setup and Hold analysis. So a maximum number of
# 100 paths are reported.
#------------------------------------------------------------------------
proc reportCriticalPaths { fileName } {
	# Open the specified output file in write mode
	set FH [open $fileName w]
	# Write the current date and CSV format to a file header
	puts $FH "#\n# File created on [clock format [clock seconds]]\n#\n"
	puts $FH "Startpoint,Endpoint,DelayType,Slack,#Levels,#LUTs"
	# Iterate through both Min and Max delay types
	foreach delayType {max min} {
		# Collect details from the 50 worst timing paths for the current analysis
		# (max = setup/recovery, min = hold/removal)
		# The $path variable contains a Timing Path object.
		
		foreach path [get_timing_paths -delay_type $delayType -max_paths 50 -nworst 1] {
		# Get the LUT cells of the timing paths
		set luts [get_cells -filter {REF_NAME =~ LUT*} -of_object $path]
		
		# Get the startpoint of the Timing Path object
		set startpoint [get_property STARTPOINT_PIN $path]
		
		# Get the endpoint of the Timing Path object
		set endpoint [get_property ENDPOINT_PIN $path]
		
		# Get the slack on the Timing Path object
		set slack [get_property SLACK $path]
		
		# Get the number of logic levels between startpoint and endpoint
		set levels [get_property LOGIC_LEVELS $path]
		
		# Save the collected path details to the CSV file
		puts $FH "$startpoint,$endpoint,$delayType,$slack,$levels,[llength $luts]"
		}
	}
	# Close the output file
	close $FH
	puts "CSV file $fileName has been created.\n"
	return 0
}; # End PROC

#------------------------------------------------------------------------
# routeCriticalPaths
#------------------------------------------------------------------------
# The strategy in this sample script is to identify the top 10 critical paths using 
# get_timing_paths, create a list of the net objects ($preRoutes) of those critical paths 
# using get_cells -of, and then route those nets first.
# The script continues after routing the pre-route nets. After route_design completes, 
# the Vivado router unroutes all of the nets in instance u0/u1, then re-routes identified 
# critical nets first, myCritNets. Then the general router finishes any remaining unrouted nets.
#------------------------------------------------------------------------

proc routeCriticalPaths { } {

	route_design -no_timing_driven
	set preRoutes [get_nets -of [get_timing_paths -max_paths 10]]
	## Mirar aquí el slack y si se está muy lejos de cerrar timing
	## En ese caso, se puede rutar de nuevo sólo las rutas críticas (reentrante)
	route_design -nets [get_nets $preRoutes] -delay
	## Y luego el resto

	## Se puede hacer a nivel de cell. Se des-ruta una cell y se trata
	## de cerrar timing empezando por las rutas críticas ¿QDMA?
	#Unroute all the nets in u0/u1, and route the critical nets first
	route_design -unroute [get_nets u0/u1/*]
	route_design -delay -nets [get_nets $myCritNets]

	## Para obtener la localización de la lógica de la ruta crítica:

	get_property LOC [get_cells -of [get_timing_paths -max_paths 10]]
	## Ver página 64 del siguiente documento: 
	## https://www.xilinx.com/support/documentation/sw_manuals/xilinx2012_4/ug904-vivado-implementation.pdf
	## Puede ser interesante fijar el lugar de los elementos de la ruta crítica. Si hemos obtenido 
	## una implementación exitosa, se puede almacenar y luego cargar la localización de dichos elementos.
	## Rutar de nuevo las nets críticas

	set critical_nets [get_nets -of [get_timing_paths -max_paths 85]]

	route_design -nets $critical_nets

}

proc smartFlow { } {

	## Add SLR directives
	set directives "Explore \
					WLDrivenBlockPlacement \
					ExtraNetDelay_high \
					ExtraNetDelay_low \
					AltSpreadLogic_high \
					AltSpreadLogic_medium \
					AltSpreadLogic_low \
					ExtraPostPlacementOpt \
					ExtraTimingOpt"
					
	# empty list for results
	set wns_results ""
	# empty list for time elapsed messages
	set time_msg ""

	foreach oneDirective $directives {
		# open post opt design checkpoint
		open_checkpoint $PROJ_DIR/${PROJ_NM}_post_opt.dcp
		# run place design with a different directive
		place_design -directive $oneDirective
		# append time elapsed message to time_msg list
		lappend time_msg [exec grep "place_design: Time (s):" vivado.log | tail -1]
		# append wns result to our results list
		set WNS [ get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup] ]
		append wns_results $WNS " "
	}
	
	# print out results at end
	set i 0
	foreach oneDirective $directives {
		puts "Post Place WNS with directive $oneDirective = [lindex $wns_results $i] "
		puts [lindex $time_msg [expr $i*2]]
		puts " "
		incr i
	}



}