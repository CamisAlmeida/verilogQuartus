transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog  -work work +incdir+/home/camis/Documentos/verilogQuartus/Rd_74HC166 {/home/camis/Documentos/verilogQuartus/Rd_74HC166/flipFlopD.v}
vlog  -work work +incdir+/home/camis/Documentos/verilogQuartus/Rd_74HC166 {/home/camis/Documentos/verilogQuartus/Rd_74HC166/entradaD.v}
vlog  -work work +incdir+/home/camis/Documentos/verilogQuartus/Rd_74HC166 {/home/camis/Documentos/verilogQuartus/Rd_74HC166/Rd_74HC166.v}

