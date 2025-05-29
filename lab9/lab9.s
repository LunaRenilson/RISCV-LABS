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

puts:
     li a2, 0
     mv t0, a0

     # Tamanho da str: Andando ate achar o fim da str
     loop_tam_str:
          lb t1, 0(t0)        # carregando byte
          beqz t1, fim_loop_tam_str

          addi t0, t0, 1
          addi a2, a2, 1
          j loop_tam_str
     
     fim_loop_tam_str:

     mv a1, a0
     li t0, 10           # ascii \n
     mv t1, a1           

     add t1, t1, a2      # ultimo caractere
     addi t1, t1, 1         
     sb t0, 0(t1)         # add \n ao final da string
     
     li a0, 1            # Codigo do output
     li a7, 64           # codigo do perif.
     ecall
     ret

gets:
     mv a1, a0
     li a0, 0                    # file descriptor = 0 (stdin)
     li a2, 100
     li a7, 63                   # syscall read (63)
     ecall

     mv a0, a1
     ret

# Converte int em str
# a0: int
# a1: buffer de saída
# a2: hex ou dec
itoa: 
     salva_reg
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
          recupera_reg
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
