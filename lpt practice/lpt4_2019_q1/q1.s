.global foo
.global bar

foo:
    push {r4, lr}
    cmp r1, #0
    blt skip1
    mov r0, #1
    pop {r4, lr}
    mov pc, lr

skip1:
    sub r2, r1, #1
    push {r0-r3}
    mov r1, r2
    bl foo
    mov r4, r0
    pop {r0-r3}

    push {r0-r3}
    mov r1, r4
    bl bar
    mov r4, r0
    pop {r0-r3}

    sub r4, r1, r4
    str r4, [r0, r2, LSL #2]
    mov r0, r4

    pop {r4, lr}
    mov pc, lr

bar:
    push {r4, lr}
    cmp r1, #0
    ble skip2
    mov r0, #0
    pop {r4, lr}
    mov pc, lr

skip2:
    sub r2, r1, #1
    push {r0-r3}
    mov r1, r2
    bl bar
    mov r4, r0
    pop {r0-r3}

    push {r0-r3}
    mov r1, r4
    bl foo
    mov r4, r0
    pop {r0-r3}

    sub r0, r1, r4
    pop {r4, lr}
    mov pc, lr
