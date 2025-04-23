# .data
     # test_string: .asciz "42 5\n"    # String 1: Número 42 seguido de espaço e 123

.globl _start

_start:
     j main

# Entrada: "6 4\n"
# Entrada: "2\n"
main: 
     
     # Obtendo cateto adjascente 1
     li a2, 6
     jal read

     la a0, input            
     li a1, 32                # ' ' (cond de parada)
     jal atoi

     la t0, catetoAdj1
     sw a0, 0(t0)             # Salvando cateto adjacente 1

     # la a0, catetoAdj1
     # la a1, resultado
     # li t0, 10                # \n
     # lb t0, 2(a1)

     # andando ate prox valor
     la a0, input
     li t1, 32                # t1 = ' '
     loop_int2:
          lb t2, 0(a0)        # Carregando byte
          beq t1, t2, fim_loop_int2          # Verificando se nao é ' '
          addi a0, a0, 1                     # prox byte
          j loop_int2
     fim_loop_int2:
          addi a0, a0, 1
        
     li a1, 10                # '\n' (cond de parada)
     jal atoi

     la t0, catetoOpst1
     sw a0, 0(t0)             # Salvando cateto oposto 1


     # Obtendo cateto adjacente 2
     li a2, 3
     jal read

     input2:
     la a0, input            
     li a1, 10                # '\n' (cond de parada)
     jal atoi

     fim_input2:
     la t0, catetoAdj2
     sw a0, 0(t0)             # Salvando cateto adjacente 2


     # Agora só calcular

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
# Saída: a0 (int com resultado)
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
     input: .skip 0x6  # buffer
     catetoAdj1: .skip 0x2
     catetoOpst1: .skip 0x2
     catetoAdj2: .skip 0x2
     resultado: .skip 0x3