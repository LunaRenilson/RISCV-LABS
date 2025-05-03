# Entrada
# +/- x1\n
# +/- x2\n
# +/- x3\n
# a b\n
#  --> xn = [1, 999]
#  --> a, b = [0, 999]

.data
     coeficientes: .word 0, 0, 0
     limites: .word 0, 0


.text
.globl _start


.macro FUNC nome_funcao
    addi sp, sp, -4       # aloca espaço na pilha
    sw ra, 0(sp)          # salva ra (32 bits)
    jal \nome_funcao      # chama a função passada como argumento
    lw ra, 0(sp)          # restaura ra
    addi sp, sp, 4        # desaloca espaço
.endm

_start:
     j main

main:
     jal read
     jal obtem_coefs
     j exit


obtem_coefs:
     la t0, input
     li a1, 10           # \n (cond de parada)
     la a2, coeficientes      

     # -------------- Primeiro valor
     lb t1, 0(t0)             # Obtendo sinal
     li t2, 45                # '-' (sinal de menos)
     beq t1, t2, aplica_sinal1
     li t1, 1
     j continua_sinal1
     aplica_sinal1:
          li t1, -1
     continua_sinal1:

     addi t0, t0, 1           # Pulando espaço
     li a1, 10                # \n (temrinador)
     mv a0, t0                # param da funcao
     FUNC atoi                # convertendo str para int (Retorno em a0)
     mul a0, a0, t1           # Aplicando o sinal
     sw a0, 0(a2)             # Salvando primeiro valor em coef
     addi t0, t0, 1           # Proximo valor

     # -------------- Segundo valor
     lb t1, 0(t0)             # Obtendo sinal
     li t2, 45                # '-' (sinal de menos)
     beq t1, t2, aplica_sinal2
     li t1, 1
     j continua_sinal2
     aplica_sinal2:
          li t1, -1
     continua_sinal2:

     addi t0, t0, 1           # Pulando espaço
     li a1, 10                # \n (temrinador)
     mv a0, t0                # param da funcao
     FUNC atoi                # convertendo str para int (Retorno em a0)
     mul a0, a0, t1           # Aplicando o sinal
     sw a0, 4(a2)             # Salvando primeiro valor em coef
     addi t0, t0, 1           # Proximo valor

     # -------------- Terceiro valor
     lb t1, 0(t0)             # Obtendo sinal
     li t2, 45                # '-' (sinal de menos)
     beq t1, t2, aplica_sinal3
     li t1, 1                 # Caso nao seja negativo
     j continua_sinal3
     aplica_sinal3:
          li t1, -1
     continua_sinal3:

     addi t0, t0, 1           # Pulando espaço
     li a1, 10                # \n (temrinador)
     mv a0, t0                # param da funcao
     FUNC atoi                # convertendo str para int (Retorno em a0)
     mul a0, a0, t1           # Aplicando o sinal
     sw a0, 8(a2)             # Salvando primeiro valor em coef
     addi t0, t0, 1           # Proximo valor

fim_coefs:
     ret


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
     la a1, input        # buffer
     li a7, 63            # syscall read (63)
     
     ecall
     ret

# Imprime conteúdo do rótulo "resultado"
write:
     li a0, 1            # file descriptor = 1 (stdout)
     la a1, resultado       # buffer
     li a2, 22            # size
     li a7, 64           # syscall write (64)
     ecall
     ret


exit:
     li a0, 0
     li a7, 93
     ecall

.bss
     input: .skip 32  # buffer
     resultado: .skip 32