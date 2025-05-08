# Entrada
# +/- x1\n
# +/- x2\n
# +/- x3\n

.data
     potencias: .skip 12
     sinal_integral: .skip 12
     limites: .skip 8
     input_teste: .asciz "+ 1\n- 2\n+ 4\n32 37\n"

.text
.globl _start


.macro salva_retorno
    addi sp, sp, -4       # aloca espaço na pilha
    sw ra, 0(sp)          # salva ra (32 bits)
.endm
.macro carrega_retorno
    lw ra, 0(sp)          # salva ra (32 bits)
    addi sp, sp, 4       # aloca espaço na pilha
.endm

.macro salva_reg
     addi sp, sp, -16
     sw t0, 0(sp)
     sw t1, 4(sp)
     sw t2, 8(sp)
     sw t3, 12(sp)
.endm
.macro recupera_reg
     lw t3, 12(sp)
     lw t2, 8(sp)
     lw t1, 4(sp)
     lw t0, 0(sp)
     addi sp, sp, 16
.endm


_start:
     j main

main:
     jal read
     jal obtem_valores

     li t0, 0            # somar as integrais
     la t1, potencias

     # Sinais das integrais
     la t2, sinal_integral

     # Calculando primeira integral
     lw a0, 0(t1)
     jal calc_integral
     # Aplicando sinal na integral
     lw t3, 0(t2)
     mul a0, a0, t3
     add t0, t0, a0

     # Calculando segunda integral
     lw a0, 4(t1)
     jal calc_integral
     # Aplicando sinal na integral
     lw t3, 4(t2)
     mul a0, a0, t3
     add t0, t0, a0


     # Calculando terceira integral
     lw a0, 8(t1)
     jal calc_integral
     # Aplicando sinal na integral
     lw t3, 8(t2)
     mul a0, a0, t3
     add t0, t0, a0

     mv a0, t0
     la a1, resultado
     jal itoa

     mv a2, a0           # tamanho da string
     jal write
     j exit


# Função calc_integral:
# Entrada: a0 = θ (potência)
# Saída: a0 = resultado da integral (b^(θ+1)/(θ+1) - a^(θ+1)/(θ+1)
calc_integral:
     salva_retorno            # Salva o endereço de retorno
     salva_reg                # Salva registradores temporários

     # Carrega limites a e b
     la t0, limites
     lw t1, 0(t0)             # t1 = a
     lw t2, 4(t0)             # t2 = b

     # Calcula θ + 1
     addi t3, a0, 1           # t3 = θ + 1

     # Calcula a^(θ+1)
     mv a0, t1                # a0 = a
     mv a1, t3                # a1 = θ + 1
     jal potencia             # a0 = a^(θ+1)
     mv t4, a0                # t4 = a^(θ+1)

     # Calcula b^(θ+1)
     mv a0, t2                # a0 = b
     mv a1, t3                # a1 = θ + 1
     jal potencia             # a0 = b^(θ+1)
     mv t5, a0                # t5 = b^(θ+1)

     # Divide b^(θ+1) por (θ+1)
     div t5, t5, t3           # t5 = b^(θ+1) / (θ+1)

     # Divide a^(θ+1) por (θ+1)
     div t4, t4, t3           # t4 = a^(θ+1) / (θ+1)

     # Subtrai os resultados
     sub a0, t5, t4           # a0 = (b^(θ+1)/(θ+1)) - (a^(θ+1)/(θ+1)

     recupera_reg             # Restaura registradores
     carrega_retorno          # Restaura endereço de retorno
     ret

# Função auxiliar: potencia (a0^a1)
# Entrada: a0 = base, a1 = expoente
# Saída: a0 = resultado
potencia:
     salva_retorno
     salva_reg
     li t0, 1                 # t0 = resultado (inicializado com 1)
     mv t1, a0                # t1 = base
     mv t2, a1                # t2 = expoente
     beqz t2, fim_potencia    # Se expoente = 0, retorna 1

loop_potencia:
     mul t0, t0, t1           # t0 *= base
     addi t2, t2, -1          # expoente--
     bnez t2, loop_potencia   # Repete até expoente = 0

fim_potencia:
     mv a0, t0                # Retorna o resultado
     recupera_reg
     carrega_retorno
     ret

