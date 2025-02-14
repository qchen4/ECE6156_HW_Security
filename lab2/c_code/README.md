# AES Test Case Generator

## Requirements
- GCC compiler
- Input files in same directory:
  - Key.txt (5 lines of 32 hex chars)
  - Plaintextin.txt (5 lines of ASCII text, 16 chars max per line)
  - Ciphertextin.txt (5 lines of 32 hex chars)

## Usage
1. Compile: `gcc aes_test.c aes.c -o aes_test`
2. Create input files (see examples below)
3. Run: `./aes_test`
4. Generated files:
   - ciphertextout1-5.txt
   - ciphertextin.txt 
   - plaintextout1-5.txt
