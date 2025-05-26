# Entrada: 
# P5
# 64 64
# 255
# [dados de 4 096 bytes]

# Nos primeiros bits menos significativos da imagem, excluindo o cabeçalho, você encontrará:

# Mensagem 1: 31 caracteres (248 bits). É uma pista textual que indica o valor do shift para decifrar a segunda mensagem.
# Mensagem 2: 24 caracteres (192 bits), criptografada via cifra de César.
# Total de bits lidos do início da imagem: 440 bits (55 bytes).

.data
     largura: .word 64
     altura: .word 64
     filename: .asciz "image.pgm"

.globl _start

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

write:
     li a0, 1            # file descriptor = 1 (stdout)
     # la a1, resultado       # buffer
     # li a2, 3            # size - Writes 4 bytes.
     li a7, 64           # syscall write (64)
     ecall
     ret


exit:
     li a0, 0
     li a7, 93
     ecall


main:

     # Abrindo imagem, lendo conteúdo e salvando
     jal open
     jal read_img
     la a0, image
     jal extract_message

     # Params do loop
     li t0, 24         # cond de parada
     la t1, mensagem + 31
     la t2, decript
     li a1, 12           # shift

     # Decifrando mensagem e salvando em `decript`
     loop_cifra:
          beqz t0, fim_cifra
          lb a0, 0(t1)
          
          salva_reg
          jal cesar
          recupera_reg

          sb a0, 0(t2)

          addi t2, t2, 1
          addi t1, t1, 1
          addi t0, t0, -1

          j loop_cifra

     fim_cifra:
     
     # Escrevendo bits nos ultimos 192 bytes (pixels)
     jal write_bits

     # Definindo tamanho do canvas
     jal setCanvas

     jal apply_decript

     j exit



# percorre a imagem 64x64 e aplica setPixel para cada pixel
# Percorre a imagem 64x64 e aplica setPixel para cada pixel
apply_decript:
     # Salva registradores na pilha
     addi sp, sp, -16
     sw ra, 0(sp)
     sw s0, 4(sp)
     sw s1, 8(sp)
     sw s2, 12(sp)

     la s2, image          # Endereço base da imagem (carregado uma vez fora dos loops)
     li s0, 0              # Contador de y (linhas: 0 a 63)

     loop_y:
          li s1, 0              # Contador de x (colunas: 0 a 63)

     loop_x:
          # Calcula o índice linear (y * 64 + x)
          li t0, 64
          mul t1, s0, t0        # t1 = y * 64
          add t1, t1, s1        # t1 = y * 64 + x (índice)

          # Carrega o valor do pixel em image[índice]
          add t2, s2, t1        # t2 = image + índice
          lbu a2, 0(t2)         # a2 = valor do pixel (byte)
          
          # Chama setPixel(x, y, valor)
          mv a0, s1             # a0 = x (s1)
          mv a1, s0             # a1 = y (s0)
          jal setPixel

          # Próxima coluna (x++)
          addi s1, s1, 1
          li t0, 64
          blt s1, t0, loop_x    # Se x < 64, continua loop_x

          # Próxima linha (y++)
          addi s0, s0, 1
          li t0, 64
          blt s0, t0, loop_y    # Se y < 64, continua loop_y

          # Restaura registradores e retorna
          lw ra, 0(sp)
          lw s0, 4(sp)
          lw s1, 8(sp)
          lw s2, 12(sp)
          addi sp, sp, 16
          ret
   

# Função para escrever 192 bits da mensagem decifrada nos últimos 192 bytes da imagem
# (1 bit da mensagem por byte da imagem, sem alterar os outros 7 bits)
write_bits:
     la t0, decript          # Endereço da mensagem decifrada (24 bytes = 192 bits)
     la t1, image            # Endereço inicial da imagem
     li t2, 4096             # Tamanho total da imagem (ajuste conforme necessário)
     add t1, t1, t2          # Posiciona t1 no final da imagem (4096 bytes)
     addi t1, t1, -192       # Últimos 192 bytes da imagem (onde os bits serão escritos)

     li t3, 0               # Contador de bits processados (0 a 191)

     bit_loop:
          # Calcula o byte atual da mensagem (t0 + (t3 / 8))
          srli t4, t3, 3          # t4 = índice do byte (t3 / 8)
          add t4, t0, t4          # t4 = endereço do byte atual em decript
          lbu t5, 0(t4)           # Carrega o byte da mensagem (8 bits)

          # Calcula o bit atual dentro do byte (t3 % 8)
          andi t6, t3, 0x07       # t6 = posição do bit no byte (0 a 7)
          srl t5, t5, t6         # Desloca o bit desejado para a posição 0
          andi t5, t5, 0x01       # Isola apenas o LSB (bit atual)

          # Carrega o byte correspondente da imagem
          lbu t6, 0(t1)           # Lê o byte atual da imagem
          andi t6, t6, 0xFE       # Limpa o LSB (mantém os 7 bits superiores)
          or t6, t6, t5           # Insere o bit da mensagem no LSB

          # Escreve o byte modificado de volta na imagem
          sb t6, 0(t1)            # Armazena o byte atualizado

          # Avança para o próximo bit e próximo byte da imagem
          addi t1, t1, 1          # Próximo byte na imagem
          addi t3, t3, 1          # Incrementa contador de bits
          li t4, 192
          blt t3, t4, bit_loop    # Repete até processar 192 bits

          ret

