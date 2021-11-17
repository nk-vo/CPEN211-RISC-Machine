onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab5_check_2/T2/sout
add wave -noupdate /lab5_check_2/T2/shift
add wave -noupdate /lab5_check_2/T2/in
add wave -noupdate /lab5_check_2/T2/err
add wave -noupdate /lab5_check_2/T2/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22 ps} 0}
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
WaveRestoreZoom {16 ps} {48 ps}
