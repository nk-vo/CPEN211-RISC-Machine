/* 
int binary_search(int *numbers, int key, int length)
{
    int startIndex = 0;
    int endIndex = length - 1;
    int middleIndex = endIndex/2;
    int keyIndex = -1;
    int NumIters = 1;
    while (keyIndex == -1) {
        if (startIndex > endIndex)
            break;
        else if (numbers[middleIndex] == key)
            keyIndex = middleIndex;
        else if (numbers[middleIndex] > key) {
            endIndex = middleIndex-1;
        } else {
            startIndex = middleIndex+1;
        }
        numbers[ middleIndex ] = -NumIters;
        middleIndex = startIndex + (endIndex - startIndex)/2;
        NumIters ++;
    }
    return keyIndex;
}
*/
// r0   - numbers
// r1   - key
// r2   - length
// r3   - startIndex
// r4   - endIndex
// r5   - middleIndex
// r6   - keyIndex
// r7   - NumIters
// r8   - numbers[middleIndex]
// r9   - -NumIters
// r10  - temp register


.include "address_map_arm.s"
.text
.globl binary_search
binary_search:

    // storing into registers
    sub sp, sp, #40         // back up space for items

    // store back up registers 
    // r3(startIndex) - r10 (temp register)
    str r10,[sp, #36]
    str r9, [sp, #32]
    str r8, [sp, #28]           
    str r7, [sp, #24]           
    str r6, [sp, #20]           
    str r5, [sp, #16]           
    str r4, [sp, #12]           
    str r3, [sp, #8]
    str lr, [sp, #4]        // link register

    ldr r3, [sp, #40]

    // starting
    mov r3, #0              // startIndex = 0
    sub r4, r2, #1          // endIndex = length - 1
    mov r5, r4, LSR #1      // middleIndex = endIndex/2
    mov r6, #-1             // keyIndex = -1
    mov r7, #1              // NumIters = 1


while:
    // load numbers[middleIndex]
    ldr r8, [r0, r5, LSL #2]
    cmp r6, #-1             // compare keyIndex and -1
    bne done

    cmp r3, r4              // startIndex > endIndex
    ble less_than_eq
    mov r0, r6              // return keyIndex = -1
    bgt done
    b   while

less_than_eq:// if startIndex is not larger than endIndex
    

    cmp r8, r1              // check if numbers[middleIndex] == key
    blt less_than
    bgt greater_than
    beq equal

    b   while

less_than: //if numbers[middleIndex] < key
    add r3, r5, #1          // startIndex = middleIndex+1;
    // numbers[ middleIndex ] = -NumCalls
    mov r9, #0              // initiate r9 to 0
    rsb r9, r7, r9          // set r9 to -NumIters
    str r9, [r0, r5, LSL #2]// numbers[middleIndex] = -NumIters

    sub r5, r4, r3          // endIndex - startIndex
    add r5, r3, r5, LSR #1  // middleIndex = startIndex + (endIndex - startIndex) / 2
    add r7, r7, #1          // NumIters++
    b   while

greater_than: //if number[middleIndex] > key
    sub r4, r5, #1          // endIndex = middleIndex-1;
    // numbers[ middleIndex ] = -NumCalls
    mov r9, #0              // initiate r9 to 0
    rsb r9, r7, r9          // set r9 to -NumIters
    str r9, [r0, r5, LSL #2]// numbers[middleIndex] = -NumIters

    sub r5, r4, r3          // endIndex - startIndex
    add r5, r3, r5, LSR #1  // middleIndex = startIndex + (endIndex - startIndex) / 2
    add r7, r7, #1          // NumIters++
    b   while
equal:
    mov r0, r5              // return keyIndex = middleIndex;
    b   done
done:
    ldr lr, [sp, #4]        // load link register

    // load back up r3 - r10
    ldr r10,[sp, #36]
    ldr r9, [sp, #32]
    ldr r8, [sp, #28]           
    ldr r7, [sp, #24]           
    ldr r6, [sp, #20]           
    ldr r5, [sp, #16]           
    ldr r4, [sp, #12]           
    ldr r3, [sp, #8]

    add sp, sp, #40         // back up space for items
    mov pc, lr

