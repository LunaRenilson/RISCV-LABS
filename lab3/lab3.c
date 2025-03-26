int read(int __fd, const void *__buf, int __n){
     int ret_val;
   __asm__ __volatile__(
     "mv a0, %1           # file descriptor\n"
     "mv a1, %2           # buffer \n"
     "mv a2, %3           # size \n"
     "li a7, 63           # syscall write code (63) \n"
     "ecall               # invoke syscall \n"
     "mv %0, a0           # move return value to ret_val\n"
     : "=r"(ret_val)  // Output list
     : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
     : "a0", "a1", "a2", "a7"
   );
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
     :   // Output list
     :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
     : "a0", "a1", "a2", "a7"
   );
 }
 
 void exit(int code)
 {
   __asm__ __volatile__(
     "mv a0, %0           # return code\n"
     "li a7, 93           # syscall exit (64) \n"
     "ecall"
     :   // Output list
     :"r"(code)    // Input list
     : "a0", "a7"
   );
 }
 
 void _start()
 {
   int ret_code = main();
   exit(ret_code);
 }
 
 #define STDIN_FD  0
 #define STDOUT_FD 1

void complemento2(char *valor, char *dec)
{
     int negativo = (valor[0] == '1');
     int total = 0;

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

     if (negativo)
     {
          dec[0] = '-';
          total = total * (-1);
     }

     // convertendo pra string do final pro começo
     for (int i = 0; total > 0; i++)
     {
          dec[10 - i] = (total % 10) + '0';
          total /= 10;
     }

     dec[11] = '\n';
     dec[12] = '\0';
}

void decimalUnsigned(char *valor, char *decUns)
{
     unsigned int total = 0;

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

     decUns[12] = '\n';
     decUns[12] = '\0';
}

void hexadecimal(char *valor, char hex[])
{
     unsigned int total = 0;
     int posicao = 2;
     int encontrouDigito = 0;

     hex[0] = '0';
     hex[1] = 'x';
     hex[10] = '\n';
     hex[11] = '\0';

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
}

void octal(char *valor, char oct[])
{
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

     oct[j++] = '\n';
     oct[j++] = '\0';
}

void imprimirBinario(char *valor)
{
     char bin[37];
     bin[0] = '0';
     bin[1] = 'b';
     int i, j;
     for (i = 2, j = 0; i < 34; i++, j++)
     {
          bin[i] = valor[j];
     }
     bin[i++] = '\n';
     bin[i++] = '\0';

     write(STDOUT_FD, bin, 37);
}

void decimalEndianness(char *valor, char *decEnd)
{
     int negativo = (valor[0] == '1');
     int total = 0;

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

     if (negativo)
     {
          decEnd[0] = '-';
          total = total * (-1);
     }

     // convertendo pra string do final pro começo
     for (int i = 0; total > 0; i++)
     {
          decEnd[10 - i] = (total % 10) + '0';
          total /= 10;
     }

     decEnd[11] = '\n';
     decEnd[12] = '\0';
}

void hexadecimalEndianness(char *valor, char hex[])
{
     unsigned int total = 0;
     int posicao = 2;
     int encontrouDigito = 0;

     hex[0] = '0';
     hex[1] = 'x';
     hex[10] = '\n';
     hex[11] = '\0';

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
}

void octalEndianness(char *valor, char oct[])
{
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

     oct[j++] = '\n';
     oct[j++] = '\0';
}

int main()
{

     char str[33];
     int n = read(STDIN_FD, str, 33);
     
     char dec[13];
     char decUns[13];
     char hex[12];
     char oct[15];
     char decEnd[13];
     char hexEnd[12];
     char octEnd[15];

     complemento2(str, dec);
     decimalUnsigned(str, decUns);
     hexadecimal(str, hex);
     octal(str, oct);
     decimalEndianness(str, decEnd);
     hexadecimalEndianness(str, hexEnd);
     octalEndianness(str, octEnd);

     // printf("%s", dec);
     // printf("%s", decUns);
     // printf("%s", hex);
     // printf("%s", oct);
     // imprimirBinario(str);
     // printf("%s", decEnd);
     // printf("%s", hexEnd);
     // printf("%s", octEnd);

     write(STDOUT_FD, dec, 13); 
     write(STDOUT_FD, decUns, 13);
     write(STDOUT_FD, hex, 12);
     write(STDOUT_FD, oct, 15);
     imprimirBinario(str);
     write(STDOUT_FD, decEnd, 12);
     write(STDOUT_FD, hexEnd, 12);
     write(STDOUT_FD, octEnd, 15);

     return 0;
}
