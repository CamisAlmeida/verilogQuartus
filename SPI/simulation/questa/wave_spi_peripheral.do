onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_spi_peripheral/clk
add wave -noupdate /tb_spi_peripheral/clr_n
add wave -noupdate /tb_spi_peripheral/parallel_load
add wave -noupdate -radix binary /tb_spi_peripheral/parallel_in
add wave -noupdate /tb_spi_peripheral/parallel_out
add wave -noupdate /tb_spi_peripheral/rx_valid
add wave -noupdate /tb_spi_peripheral/sclk
add wave -noupdate /tb_spi_peripheral/cs_n
add wave -noupdate /tb_spi_peripheral/copi
add wave -noupdate /tb_spi_peripheral/cipo
add wave -noupdate /tb_spi_peripheral/rx_pulses
add wave -noupdate /tb_spi_peripheral/erros
add wave -noupdate /tb_spi_peripheral/tx_seen
add wave -noupdate /tb_spi_peripheral/antes
add wave -noupdate /tb_spi_peripheral/pulsos_antes
add wave -noupdate /tb_spi_peripheral/cipo_antes
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {485227 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
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
WaveRestoreZoom {0 ps} {6200128 ps}
