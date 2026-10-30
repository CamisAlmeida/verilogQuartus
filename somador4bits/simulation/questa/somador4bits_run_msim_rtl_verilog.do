transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog  -work work +incdir+/home/camis/Documentos/verilogQuartus/somador4bits {/home/camis/Documentos/verilogQuartus/somador4bits/somadorCompleto.v}
vlog  -work work +incdir+/home/camis/Documentos/verilogQuartus/somador4bits {/home/camis/Documentos/verilogQuartus/somador4bits/somador4bits.v}

