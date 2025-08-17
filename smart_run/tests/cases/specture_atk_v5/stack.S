.section .text
.globl rasChange

rasChange:
    # Pop off stack frame and get RA
    ld ra, 40(sp)

    # Calculate ra - 2 + (( 2 << 4 ) / 16)
    # This stalls the result of ra to be used for the ret
    addi ra, ra, -2
    addi t1, zero, 2
    slli t2, t1, 0x4
    fcvt.s.lu fa4, t1 
    fcvt.s.lu fa5, t2 
    fdiv.s fa5, fa5, fa4
    fdiv.s fa5, fa5, fa4
    fdiv.s fa5, fa5, fa4
    fdiv.s fa5, fa5, fa4
    fcvt.lu.s t2, fa5, rtz
    addi t1, zero, 2
    slli t2, t1, 0x4
    fcvt.s.lu fa4, t1 
    fcvt.s.lu fa5, t2 
    fdiv.s fa5, fa5, fa4
    fdiv.s fa5, fa5, fa4
    fdiv.s fa5, fa5, fa4
    fdiv.s fa5, fa5, fa4
    fcvt.lu.s t2, fa5, rtz
    add ra, ra, t2

    # Return to main
    ret