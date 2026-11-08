onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_sipo8/clk
add wave -noupdate /tb_sipo8/clr_n
add wave -noupdate /tb_sipo8/sample
add wave -noupdate /tb_sipo8/last_bit
add wave -noupdate /tb_sipo8/serial_in
add wave -noupdate -radix hexadecimal /tb_sipo8/parallel_out
add wave -noupdate /tb_sipo8/valid
add wave -noupdate /tb_sipo8/valid_count
add wave -noupdate -radix hexadecimal /tb_sipo8/ref_sr
add wave -noupdate /tb_sipo8/ref_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {196640 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 132
configure wave -valuecolwidth 67
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
WaveRestoreZoom {0 ps} {367376 ps}
