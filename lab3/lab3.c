int read(int __fd, const void *__buf, int __n)
{
     int ret_val;
     __asm__ __volatile__(
         "mv a0, %1           # file descriptor\n"
         "mv a1, %2           # buffer \n"
         "mv a2, %3           # size \n"
         "li a7, 63           # syscall write code (63) \n"
         "ecall               # invoke syscall \n"
         "mv %0, a0           # move return value to ret_val\n"
         : "=r"(ret_val)                   // Output list
         : "r"(__fd), "r"(__buf), "r"(__n) // Input list
         : "a0", "a1", "a2", "a7");
     return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
     __asm__ __volatile__(
         "mv a0, %0           # file descriptor\n"
         "mv a1, %1           # buffer \n"
         "mv a2, %2           # size \n"
         "li a7, 64           # syscall write (64) \n"
         "ecall"
         :                                 // Output list
         : "r"(__fd), "r"(__buf), "r"(__n) // Input list
         : "a0", "a1", "a2", "a7");
}

void exit(int code)
{
     __asm__ __volatile__(
         "mv a0, %0           # return code\n"
         "li a7, 93           # syscall exit (64) \n"
         "ecall"
         :           // Output list
         : "r"(code) // Input list
         : "a0", "a7");
}

void _start()
{
     int ret_code = main();
     exit(ret_code);
}

#define STDIN_FD 0
#define STDOUT_FD 1

void complemento2(char *valor){   

     char dec[10];
     int negativo = (valor[0] == '1');
     int total = 0;
     int inicio = 0;
     int casasDecimais = 0;

     if (negativo)
     {
          for (int i = 31; i >= 1; i--)
          {
               // Convertendo em inteiro
               int bit = valor[i] - '0';

               // Convertendo para binário
               total += bit * (1 << (31 - i));
          }

          // subtraindo digito do complemento de dois e transformando em negativo
          int tmp = total;
          total = (~total) + 1;
          dec[0] = '-';
          inicio = 1;

          while (tmp > 0)
          {
               tmp /= 10;
               casasDecimais++;
          }
     }
     else
     {
          for (int i = 31; i >= 1; i--)
          {
               // Convertendo em inteiro
               int bit = valor[i] - '0';
               total += bit * (1 << (31 - i));
          }
          int tmp = total;

          while (tmp > 0)
          {
               tmp /= 10;
               casasDecimais++;
          }
     }

     casasDecimais += inicio;
     // convertendo pra string do final pro começo
     for (int i = inicio; i < casasDecimais; i++)
     {
          int digito = (total % 10);
          // if (digito == 0) continue;

          dec[casasDecimais - i] = digito + '0';
          total /= 10;
     }

     write(STDOUT_FD, dec, casasDecimais + 1);
}

void decimalUnsigned(char *valor)
{
     unsigned int total = 0;
     char decUns[11];

     for (int i = 0; i < 32; i++)
     {
          int bit = valor[i] - '0';   // Converte char ('0' ou '1') para inteiro (0 ou 1)
          total = (total << 1) | bit; // Desloca o total para a esquerda e adiciona o bit
     }

     // Trocando a ordem dos bytes
     total = ((total >> 24) & 0xFF) |      // Byte 0 -> Byte 3
             ((total >> 8) & 0xFF00) |     // Byte 1 -> Byte 2
             ((total << 8) & 0xFF0000) |   // Byte 2 -> Byte 1
             ((total << 24) & 0xFF000000); // Byte 3 -> Byte 0

     // convertendo pra string do final pro começo
     for (int i = 0; total > 0; i++)
     {
          decUns[9 - i] = (total % 10) + '0';
          total /= 10;
     }
     write(STDOUT_FD, decUns, 11);
}

void hexadecimal(char *valor)
{
     unsigned int total = 0;
     int posicao = 2;
     int encontrouDigito = 0;

     char hex[10];
     hex[0] = '0';
     hex[1] = 'x';

     for (int i = 0; i < 32; i++)
     {
          int bit = valor[i] - '0';   // Converte char ('0' ou '1') para inteiro (0 ou 1)
          total = (total << 1) | bit; // Desloca o total para a esquerda e adiciona o bit
     }

     for (int i = 28; i >= 0; i -= 4)
     {
          unsigned int half = (total >> i) & 0xF;

          if (!encontrouDigito && half == 0 && posicao < 28)
          {
               continue;
          }

          // Marca que encontrou bit mais significativo
          encontrouDigito = 1;

          if (half < 10)
          {
               hex[posicao++] = '0' + half;
          }
          else
          {
               hex[posicao++] = 'a' + (half - 10);
          }
     }

     write(STDOUT_FD, hex, posicao);
}

void octal(char *valor)
{
     char oct[13];
     oct[0] = '0';
     oct[1] = 'o';

     int j = 2;
     unsigned int total = 0;
     int encontrouDigito = 0;
     for (int i = 0; i < 32; i++)
     {
          int bit = valor[i] - '0';   // Converte char ('0' ou '1') para inteiro (0 ou 1)
          total = (total << 1) | bit; // Desloca o total para a esquerda e adiciona o bit
     }

     if (total == 0)
     {
          oct[j++] = '0';
     }

     for (int i = 30; i >= 0; i -= 3)
     {
          unsigned int trio = (total >> i) & 0x7; // Obtendo 3 bits do total

          // Pulando zeros à esquerda
          if (!encontrouDigito && trio == 0 && i > 0)
          {
               continue;
          }

          encontrouDigito = 1;
          oct[j++] = '0' + trio;
     }
     write(STDOUT_FD, oct, j);
}

