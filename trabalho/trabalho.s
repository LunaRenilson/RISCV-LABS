.data
    arquitetura: .skip 16           # Para armazenar a arquitetura da rede de 4 camadas
    entrada:     .asciz "4,10,20,3\n..." # Entrada de exemplo

.globl _start

_start:
    
    j exit


le_arquitetura:
    la t0, entrada  # Carrega o endereço da variável arquitetura
    la t1, arquitetura  # Carrega o endereço da variável entrada
    li t2, 10           # '\n' (nova linha) como delimitador  
    loop_arquitetura:
        lw a0, 0(t0)          # Lê o valor atual
        beq t2, a0, fim_arquitetura  # Se for '\n', sai do loop
        
        jal atoi              # Converte string para int
        sw a0, 0(t1)         # Armazena o valor convertido na arquitetura

        addi t1, t1, 4       # Avança para o próximo espaço na arquitetura
        addi t0, t0, 4        # Avança para o próximo valor na entrada
        j loop_arquitetura
    fim_arquitetura:
        ret





# Converte str em int
# Entrada: a0 (string)
# Saída: a0 (int com resultado)
atoi:
     salva_retorno
     lb t0, 0(a0)        # Primeiro char
     li t1, 45           # t1 = '-'
     beq t0, t1, atoi_negativo

     li t1, 0            # Total
     li t2, 10           # multiplicador
     li t4, 1            # caso positivo por padrao
     li a1, 10            # cond de parada forçado '\n'
     j loop_atoi

     atoi_negativo:
          li t1, 0            # Total
          li t2, 10           # multiplicador
          li a1, 10            # cond de parada forçado '\n'
          li t4, -1            # sinalizador do negativo  
          addi a0, a0, 1      # pulando char negativo
          lb t0, 0(a0)

     loop_atoi:
          beq t0, a1, fim_loop_atoi
          addi t3, t0, -48              # Convertendo para int
          mul t1, t1, t2                # add casa decimal no total
          add t1, t1, t3                # Adicionando valor no total 
          addi a0, a0, 1                # prox digito
          lb t0, 0(a0) 
          j loop_atoi

     fim_loop_atoi:
          mul t1, t1, t4
          mv a0, t1
          recupera_retorno
          ret



# Exit function implementation using syscall exit(93)
exit:
   li a7, 93                  # Syscall number for exit
   li a0, 0                   # Exit code (success)
   ecall                      # Call Linux to terminate the program 