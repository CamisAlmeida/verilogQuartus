onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Rd_74HC166/clk
add wave -noupdate /Rd_74HC166/clr_n
add wave -noupdate /Rd_74HC166/clk_inh
add wave -noupdate /Rd_74HC166/shift_load_n
add wave -noupdate /Rd_74HC166/serial_in
add wave -noupdate /Rd_74HC166/shift_reg
add wave -noupdate /Rd_74HC166/parallel_in
add wave -noupdate /Rd_74HC166/serial_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
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
WaveRestoreZoom {0 ns} {113 ns}
