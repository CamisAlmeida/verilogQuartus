vlog -work work wave.vwf.vt
vsim -voptargs=+acc -c -t 1ps -L cyclonev_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.Rd_74HC166_vlg_vec_tst -voptargs="+acc"
add wave /*
run -all
