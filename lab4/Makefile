# Variáveis do compilador e flags
CC = cc
CFLAGS = -Wall

# Nome dos arquivos
SRC = lab4.c
EXEC = lab4

# Alvo principal
all: $(EXEC)

# Regra para compilar o código-fonte em objeto
$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $(SRC) -o $(EXEC)

run: $(EXEC)
	./$(EXEC)

# Limpeza dos arquivos gerados
clean:
	rm -f $(EXEC)