void binario(char *valor)
{
     char bin[34];

     // Inicializando vetor com zeros
     for (int i = 0; i < 34; i++)
     {
          bin[i] = 0;
     }

     bin[0] = '0';
     bin[1] = 'b';
     int encontrouDigito = 0;
     int j = 2;

     for (int byte = 3; byte >= 0; byte--) { // 4 bytes (32 bits)
          for (int bit = 0; bit < 8; bit++)
          {
               char valorAtual = valor[(byte * 8) + bit];
               if (!encontrouDigito && valorAtual == '0'){
                    continue;
               }
               encontrouDigito = 1;
               bin[j++] = valorAtual;
          }
     }

     if (!encontrouDigito){
          bin[j++] = '0';
     }

     write(STDOUT_FD, bin, j);
}

void decimalEndianness(char *valor)
{
     char decEnd[11];
     int negativo = (valor[0] == '1');
     int total = 0;
     int casasDecimais = 0;

     if (negativo)
     {
          for (int i = 31; i >= 0; i--)
          {
               // Convertendo em inteiro
               int bitAntes = valor[i] - '0';
               // Convertendo para complemento de dois
               int bitDepois = (bitAntes == 0) ? 1 : 0;

               // Convertendo para binário
               total += bitDepois * (1 << (31 - i));
          }
          total = (total * -1) - 1;
     }
     else
     {
          for (int i = 31; i >= 0; i--)
          {
               // Convertendo em inteiro
               int bit = valor[i] - '0';
               total += bit * (1 << (31 - i));
          }
     }

     // Trocando a ordem dos bytes
     total = ((total >> 24) & 0xFF) |      // Byte 0 -> Byte 3
             ((total >> 8) & 0xFF00) |     // Byte 1 -> Byte 2
             ((total << 8) & 0xFF0000) |   // Byte 2 -> Byte 1
             ((total << 24) & 0xFF000000); // Byte 3 -> Byte 0

     // Contando o numero de casas decimais para impressao
     int tmp = total;
     while (tmp > 0)
     {
          tmp /= 10;
          casasDecimais++;
     }

     if (negativo)
     {
          decEnd[0] = '-';
          total = total * (-1);
     }

     // convertendo pra string do final pro começo
     for (int i = 0; i < casasDecimais; i++)
     {
          decEnd[casasDecimais - i - 1] = (total % 10) + '0';
          total /= 10;
     }

     write(STDOUT_FD, decEnd, casasDecimais);
}

void hexadecimalEndianness(char *valor)
{
     unsigned int total = 0;
     int posicao = 2;
     int encontrouDigito = 0;

     char hex[10];
     hex[0] = '0';
     hex[1] = 'x';

     for (int i = 0; i < 32; i++)
     {
          int bit = valor[i] - '0';   // Converte char ('0' ou '1') para inteiro (0 ou 1)
          total = (total << 1) | bit; // Desloca o total para a esquerda e adiciona o bit
     }

     // Trocando a ordem dos bytes
     total = ((total >> 24) & 0xFF) |      // Byte 0 -> Byte 3
             ((total >> 8) & 0xFF00) |     // Byte 1 -> Byte 2
             ((total << 8) & 0xFF0000) |   // Byte 2 -> Byte 1
             ((total << 24) & 0xFF000000); // Byte 3 -> Byte 0

     for (int i = 28; i >= 0; i -= 4)
     {
          unsigned int half = (total >> i) & 0xF;

          if (!encontrouDigito && half == 0 && posicao < 28)
          {
               continue;
          }

          // Marca que encontrou bit mais significativo
          encontrouDigito = 1;

          if (half < 10)
          {
               hex[posicao++] = '0' + half;
          }
          else
          {
               hex[posicao++] = 'a' + (half - 10);
          }
     }
     write(STDOUT_FD, hex, 10);
}

void octalEndianness(char *valor)
{
     char oct[13];
     oct[0] = '0';
     oct[1] = 'o';

     int j = 2;
     unsigned int total = 0;
     int encontrouDigito = 0;
     for (int i = 0; i < 32; i++)
     {
          int bit = valor[i] - '0';   // Converte char ('0' ou '1') para inteiro (0 ou 1)
          total = (total << 1) | bit; // Desloca o total para a esquerda e adiciona o bit
     }

     // Trocando a ordem dos bytes
     total = ((total >> 24) & 0xFF) |      // Byte 0 -> Byte 3
             ((total >> 8) & 0xFF00) |     // Byte 1 -> Byte 2
             ((total << 8) & 0xFF0000) |   // Byte 2 -> Byte 1
             ((total << 24) & 0xFF000000); // Byte 3 -> Byte 0

     for (int i = 30; i >= 0; i -= 3)
     {
          unsigned int trio = (total >> i) & 0x7; // Obtendo 3 bits do total

          // Pulando zeros à esquerda
          if (!encontrouDigito && trio == 0 && i > 0)
          {
               continue;
          }
          encontrouDigito = 1;
          oct[j++] = '0' + trio;
     }
     write(STDOUT_FD, oct, j);
}

int main()
{

     char str[33];
     int n = read(STDIN_FD, str, 33);
     char quebra[1] = "\n";

     complemento2(str);
     write(STDOUT_FD, quebra, 1);

     decimalUnsigned(str);
     write(STDOUT_FD, quebra, 1);

     hexadecimal(str);
     write(STDOUT_FD, quebra, 1);

     octal(str);
     write(STDOUT_FD, quebra, 1);

     binario(str);
     write(STDOUT_FD, quebra, 1);

     decimalEndianness(str);
     write(STDOUT_FD, quebra, 1);

     hexadecimalEndianness(str);
     write(STDOUT_FD, quebra, 1);

     octalEndianness(str);
     write(STDOUT_FD, quebra, 1);

     return 0;
}