# a0 = byte a ser convertido
# a1 = shift

# output -> a0: byte decifrado
# a0 = byte a ser decifrado
# a1 = shift (valor positivo)
# output -> a0: byte decifrado
cesar:
     # Verifica se é maiúscula (A-Z)
     li t0, 65
     blt a0, t0, not_upper
     li t0, 91
     bgt a0, t0, not_upper
     # Maiúscula: normaliza para 0-25
     addi a0, a0, -65
     # Aplica shift inverso e módulo 26
     sub a0, a0, a1
     li t1, 26
     rem a0, a0, t1
     # Corrige se negativo
     bge a0, zero, convert_upper
     addi a0, a0, 26
     j convert_upper

     not_upper:
          # Verifica se é minúscula (a-z)
          li t0, 97
          blt a0, t0, not_letter
          li t0, 123
          bgt a0, t0, not_letter
          # Minúscula: normaliza para 0-25
          addi a0, a0, -97
          # Aplica shift inverso e módulo 26
          sub a0, a0, a1
          li t1, 26
          rem a0, a0, t1
          # Corrige se negativo
          bge a0, zero, convert_lower
          addi a0, a0, 26
          j convert_lower

     convert_upper:
          addi a0, a0, 65
          ret

     convert_lower:
          addi a0, a0, 97
          ret

     not_letter:
          # Se não é letra, retorna original
          ret


extract_message:
     la t0, image + 13       # Endereço inicial da imagem
     la t1, mensagem    # Endereço onde a mensagem será armazenada
     li t2, 440          # Contador de bytes da imagem
     li t3, 0           # Contador de bits para formar byte
     li t4, 0           # Acumulador de bits

     process_byte:
          lb t5, 0(t0)       # Carrega byte da imagem
          andi t5, t5, 0x01  # Extrai o bit menos significativo

          sll t4, t4, 1      # Abre espaço para o bit
          or t4, t4, t5      # Insere o bit

          addi t0, t0, 1     # Próximo byte da imagem
          addi t3, t3, 1     # Mais um bit acumulado

          li t6, 8
          bne t3, t6, not_complete_byte

          sb t4, 0(t1)       # Armazena byte completo
          addi t1, t1, 1
          li t4, 0           # Reseta acumulador
          li t3, 0           # Reseta contador de bits

     not_complete_byte:
          addi t2, t2, -1
          bnez t2, process_byte

          # Se restaram bits incompletos
          beqz t3, end_extract
          sll t4, t4, t6     # Preenche com zeros à direita, opcional
          sb t4, 0(t1)

     end_extract:
          ret


open:
     # Abre o arquivo
     la a0, filename    # Endereço do caminho do arquivo
     li a1, 0           # Flags (0: rdonly)
     li a2, 0           # Mode
     li a7, 1024        # syscall open
     ecall

read_img:
     # Lê os dados da imagem (depois do cabeçalho)
    la a1, image       # Endereço onde os dados da imagem serão armazenados
    li a2, 4096      # Tamanho dos dados da imagem
    li a7, 63          # syscall read    outp: .skip 4
    ecall
    ret

# a0 = x coordinate
# a1 = y coordinate
setPixel:
     li a2, 0xFFFFFFFF # white pixel
     li a7, 2200 # syscall setPixel (2200)
     ecall
     ret

setCanvas: 
     # setando tamanho do canvas
     lw a0, largura               # altura do cavas
     lw a1, altura              # largura do canvas
     li a7, 2201                 # syscall
     ecall
     ret

.bss
     image: .skip 4096
     resultado: .skip 32
     mensagem: .skip 440
     decript: .skip 30