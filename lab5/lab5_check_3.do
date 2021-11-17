onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab5_check_3/tb_err
add wave -noupdate /lab5_check_3/TB/writenum
add wave -noupdate /lab5_check_3/TB/write
add wave -noupdate /lab5_check_3/TB/vsel
add wave -noupdate /lab5_check_3/TB/shift
add wave -noupdate /lab5_check_3/TB/readnum
add wave -noupdate /lab5_check_3/TB/loads
add wave -noupdate /lab5_check_3/TB/loadc
add wave -noupdate /lab5_check_3/TB/loadb
add wave -noupdate /lab5_check_3/TB/loada
add wave -noupdate /lab5_check_3/TB/err
add wave -noupdate /lab5_check_3/TB/datapath_out
add wave -noupdate /lab5_check_3/TB/datapath_in
add wave -noupdate /lab5_check_3/TB/clk
add wave -noupdate /lab5_check_3/TB/bsel
add wave -noupdate /lab5_check_3/TB/asel
add wave -noupdate /lab5_check_3/TB/Z_out
add wave -noupdate /lab5_check_3/TB/R7
add wave -noupdate /lab5_check_3/TB/R6
add wave -noupdate /lab5_check_3/TB/R5
add wave -noupdate /lab5_check_3/TB/R4
add wave -noupdate /lab5_check_3/TB/R3
add wave -noupdate /lab5_check_3/TB/R2
add wave -noupdate /lab5_check_3/TB/R1
add wave -noupdate /lab5_check_3/TB/R0
add wave -noupdate /lab5_check_3/TB/ALUop
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {39 ps} 0}
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
WaveRestoreZoom {0 ps} {126 ps}
