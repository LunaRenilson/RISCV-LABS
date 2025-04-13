.data
     test_string: .asciz "42 5\n"    # String 1: Número 42 seguido de espaço e 123

.globl _start

_start:
     j main

# Entrada: "6 4\n"
# Entrada: "5\n"
main: 
     
     li a2, 4
     jal read
     
     la a0, input
     li a1, 32
     jal atoi

     la a1, resultado
     jal itoa

     jal write
     j exit


# Converte int em str
# Entrada: a0 (int), a1(buffer de saída)
itoa: 


     addi sp, sp, -32         # reserva espaço na pilha (ajustável)
     mv t0, sp
     li t1, 0                 # qtd de caracteres (contador)  
     li t2, 10                # divisor   

     # Trata caso especial de zero
     beqz a0, trata_zero


     loop_itoa:
          beqz a0, desempilha_itoa
          rem t3, a0, t2      # Obtendo digito menos significativo
          div a0, a0, t2      # Deslocando inteiro
          addi t3, t3, 48     # Convertendo pra char
          sb t3, 0(t0)        # Armazenando valor convertido
          
          addi t0, t0, 1      # Andando na pilhar
          addi t1, t1, 1      # Incrementando contador

          j loop_itoa
     
     desempilha_itoa:
          beqz t1, fim_itoa
          lb t3, -1(t0)        # Desempilhando char
          sb t3, 0(a1)        # empilhando na variavel da saida

          addi t0, t0, -1     # Voltando na pilha aux
          addi a1, a1, 1      # Avançando na pilha de saida
          addi t1, t1, -1
          j desempilha_itoa


     fim_itoa:
          sb t2, 0(a1)        # Adicionando terminador
          # Restaurando a pilha
          addi sp, sp, 32     

          ret

     trata_zero:
          li t3, 48           # '0'
          sb t3, 0(t0)        # carregando valor na pilha
          addi t0, t0, 1      # andando na pilha
          li t1, 1            # Contador de char (1, nesse caso)
          j desempilha_itoa   # Desempilhando


# Converte str em int
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

# entrada: a2 (tamanho do buffer a ser lido)
read:
     li a0, 0             # file descriptor = 0 (stdin)
     la a1, input # buffer
     li a7, 63            # syscall read (63)
     
     ecall
     ret

write:
     li a0, 1            # file descriptor = 1 (stdout)
     la a1, resultado       # buffer
     li a2, 3            # size - Writes 4 bytes.
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