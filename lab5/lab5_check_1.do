onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab5_check_1/Z
add wave -noupdate /lab5_check_1/writenum
add wave -noupdate /lab5_check_1/write
add wave -noupdate /lab5_check_1/sout
add wave -noupdate /lab5_check_1/shift
add wave -noupdate /lab5_check_1/readnum
add wave -noupdate /lab5_check_1/in
add wave -noupdate /lab5_check_1/err
add wave -noupdate /lab5_check_1/data_out
add wave -noupdate /lab5_check_1/data_in
add wave -noupdate /lab5_check_1/clk
add wave -noupdate /lab5_check_1/Bin
add wave -noupdate /lab5_check_1/aout
add wave -noupdate /lab5_check_1/ALUop
add wave -noupdate /lab5_check_1/Ain
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4 ps} 0}
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
WaveRestoreZoom {0 ps} {16 ps}
