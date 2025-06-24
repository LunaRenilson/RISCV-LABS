.data
    

    arquitetura: .space 20              # 4 valores de Entrada

    # Vetores de pesos para cada camada
    l1: .space 200            # 50 * 4 valores de Oculta 1
    l2: .space 2500           # 50 * 50 valores de Oculta 2
    l3: .space 2500           # 50 * 50 valores de Oculta 3
    l4: .space 2500           # 50 * 50 valores de Oculta 4
    ln: .space 20             # Vetor de tamanhos das camadas
    saida: .space 3           # 3 valores de Saída

.globl _start

.macro salva_retorno
    addi sp, sp, -16       # aloca espaço na pilha
    sw ra, 0(sp)          # salva ra (32 bits)
.endm
.macro recupera_retorno
    lw ra, 0(sp)          # salva ra (32 bits)
    addi sp, sp, 16       # aloca espaço na pilha
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
    jal le_arquitetura


# Entrada no formato 4,10,20,3
le_arquitetura:
    salva_retorno

    # Lê os valores da arquitetura
    la a0, entrada         # Carrega o endereço do buffer de entrada
    li a1, 44              # Condição de parada: ','
    jal gets

    # Converte os valores lidos para inteiros e salva na arquitetura
    la t0, arquitetura  # Endereço base da arquitetura
    la t1, entrada         # Carrega o endereço do buffer de entrada
    li a2, 0              # Inicializa o tamanho da arquitetura
    salva_arquitetura_loop:
        # Verifica fim da linha
        lb t2, 0(t1)         # Lê o próximo byte do buffer de entrada
        li t3, 10            # Verifica se é o final da linha
        beq t2, t3, fim_salva_arquitetura_loop  # Se for '\n', sai do loop
        
        # Converte os valores de entrada para inteiros
        mv a0, t1            # Passa o endereço do buffer de entrada
        li a1, 44              # Condição de parada: ','
        jal atoi
        sw a0, 0(t0)           # Armazena o valor convertido na arquitetura
        addi t0, t0, 4         # Avança para o próximo espaço
        addi t1, t1, 1         # Pulando a virgula na entrada
        addi a2, a2, 1         # Incrementa o tamanho da arquitetura
        j salva_arquitetura_loop

    fim_salva_arquitetura_loop:
        # Salva o tamanho da arquitetura
        la t0, ln             # Endereço do vetor de tamanhos das camadas
        sw a2, 0(t0)          # Armazena o tamanho da arquitetura


# Converte str em int
# Entrada: a0 (string), a1 (condição de parada, por exemplo, '\n' ou ',')
# Saída: a0 (int com resultado)
atoi:
     salva_retorno
     salva_reg

     lb t0, 0(a0)        # Primeiro char
     li t1, 45           # t1 = '-'
     beq t0, t1, atoi_negativo

     li t1, 0            # Total
     li t2, 10           # multiplicador
     li t4, 1            # caso positivo por padrao
     li t5, 10           # cond de parada forçado '\n'
     j loop_atoi

     atoi_negativo:
          li t1, 0            # Total
          li t2, 10           # multiplicador
          li a1, 10            # cond de parada forçado '\n'
          li t4, -1            # sinalizador do negativo  
          addi a0, a0, 1      # pulando char negativo
          lb t0, 0(a0)

     loop_atoi:
          beq t0, a1, fim_loop_atoi     # Condição de parada normal
          beq t0, t5, fim_loop_atoi     # Condição de parada forçada
          addi t3, t0, -48              # Convertendo para int
          mul t1, t1, t2                # add casa decimal no total
          add t1, t1, t3                # Adicionando valor no total 
          addi a0, a0, 1                # prox digito
          lb t0, 0(a0) 
          j loop_atoi

     fim_loop_atoi:    
            mul t1, t1, t4
            mv a0, t1

            recupera_reg
            recupera_retorno
            ret



gets:
     mv a1, a0                # salvando o buffer  
     mv t3, a0                # backup buffer
     li t0, 10                # cond de parada: \n
     loop_leitura:
          li a0, 0                 # file descriptor = 0 (stdin)
          li a2, 1
          li a7, 63                # syscall read (63)
          ecall

          lb t1, 0(a1)
          addi a1, a1, 1
          beq t0, t1, fim_leitura
          j loop_leitura

     fim_leitura:
          mv a0, t3
          ret

# Exit function implementation using syscall exit(93)
exit:
   li a7, 93                  # Syscall number for exit
   li a0, 0                   # Exit code (success)
   ecall                      # Call Linux to terminate the program 


.bss
    # Valores de entrada
    entrada: .space 32        # 4 valores de Entrada (4 * 4 bytes)