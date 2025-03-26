CC = cc
LD = ld
WHISPER = whisper
LDFLAGS =

SRC = lab3.c
OBJ = lab3.o
EXEC = main.x

all: $(EXEC)

$(OBJ): $(SRC)
	$(CC) $< -o $@

$(EXEC): $(OBJ)
	$(LD) $< -o $@

run: $(EXEC)
	$(WHISPER) ./$< --newlib --setreg sp=0x7FFFFFC --isa acdfimsu

clean:
	rm -f $(OBJ) $(EXEC)
