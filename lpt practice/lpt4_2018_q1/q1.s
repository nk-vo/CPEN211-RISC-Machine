.global func
.global _start

_start:
    mov r4, #0x1
    mov r5, #0x2
    mov r6, #0x3
    mov r7, #0x4
    ldr r0, =X
    ldr r1, =Y
    mov r2, #7
    mov r3, r6

    bl func
exit:
    b exit

func:
    push {r4-r7, lr} 
    cmp r2, #0
    beq ret0
    cmp r3, #0
    beq ret0
    b continue

ret0:
    mov r0, #0
    pop {r4-r7, lr}
    mov pc, lr

continue:
    sub r4, r2, #1
    ldr r5, [r0, r4, LSL #2]
    sub r6, r3, #1
    ldr r7, [r1, r5, LSL #2]
    cmp r5, r7
    bne skip1

    mov r2, r4
    mov r3, r6
    bl func
    add r0, r0, #1
    pop {r4-r7, lr}
    mov pc, lr

skip1:
    SUB SP, SP, #16
    STR R0, [SP, #12]
    STR R1, [SP, #8]
    STR R2, [SP, #4]
    STR R3, [SP, #0]

    sub r3, r3, #1
    bl func
    mov r5, r0
    LDR R0, [SP,#12]
    LDR R1, [SP,#8]
    LDR R2, [SP, #4]
    LDR R3, [SP]
    ADD SP, SP, #16

    sub r2, r2, #1
    bl func
    cmp r5, r0
    ble skip2
    mov r0, r5
    pop {r4-r7, lr}
    mov pc, lr

skip2:
// b is stored in r0 so just need to return
    push {r4-r7,lr}
    mov pc, lr

X:
.asciz "ABCDBAB"

Y:
.asciz "BDCABA"