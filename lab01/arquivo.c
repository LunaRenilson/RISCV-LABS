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

/* Aloca um buffer com 10 bytes.*/
char buffer[7];

void le_entrada(char *buf, int *v1, int *v2, char * op)
{
     // Convertendo para int
     (*v1) = buf[0] - 48;
     (*op) = buf[2];
     (*v2) = buf[4] - 48;
}

int realiza_operacao(int v1, int v2, char op)
{
     int res;
     if (op == '+')
          res = v1+v2;
     if (op == '-')
          res = v1 - v2;
     if (op == '*')
          res = v1*v2;

     return res;
}

int main()
{
     /* Lê uma string da entrada padrão */
     int n = read(STDIN_FD, (void *)buffer, 7);

     /* Modifica a string lida */
     int v1, v2;
     char op;

     le_entrada(buffer, &v1, &v2, &op);
     char resultado[2];
     resultado[0] = realiza_operacao(v1, v2, op) + 48;
     resultado[1] = '\n';
     
     /* Imprime a string lida e os dois caracteres adicionados
      * na saída padrão. */
     write(STDOUT_FD, resultado, 2);
     return 0;
}