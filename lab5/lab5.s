.data
simulation: .asciz "(14 37) (13 37) (12 39)"  


.globl _start
_start:
     jal main


# (DD DD) (DD DD) (DD DD)\n
main:
     # jal read

     la t0, simulation          # Carregando input em a0
     lb a0, 1(t0)
     lb a1, 2(t0)
     
     jal parse_two_digits 

     # jal write
     j exit


# Entrada: a0 e a1 (dois valores ascii)
# Saida: a0 (int)
parse_two_digits:
     # Converte de ASCII para inteiro
     addi a0, a0, -48 # Subtrai '0'
     addi a1, a1, -48

     # Calcula o valor: (dezena * 10) + unidade
     li t0, 10
     mul a0, a0, t0
     add a0, t0, a1
     ret


# Entrada: a0
# Saída: a0 
# Destrói: a1, t0, t1, t2
# sqrt_babylonian:
#     li t0, 10             # 10 iterações (contador)
#     srli a1, a0, 1        # Estimativa inicial: k = y/2  
#     beqz a0, done         # Se y=0, retorna 0

# loop:
#     div t1, a0, a1        # t1 = y/k
#     add t1, a1, t1        # t1 = k + y/k
#     srli a1, t1, 1        # a1 = (k + y/k)/2 (nova estimativa)
    
#     addi t0, t0, -1       # Decrementa contador
#     bnez t0, loop         # Repete até 10 iterações

# done:
#     mv a0, a1             # Move resultado para a0
#     ret                   # Retorna com a raiz em a0


read:
     li a0, 0             # file descriptor = 0 (stdin)
     la a1, input_address # buffer
     li a2, 3            # size - Reads 24 bytes.
     li a7, 63            # syscall read (63)
     
     ecall
     ret

write:
     li a0, 1            # file descriptor = 1 (stdout)
     la a1, result       # buffer
     li a2, 4            # size - Writes 4 bytes.
     li a7, 64           # syscall write (64)
     ecall
     ret


exit:
     li a0, 0
     li a7, 93
     ecall

.bss

input_address: .skip 0x18  # buffer

result: .skip 0x4