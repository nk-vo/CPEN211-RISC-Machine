onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab8_stage2_tb/err
add wave -noupdate /lab8_stage2_tb/CLOCK_50
add wave -noupdate /lab8_stage2_tb/break
add wave -noupdate -divider DUT
add wave -noupdate /lab8_stage2_tb/DUT/clk
add wave -noupdate /lab8_stage2_tb/DUT/reset
add wave -noupdate /lab8_stage2_tb/DUT/s
add wave -noupdate /lab8_stage2_tb/DUT/load
add wave -noupdate /lab8_stage2_tb/DUT/N
add wave -noupdate /lab8_stage2_tb/DUT/V
add wave -noupdate /lab8_stage2_tb/DUT/Z
add wave -noupdate /lab8_stage2_tb/DUT/w
add wave -noupdate /lab8_stage2_tb/DUT/read_data
add wave -noupdate /lab8_stage2_tb/DUT/write_data
add wave -noupdate /lab8_stage2_tb/DUT/mem_addr
add wave -noupdate /lab8_stage2_tb/DUT/mem_cmd
add wave -noupdate /lab8_stage2_tb/DUT/msel
add wave -noupdate /lab8_stage2_tb/DUT/mem_write
add wave -noupdate /lab8_stage2_tb/DUT/dout
add wave -noupdate /lab8_stage2_tb/DUT/switch_enable
add wave -noupdate /lab8_stage2_tb/DUT/load_led
add wave -noupdate -divider CPU
add wave -noupdate /lab8_stage2_tb/DUT/CPU/curr_instruct
add wave -noupdate /lab8_stage2_tb/DUT/CPU/opcode
add wave -noupdate /lab8_stage2_tb/DUT/CPU/op
add wave -noupdate /lab8_stage2_tb/DUT/CPU/sximm5
add wave -noupdate /lab8_stage2_tb/DUT/CPU/sximm8
add wave -noupdate /lab8_stage2_tb/DUT/CPU/readnum
add wave -noupdate /lab8_stage2_tb/DUT/CPU/writenum
add wave -noupdate /lab8_stage2_tb/DUT/CPU/ALUop
add wave -noupdate /lab8_stage2_tb/DUT/CPU/shift
add wave -noupdate /lab8_stage2_tb/DUT/CPU/load_ir
add wave -noupdate /lab8_stage2_tb/DUT/CPU/nsel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/vsel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/write
add wave -noupdate /lab8_stage2_tb/DUT/CPU/loada
add wave -noupdate /lab8_stage2_tb/DUT/CPU/loadb
add wave -noupdate /lab8_stage2_tb/DUT/CPU/asel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/bsel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/loadc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/loads
add wave -noupdate /lab8_stage2_tb/DUT/CPU/load_pc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/reset_pc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/load_addr
add wave -noupdate /lab8_stage2_tb/DUT/CPU/addr_sel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/Z_out
add wave -noupdate /lab8_stage2_tb/DUT/CPU/C
add wave -noupdate /lab8_stage2_tb/DUT/CPU/PC
add wave -noupdate /lab8_stage2_tb/DUT/CPU/next_pc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/da_out
add wave -noupdate /lab8_stage2_tb/DUT/CPU/dp_pc
add wave -noupdate /lab8_stage2_tb/DUT/CPU/cond
add wave -noupdate /lab8_stage2_tb/DUT/CPU/sxim8
add wave -noupdate /lab8_stage2_tb/DUT/CPU/pc_offsetsel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/B
add wave -noupdate /lab8_stage2_tb/DUT/CPU/BEQ
add wave -noupdate /lab8_stage2_tb/DUT/CPU/BNE
add wave -noupdate /lab8_stage2_tb/DUT/CPU/BLT
add wave -noupdate /lab8_stage2_tb/DUT/CPU/BLE
add wave -noupdate /lab8_stage2_tb/DUT/CPU/BL
add wave -noupdate /lab8_stage2_tb/DUT/CPU/pc_offset
add wave -noupdate /lab8_stage2_tb/DUT/CPU/pc_ret
add wave -noupdate /lab8_stage2_tb/DUT/CPU/pc_addsel
add wave -noupdate /lab8_stage2_tb/DUT/CPU/pc_returnsel
add wave -noupdate -divider state
add wave -noupdate /lab8_stage2_tb/DUT/CPU/FSM/present_state
add wave -noupdate -divider REGDATA
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/REGFILE/R7
add wave -noupdate -divider result
add wave -noupdate {/lab8_stage2_tb/DUT/MEM/mem[25]}
add wave -noupdate -divider stack
add wave -noupdate {/lab8_stage2_tb/DUT/MEM/mem[255]}
add wave -noupdate {/lab8_stage2_tb/DUT/MEM/mem[254]}
add wave -noupdate {/lab8_stage2_tb/DUT/MEM/mem[253]}
add wave -noupdate -divider {DP internals}
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/data_in
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/data_out
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/aout
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/bout
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/sout
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/Ain
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/Bin
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/out
add wave -noupdate /lab8_stage2_tb/DUT/CPU/DP/Z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {764 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 285
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
WaveRestoreZoom {231 ps} {706 ps}
