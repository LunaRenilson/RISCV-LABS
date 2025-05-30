.data
     input: .skip 100

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
     add t1, a0, a2          # andando para ultima casa do buffer
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

     la a0, input
     lb t0, 0(a0)

     li t1, 48                # t1 = '1'
     beq t0, t1, trata_0      # buffer[0] = '1' -> trata_1

     li t1, 49                # t1 = '1'
     beq t0, t1, trata_1      # buffer[0] = '1' -> trata_1
     
     # li t1, 34                # t1 = '4'
     # beq t0, t1, trata_4      # buffer[0] = '4' -> trata_4
     
     li t1, 53                # t1 = '5'
     beq t0, t1, trata_5      # buffer[0] = '5' -> trata_5

     j obtem_input


     trata_0:
          jal puts

     trata_1:
          addi a0, a0, 2           # pulando digito e \n
          jal puts
          j fim_gets

     trata_4:

     trata_5:
          addi a0, a0, 2
          j fim_gets

     obtem_input:
     li a0, 0                 # file descriptor = 0 (stdin)
     la a1, input 
     li a2, 100
     li a7, 63                # syscall read (63)
     ecall

     fim_gets:
          ret

# Converte int em str
# a0: int
# a1: buffer de saída
# a2: hex ou dec
itoa: 
     salva_retorno
     salva_reg

     addi sp, sp, -32         # reserva espaço na pilha
     mv t0, sp
     li t1, 0                 # qtd de caracteres (contador)  
     li t2, 10                # divisor   
     mv t5, a1                # salvando buffer
     li t6, 0                 # flag para sinal negativo (0 = positivo)

     # Verifica se o número é negativo
     bgez a0, nao_negativo    # Se a0 >= 0, pula a tratativa de negativo
     li t6, 1                 # Marca como negativo
     neg a0, a0               # Converte para positivo

nao_negativo:
     # Trata caso especial de zero
     beqz a0, trata_zero

loop_itoa:
     beqz a0, insere_sinal_negativo  # Agora vamos inserir o sinal ANTES dos dígitos
     rem t3, a0, t2           # Obtendo digito menos significativo
     div a0, a0, t2           # Deslocando inteiro
     addi t3, t3, 48          # Convertendo pra char
     sb t3, 0(t0)             # Armazenando valor convertido
     
     addi t0, t0, 1           # Andando na pilha
     addi t1, t1, 1           # Incrementando contador
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
     addi t1, t1, -1
     j desempilha_itoa

fim_itoa:
     li t4, 0
     sb t4, 0(a1)             # Adicionando terminador nulo
     mv a0, t5                # recuperando buffer

     # Restaurando a pilha
     addi sp, sp, 32
     recupera_reg
     recupera_retorno
     ret
     
trata_zero:
     li t3, 48                # '0'
     sb t3, 0(t0)             # carregando valor na pilha
     addi t0, t0, 1           # andando na pilha
     li t1, 1                 # Contador de char (1, nesse caso)
     j desempilha_itoa        # Desempilhando

# Converte str em int
# Entrada: a0 (string) a1 (terminador)
# Saída: a0 (int com resultado)
atoi:
     lb t0, 0(a0)        # Primeiro char
     li t1, 0            # Total
     li t2, 10           # multiplicador
     li a1, 10            # cond de parada forçado '\0'
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

# Exit function implementation using syscall exit(93)
exit:
   li a7, 93                  # Syscall number for exit
   li a0, 0                   # Exit code (success)
   ecall                      # Call Linux to terminate the program 