obtem_valores:
     la t0, input
     la a2, potencias

     # -------------- Primeiro valor
     lb t1, 0(t0)             # Obtendo sinal
     li t2, 45                # '-' (sinal de menos)
     beq t1, t2, aplica_sinal1
     
     # Caso sinal seja positivo, aplica 1
     la t1, sinal_integral
          li t2, 1
          sw t2, 0(t1)
     j continua_sinal1
     # Caso sinal seja negativo, aplica 2
     aplica_sinal1:
          la t1, sinal_integral
          li t2, -1
          sw t2, 0(t1)
     continua_sinal1:

     addi t0, t0, 2           # Pulando espaço
     li a1, 10                # \n (temrinador)
     mv a0, t0                # param da funcao
     salva_retorno
     jal atoi                # convertendo str para int (Retorno em a0)
     carrega_retorno
     sw a0, 0(a2)             # Salvando primeiro valor em coef
     addi t0, a1, 1           # Proximo valor

     # -------------- Segundo valor
     lb t1, 0(t0)             # Obtendo sinal

     li t2, 45                # '-' (sinal de menos)
     beq t1, t2, aplica_sinal2

     # Caso sinal seja positivo, aplica 1
     la t1, sinal_integral
          li t2, 1
          sw t2, 4(t1)
     j continua_sinal2
     # Caso sinal seja negativo, aplica 2
     aplica_sinal2:
          la t1, sinal_integral
          li t2, -1
          sw t2, 4(t1)
     continua_sinal2:

     addi t0, t0, 2           # Pulando espaço
     li a1, 10                # \n (temrinador)
     mv a0, t0                # param da funcao
     salva_retorno
     jal atoi                # convertendo str para int (Retorno em a0)
     carrega_retorno
     sw a0, 4(a2)             # Salvando primeiro valor em coef
     addi t0, a1, 1           # Proximo valor

     # -------------- Terceiro valor
     lb t1, 0(t0)             # Obtendo sinal
     li t2, 45                # '-' (sinal de menos)
     beq t1, t2, aplica_sinal3

     # Caso sinal seja positivo, aplica 1
     la t1, sinal_integral
          li t2, 1
          sw t2, 8(t1)
     j continua_sinal3
     # Caso sinal seja negativo, aplica 2
     aplica_sinal3:
          la t1, sinal_integral
          li t2, -1
          sw t2, 8(t1)
     continua_sinal3:

     addi t0, t0, 2           # Pulando espaço
     li a1, 10                # \n (temrinador)
     mv a0, t0                # param da funcao
     salva_retorno
     jal atoi                # convertendo str para int (Retorno em a0)
     carrega_retorno
     sw a0, 8(a2)             # Salvando primeiro valor em coef
     addi t0, a1, 1           # Proximo 

     # Obtendo limites
     # ------------- Primeiro limite
     mv a0, t0
     li a1, 32                # ' '
     salva_retorno
     jal atoi
     carrega_retorno 
     addi t0, a1, 1           # Andando para prox limite
     la a1, limites
     sw a0, 0(a1)             # Armazenando primeiro limite


     # -------------- Segundo limite
     mv a0, t0
     li a1, 10                # '\n'
     salva_retorno
     jal atoi
     carrega_retorno
     la a1, limites
     sw a0, 4(a1)             # Salvando segundo limite

     ret


# Converte int em str
# Entrada: a0 (int), a1(buffer de saída)
itoa: 
     addi sp, sp, -32         # reserva espaço na pilha (ajustável)
     mv t0, sp
     li t1, 0                 # qtd de caracteres (contador parcial)
     li t4, 0                 # qtd de caractered (contador para retorno da func)
     li t2, 10                # divisor & '\n'

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
          addi t4, t4, 1      # Incrementando contador

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
          addi t4, t4, 1           # contando '\n'
          mv a0, t4

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
     salva_reg
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
          mv a1, a0                     # novo Offset
          mv a0, t1                     # Int convertido
          recupera_reg
          ret

# entrada: a2 (tamanho do buffer a ser lido)
read:

     li a0, 0             # file descriptor = 0 (stdin)
     la a1, input        # buffer
     li a2, 32
     li a7, 63            # syscall read (63)
     ecall
     ret

# Imprime conteúdo do rótulo "resultado"
write:
     li a0, 1            # file descriptor = 1 (stdout)
     la a1, resultado       # buffer
     # li a2, 22            # size
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