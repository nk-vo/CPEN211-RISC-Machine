onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/clk
add wave -noupdate /cpu_tb/reset
add wave -noupdate /cpu_tb/s
add wave -noupdate /cpu_tb/load
add wave -noupdate /cpu_tb/err
add wave -noupdate /cpu_tb/in
add wave -noupdate /cpu_tb/out
add wave -noupdate /cpu_tb/N
add wave -noupdate /cpu_tb/V
add wave -noupdate /cpu_tb/Z
add wave -noupdate /cpu_tb/w
add wave -noupdate /cpu_tb/R0
add wave -noupdate /cpu_tb/R1
add wave -noupdate /cpu_tb/R2
add wave -noupdate /cpu_tb/R3
add wave -noupdate /cpu_tb/R4
add wave -noupdate /cpu_tb/R5
add wave -noupdate /cpu_tb/R6
add wave -noupdate /cpu_tb/R7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200 ps} 0}
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
WaveRestoreZoom {0 ps} {1 ns}
