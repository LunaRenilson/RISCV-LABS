all: ${f}.x run

${f}.o: ${f}.s
	riscv64-unknown-elf-as -march=rv32im -o ${f}.o ${f}.s

${f}.x: ${f}.o
	riscv64-unknown-elf-ld -m elf32lriscv -o ${f}.x ${f}.o 

run: ${f}.x
	qemu-riscv32 ${f}.x