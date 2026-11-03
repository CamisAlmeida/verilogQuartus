onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_Rd_74HC166/clk
add wave -noupdate /tb_Rd_74HC166/clr_n
add wave -noupdate /tb_Rd_74HC166/clk_inh
add wave -noupdate /tb_Rd_74HC166/shift_load_n
add wave -noupdate /tb_Rd_74HC166/serial_in
add wave -noupdate -radix binary /tb_Rd_74HC166/parallel_in
add wave -noupdate /tb_Rd_74HC166/serial_out
add wave -noupdate /tb_Rd_74HC166/i
add wave -noupdate -radix binary /tb_Rd_74HC166/lido
add wave -noupdate /tb_Rd_74HC166/erros
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {62741 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {138437 ps}
