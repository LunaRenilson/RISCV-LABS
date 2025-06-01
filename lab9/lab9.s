.data
     buf_aux: .skip 100

.globl linked_list_search
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl exit
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
     addi sp, sp, -32
     sw t0, 0(sp)
     sw t1, 4(sp)
     sw t2, 8(sp)
     sw t3, 12(sp)
     sw t4, 16(sp)
.endm
.macro recupera_reg
     lw t4, 16(sp)
     lw t3, 12(sp)
     lw t2, 8(sp)
     lw t1, 4(sp)
     lw t0, 0(sp)
     addi sp, sp, 32
.endm

# # int linked_list_search(Node *head_node, int val);
# # a0: *head_node
# # a1: valor
linked_list_search:
     salva_retorno
     salva_reg

     li t0, 0            # contador

     loop_node:
          lw t1, 0(a0)        # carrega valor 1
          lw t2, 4(a0)        # Carrega valor 2
          lw t3, 8(a0)        # prox nó

          add t4, t1, t2      # t4 = va1 + va2
          beq t4, a1, achou 
          beqz t3, nao_achou  # node->next = null: nao_achou

          addi t0, t0, 1
          mv a0, t3
          j loop_node

     achou:
          mv a0, t0           # salva indice para retorno
          j fim_node

     nao_achou:
          li a0, -1
     
     fim_node:
          recupera_reg
          recupera_retorno
          ret 

# a0: buffer
puts:
     salva_retorno
     li a2, 0
     mv t0, a0
     li t2, 10

     # Tamanho da str: Andando ate achar o fim da str
     loop_tam_str:
          lb t1, 0(t0)        # carregando byte
          beqz t1, fim_loop_tam_str

          addi t0, t0, 1
          addi a2, a2, 1
          j loop_tam_str
     fim_loop_tam_str:

     # Preparar para syscall sem modificar o buffer
     mv a1, a0           # buffer

     li t0, 10           # '\n'
     add t1, a0, a2      # andando para ultima casa do buffer
     sb t0, 0(t1)        # adicionando quebra de linha
     addi a2, a2, 1      # considerando espaço adicional do buffer

     # a2 já contém o tamanho (calculado)
     li a0, 1            # stdout
     li a7, 64           # syscall write
     
     # Adicionar nova linha separadamente
     ecall

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
          
# Converte int em str
# a0: int
# a1: buffer de saída
# a2: hex ou dec
itoa: 
     salva_retorno
     salva_reg

     la t0, buf_aux
     li t1, 0                 # qtd de caracteres (contador)  
     li t2, 10                # divisor   
     mv t5, a1                # salvando buffer
     li t6, 0                 # flag para sinal negativo (0 = positivo)

     # Verifica se o número é negativo
     bgez a0, positivo    # Se a0 >= 0, pula a tratativa de negativo
     li t6, 1                 # Marca como negativo
     neg a0, a0               # Converte para positivo

positivo:
     # Trata caso especial de zero
     beqz a0, trata_zero

loop_itoa:
     beqz a0, insere_sinal_negativo     # a0 = 0 -> insere_blablabla
     rem t3, a0, t2                     # Obtendo digito menos significativo
     div a0, a0, t2                     # Deslocando inteiro
     addi t3, t3, 48                    # Convertendo pra char
     sb t3, 0(t0)                       # Armazenando valor convertido
     
     addi t0, t0, 1                     # Andando na pilha
     addi t1, t1, 1                     # Incrementando contador
     j loop_itoa

insere_sinal_negativo:
     # Se for negativo, insere '-' ANTES dos dígitos
     beqz t6, desempilha_itoa  # Se não for negativo, vai direto para desempilhar
     li t3, 45                # Caractere '-'
     sb t3, 0(a1)             # Armazena no buffer
     addi a1, a1, 1           # Avança no buffer

desempilha_itoa:
     beqz t1, fim_itoa
     lb t3, -1(t0)            # Desempilhando char
     sb t3, 0(a1)             # Armazenando no buffer de saída

     addi t0, t0, -1          # Voltando na pilha aux
     addi a1, a1, 1           # Avançando no buffer de saída
     addi t1, t1, -1          # subtrai contador
     j desempilha_itoa

trata_zero:
     li t3, 48                # '0'
     sb t3, 0(t0)             # carregando valor na pilha
     addi t0, t0, 1           # andando na pilha
     li t1, 1                 # Contador de char (1, nesse caso)
     j desempilha_itoa        # Desempilhando

fim_itoa:
     li t4, 0
     sb t4, 0(a1)             # Adicionando terminador nulo
     mv a0, t5                # recuperando buffer
 
     # Restaurando a pilha
     recupera_reg
     recupera_retorno
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

