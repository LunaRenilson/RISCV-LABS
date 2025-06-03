void torre_de_hanoi(int n, char origem, char auxiliar, char destino, char* print_hanoi) {
    if (n == 1) {
        // Preenche a string de saída com os valores corretos
        print_hanoi[11] = '0' + n;          // Disco
        print_hanoi[19] = origem;           // Torre origem
        print_hanoi[31] = destino;          // Torre destino
        puts(print_hanoi);                  // Imprime a instrução
        return;
    }
    
    // Move n-1 discos de origem para auxiliar usando destino como auxiliar
    torre_de_hanoi(n - 1, origem, destino, auxiliar, print_hanoi);
    
    // Move o disco restante (o maior) de origem para destino
    print_hanoi[11] = '0' + n;              // Disco
    print_hanoi[19] = origem;               // Torre origem
    print_hanoi[31] = destino;              // Torre destino
    puts(print_hanoi);                      // Imprime a instrução
     
    // Move n-1 discos de auxiliar para destino usando origem como auxiliar
    torre_de_hanoi(n - 1, auxiliar, origem, destino, print_hanoi);
}