arquivo1.s: arquivo1.c
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax arquivo1.c -S -o arquivo1.s

arquivo1.o: arquivo1.s
	clang --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax arquivo1.s -c -o arquivo1.o

prog.x: arquivo1.o arquivo2.o
	ld.lld arquivo1.o arquivo2.o -o prog.x