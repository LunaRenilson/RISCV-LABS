.data
     test_string: .asciz "42 5\n"    # String 1: Número 42 seguido de espaço e 123

.globl _start

_start:
     j main

# Entrada: "6 4\n"
# Entrada: "5\n"
main: 
     
     # li a2, 4
     # jal read

     la a0, test_string
     li a1, 32
     jal atoi

     j exit

# Entrada: a0 (string) a1 (terminador)
atoi:
     lb t0, 0(a0)        # Primeiro char
     li t1, 0            # Total
     li t2, 10           # multiplicador

     loop_atoi:
          beq t0, a1, fim_loop_atoi
          addi t3, t0, -48              # Convertendo para int
          mul t1, t1, t2                # add casa decimal no total
          add t1, t1, t3                # Adicionando valor no total 
          addi a0, a0, 1                # prox digito
          lb t0, 0(a0) 
          j loop_atoi
     fim_loop_atoi:
          mv a0, t1
          ret

read:
     li a0, 0             # file descriptor = 0 (stdin)
     la a1, input # buffer
     li a7, 63            # syscall read (63)
     
     ecall
     ret

write:
     li a0, 1            # file descriptor = 1 (stdout)
     la a1, resultado       # buffer
     li a2, 4            # size - Writes 4 bytes.
     li a7, 64           # syscall write (64)
     ecall
     ret


exit:
     li a0, 0
     li a7, 93
     ecall

.bss
     input: .skip 0x3  # buffer
     catetoAdj1: .word
     catetoOpst1: .word
     catetoOpst2: .word
     resultado: .skip 0x3