#include <stdio.h>

void le_entrada(int *valores)
{
     for (int i = 0; i < 8; i++)
     {
          char entrada[5];
          // int n = read(STDIN_FD, entrada, 5);
          scanf("%s", entrada);

          int sinal = (entrada[0] == '+' ? 1 : -1);

          valores[i] += (entrada[1] - 48) * 1000; // x000
          valores[i] += (entrada[2] - 48) * 100;  // 0x00
          valores[i] += (entrada[3] - 48) * 10;   // 00x0
          valores[i] += (entrada[4] - 48);        // 000x

          // Transformando em positivo ou negativo
          valores[i] *= sinal;
     }

     for (int i = 0; i < 8; i++)
     {
          printf("%d ", valores[i]);
     }
}

int organizarBits(int *valores)
{
     unsigned int N1 = valores[0] & valores[1];    // 1 AND 2 
     unsigned int N2 = valores[2] | valores[3];    // 3 OR 4 
     unsigned int N3 = valores[4] ^ valores[5];    // 5 XOR 6
     unsigned int N4 = ~(valores[6] & valores[7]); // 7 NAND 8 (NAND é o inverso do AND)

     int resultado = (N1 & 0xFF)          // bits 0-7
                     | (N2 & 0xFF) << 8   // bits 8-15
                     | (N3 & 0xFF) << 16  // bits 16-23
                     | (N4 & 0xFF) << 24; // bits 24-31;

     printf("%d\n", N4);
     return resultado;
}

void hex_code(int val)
{
     char hex[11];
     unsigned int uval = (unsigned int)val, aux;

     hex[0] = '0';
     hex[1] = 'x';
     hex[10] = '\n';

     for (int i = 9; i > 1; i--)
     {
          aux = uval % 16;
          if (aux >= 10)
               hex[i] = aux - 10 + 'A';
          else
               hex[i] = aux + '0';
          uval = uval / 16;
     }
     // write(1, hex, 11);
     printf("%s\n", hex);
}

int main()
{

     int valores[8] = {0};
     le_entrada(valores);
     int total = organizarBits(valores);
     hex_code(total);

     return 0;
}