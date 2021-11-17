onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab5_check_4/Z_out
add wave -noupdate /lab5_check_4/writenum
add wave -noupdate /lab5_check_4/write
add wave -noupdate /lab5_check_4/vsel
add wave -noupdate /lab5_check_4/shift
add wave -noupdate /lab5_check_4/readnum
add wave -noupdate /lab5_check_4/R7
add wave -noupdate /lab5_check_4/R6
add wave -noupdate /lab5_check_4/R5
add wave -noupdate /lab5_check_4/R4
add wave -noupdate /lab5_check_4/R3
add wave -noupdate /lab5_check_4/R2
add wave -noupdate /lab5_check_4/R1
add wave -noupdate /lab5_check_4/R0
add wave -noupdate /lab5_check_4/loads
add wave -noupdate /lab5_check_4/loadc
add wave -noupdate /lab5_check_4/loadb
add wave -noupdate /lab5_check_4/loada
add wave -noupdate /lab5_check_4/err
add wave -noupdate /lab5_check_4/datapath_out
add wave -noupdate /lab5_check_4/datapath_in
add wave -noupdate /lab5_check_4/clk
add wave -noupdate /lab5_check_4/bsel
add wave -noupdate /lab5_check_4/asel
add wave -noupdate /lab5_check_4/ALUop
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30 ps} 0}
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
WaveRestoreZoom {31 ps} {95 ps}
