CC = gcc
CFLAGS = -Wall -Wextra -O2
TARGET = lab3

all: $(TARGET)

$(TARGET): lab3.c
	$(CC) $(CFLAGS) lab3.c -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)
