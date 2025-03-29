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

void le_entrada(char * entrada, int * numeros) {
     for (int i = 0; i < 47; i++){
          char entrada[5];
          int sinal;
          int n = read(STDIN_FD, entrada, 5);

          sinal = (entrada[0] == '+' ? 1 : -1);

          numeros[0] = 0; // incializando valor
          numeros[0] += (entrada[1] - '48') * 1000;
          numeros[0] += (entrada[1] - '48') * 100;
          numeros[0] += (entrada[1] - '48') * 10;
          numeros[0] += (entrada[1] - '48');
          
     }
}

int main() {

     int numeros[8];

     return 0;
}