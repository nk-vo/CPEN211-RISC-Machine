onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab5_check_2/writenum
add wave -noupdate /lab5_check_2/write
add wave -noupdate /lab5_check_2/sout
add wave -noupdate /lab5_check_2/shift
add wave -noupdate /lab5_check_2/readnum
add wave -noupdate /lab5_check_2/out
add wave -noupdate /lab5_check_2/in
add wave -noupdate /lab5_check_2/err_sh
add wave -noupdate /lab5_check_2/err_rf
add wave -noupdate /lab5_check_2/err_ALU
add wave -noupdate /lab5_check_2/err
add wave -noupdate /lab5_check_2/data_out
add wave -noupdate /lab5_check_2/data_in
add wave -noupdate /lab5_check_2/clk
add wave -noupdate /lab5_check_2/Z
add wave -noupdate /lab5_check_2/Bin
add wave -noupdate /lab5_check_2/Ain
add wave -noupdate /lab5_check_2/ALUop
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {64 ps}
