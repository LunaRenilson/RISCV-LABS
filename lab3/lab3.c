#include <stdio.h>

int complemento2(char *valor)
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

     return total;
}

unsigned int binToInt(char *valor)
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

     return total;
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

          if (half < 10){
               hex[posicao++] = '0' + half;
          }
          else{
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

void imprimirBinario(char *valor){
     char bin[37];
     bin[0] = '0';
     bin[1] = 'b';
     int i, j;
     for (i = 2, j = 0; i < 34; i++, j++){
          bin[i] = valor[j];
     }
     bin[i++] = '\n';
     bin[i++] = '\0'; 
     printf("%s", bin);
}

int decimalEndianness(char *valor)
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

     return total;
}


int main()
{

     char str[33] = "11000011101001111100001110100111\n";
     char hex[12];
     char oct[15];

     hexadecimal(str, hex);
     octal(str, oct);

     printf("%d\n", complemento2(str));
     printf("%u\n", binToInt(str));
     printf("%s\n", hex);
     printf("%s", oct);

     imprimirBinario(str);
     printf("%d\n", decimalEndianness(str));

     return 0;
}
