#include "biblio.h"

char buffer[100];
char print_hanoi[40] = "Mover disco _ da torre _ para a torre _\0";

#define NULL 0

void run_operation(int op){
    int o_quanto_a_equipe_de_404_e_legal = 0;
    switch (op){
        case 0:         // FIBONACCI
            o_quanto_a_equipe_de_404_e_legal = fibonacci_recursive(atoi(gets(buffer)));
            puts(itoa(o_quanto_a_equipe_de_404_e_legal, buffer, 10));
            break;

        case 1:         // FATORIAL
            o_quanto_a_equipe_de_404_e_legal = fatorial_recursive(atoi(gets(buffer)));;
            puts(itoa(o_quanto_a_equipe_de_404_e_legal, buffer, 10));
            break;

        case 2:         // Hanoi
            torre_de_hanoi(atoi(gets(buffer)), 'A', 'B', 'C', print_hanoi);
            break;

        default:
            break;
        }
}

void _start(){
    int operation = atoi(gets(buffer));
    run_operation(operation);
    exit(0);
}