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
     write(1, hex, 11);
}

void le_entrada(int *valores)
{
     for (int i = 0; i < 8; i++)
     {
          char entrada[6];
          int n = read(STDIN_FD, entrada, 6);
          int valor =  (entrada[1] - 48) * 1000 // x000
                    + (entrada[2] - 48) * 100  // 0x00
                    + (entrada[3] - 48) * 10   // 00x0
                    + (entrada[4] - 48);        // 000x

          // Transformando em positivo ou negativo
          if (entrada[0] == '-'){
               valor = -valor;
          }

          valores[i] = valor;
     }
}

int organizarBits(int *valores)
{
     unsigned int N2 = valores[2] | valores[3];    // 3 OR 4 
     unsigned int N1 = valores[0] & valores[1];    // 1 AND 2 
     unsigned int N3 = valores[4] ^ valores[5];    // 5 XOR 6
     unsigned int N4 = ~(valores[6] & valores[7]); // 7 NAND 8 (NAND é o inverso do AND)

     unsigned int resultado = (N1 & 0xFF)           // N1: bits 0-7 (LSB)
               | ((N2 & 0xFF) << 8 )      // N2: bits 8-15 (LSB)
               | ((N4 >> 16) & 0xFF) << 16  // N4: MSB (16-23)
               | ((N3 >> 24) & 0xFF) << 24; // N3: MSB (24-31) 
     return resultado;
}


int main()
{

     int valores[8] = {0};
     le_entrada(valores);
     int total = organizarBits(valores);
     hex_code(total);

     return 0;
}