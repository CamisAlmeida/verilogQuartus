transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog  -work work +incdir+C:/camis/quartus/verilogQuartus/somador4bits {C:/camis/quartus/verilogQuartus/somador4bits/somadorCompleto.v}
vlog  -work work +incdir+C:/camis/quartus/verilogQuartus/somador4bits {C:/camis/quartus/verilogQuartus/somador4bits/somador4bits.v}

