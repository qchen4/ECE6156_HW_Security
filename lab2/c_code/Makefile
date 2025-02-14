# Makefile for AES test case generation

CC = gcc
CFLAGS = -Wall -Wextra
TARGET = aes_test
OUTPUTS = Ciphertextout*.txt plaintextout*.txt 

all: $(TARGET) run

$(TARGET): aes_test.c aes.c aes.h
	$(CC) $(CFLAGS) aes_test.c aes.c -o $(TARGET)

run:
	@echo "Running AES test case generation..."
	@./$(TARGET)
	@echo "Generated files:"
	@ls -l $(OUTPUTS)

clean:
	@echo "Cleaning up..."
	@rm -f $(TARGET) $(OUTPUTS)
	@echo "Clean complete"

.PHONY: all run clean
