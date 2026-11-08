onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Controle
add wave -noupdate -label clk /tb_spi_system/clk
add wave -noupdate -label start /tb_spi_system/start
add wave -noupdate -label peripheral_sel /tb_spi_system/sel
add wave -noupdate -label busy /tb_spi_system/busy
add wave -noupdate -label done /tb_spi_system/done
add wave -noupdate -divider SPI
add wave -noupdate -label sclk /tb_spi_system/sclk
add wave -noupdate -label cs_n -radix binary /tb_spi_system/cs_n
add wave -noupdate -label copi /tb_spi_system/copi
add wave -noupdate -label cipo /tb_spi_system/cipo
add wave -noupdate -divider {Saidas paralelas}
add wave -noupdate -label ctrl_out -radix hexadecimal /tb_spi_system/c_out
add wave -noupdate -label p0_out -radix hexadecimal /tb_spi_system/p0_out
add wave -noupdate -label p1_out -radix hexadecimal /tb_spi_system/p1_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4311527 ps} 0}
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
WaveRestoreZoom {4597454 ps} {5541174 ps}
