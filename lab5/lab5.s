.data
     result: .byte 0, 0, 0, 0 # inicializando vetor com 0
.globl _start
_start:
     jal main


# (DD DD) (DD DD) (DD DD)\n
main:
     # Lendo entrada
     jal read

     # --------------------------------- Taking cathet x
     la t0, input_address          # Carregando input em a0
     lb a0, 1(t0)
     lb a1, 2(t0)
     
     # Returns x1 (from point 1) in a0 and copy to s0
     jal parse_two_digits 
     mv s0, a0
     

     la t0, input_address          # Carregando input em a0
     lb a0, 9(t0)
     lb a1, 10(t0)

     # Returns x2 in a0 and copy to s1
     jal parse_two_digits 
     mv s1, a0

     # cathet s2 = x2 - x1
     # s2 = s2 * s2 
     sub s2, s1, s0
     mul s2, s2, s2


     # -------------------------------- Taking cathet y
     la t0, input_address          # Carregando input em a0
     lb a0, 4(t0)
     lb a1, 5(t0)
     
     # Returns y1 (from point 1) in a0 and copy to s0
     jal parse_two_digits 
     mv s0, a0
     
     la t0, input_address          # Carregando input em a0
     lb a0, 20(t0)
     lb a1, 21(t0)

     # Returns y3 in a0 and copy to s1
     jal parse_two_digits 
     mv s1, a0

     # cathet s2 = x2 - x1
     # s2 = s2 * s2 
     sub s3, s1, s0
     mul s3, s3, s3
     add a0, s2, s3      # Sum cathets

     # Calculate hypotenuse 
     # Returns in a0
     jal sqrt_babylonian

     jal parse_str

     jal write
     j exit


# Entrada: a0
# Saída: a0
parse_str:
     la a1, result
     li t1, 10
     li t2, 48           # t2 = '0'

     # Add zeros à esquerda
     sb t2, 0(a1)
     sb t2, 1(a1)        #
     addi a1, a1, 2 # indo para o fim do buffer

     loop_str:
          beqz a0, fim_loop
          rem t0, a0, t1           # Obtendo digito menos significativo
          div a0, a0, t1           # Atualizando int (retirando digito menos significativo)
          addi t0, t0, 48          # t0 + '0'

          sb t0, 0(a1)             # Salvando do digito mais significativo para o menos significativo
          addi a1, a1, -1          # andando na string (pro digt. mais significativo)
          j loop_str
     
     fim_loop:
          li t0, 10                # t0 = '\n'
          la a1, result            # carrega result
          sb t0, 3(a1)             # armazena '\n' no fim da str
          mv a0, a1                # retorna a str em a0
          ret


# Entrada: a0 e a1 (dois valores ascii)
# Saida: a0 (int)
parse_two_digits:

     # Converte de ASCII para inteiro
     addi a0, a0, -48 # Subtrai '0'
     addi a1, a1, -48

     # Calcula o valor: (dezena * 10) + unidade
     li t5, 10
     mul a0, a0, t5
     add a0, a0, a1

     ret

# Entrada: a0
# Saída: a0
sqrt_babylonian:
     li t0, 10             # 10 iterações (contador)
     srli a1, a0, 1        # Estimativa inicial: k = y/2  
     beqz a0, done         # Se y=0, retorna 0

     loop:
          div t1, a0, a1        # t1 = y/k
          add t1, a1, t1        # t1 = k + y/k
          srli a1, t1, 1        # a1 = (k + y/k)/2 (nova estimativa)
          
          addi t0, t0, -1       # Decrementa contador
          bnez t0, loop         # Repete até 10 iterações

     done:
          mv a0, a1             # Move resultado para a0
          ret                   # Retorna com a raiz em a0


read:
     li a0, 0             # file descriptor = 0 (stdin)
     la a1, input_address # buffer
     li a2, 0x18           # size - Reads 24 bytes.
     li a7, 63            # syscall read (63)
     
     ecall
     ret

write:
     li a0, 1            # file descriptor = 1 (stdout)
     la a1, result       # buffer
     li a2, 4            # size - Writes 4 bytes.
     li a7, 64           # syscall write (64)
     ecall
     ret


exit:
     li a0, 0
     li a7, 93
     ecall

.bss
     input_address: .skip 0x18  # buffer