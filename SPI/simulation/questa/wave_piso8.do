onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_piso8/clk
add wave -noupdate /tb_piso8/clr_n
add wave -noupdate /tb_piso8/load
add wave -noupdate /tb_piso8/shift
add wave -noupdate /tb_piso8/parallel_in
add wave -noupdate /tb_piso8/serial_out
add wave -noupdate -radix binary /tb_piso8/carga
add wave -noupdate -radix hexadecimal /tb_piso8/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {108415 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {131072 ps}
