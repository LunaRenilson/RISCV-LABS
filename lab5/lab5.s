.globl _start

_start:
     jal main

main:
     jal read


     jal write
     j exit


# Entrada: a0
# Saída: a0 
# Destrói: a1, t0, t1, t2
sqrt_babylonian:
    li t0, 10             # 10 iterações (contador)
    srli a1, a0, 1        # Estimativa inicial: k = y/2  
    beqz a0, done         # Se y=0, retorna 0

loop:
    div t1, a0, a1        # t1 = y/k
    add t1, a1, t1        # t1 = k + y/k
    srli a1, t1, 1        # a1 = (k + y/k)/2 (nova estimativa)
    
    addi t0, t0, -1       # Decrementa contador
    bnez t0, loop         # Repete até 10 iterações

done:
    mv a0, a1             # Move resultado para a0
    ret                   # Retorna com a raiz em a0


parse_two_digits:
    lbu t0, 0(a0)    # Carrega o primeiro dígito (dezena)
    lbu t1, 1(a0)    # Carrega o segundo dígito (unidade)

    # Converte de ASCII para inteiro
    addi t0, t0, -48 # Subtrai '0'
    addi t1, t1, -48

    # Calcula o valor: (dezena * 10) + unidade
    li t2, 10
    mul t0, t0, t2
    add a0, t0, t1
    ret

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