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

## Examples

### Key.txt
```
00000000000000000000000000000000
ffffffffffffffffffffffffffffffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
00112233445566778899aabbccddeeff
deadbeefdeadbeefdeadbeefdeadbeef 
```

### Plaintextin.txt
```
00000000000000000000000000000000
ffffffffffffffffffffffffffffffff
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
000102030405060708090a0b0c0d0e0f
48656c6c6f2041455320313233212121 
```

### Ciphertextin.txt
```
66e94bd4ef8a2c3b884cfa59ca342b2e
66e94bd4ef8a2c3b884cfa59ca342b2e
3f5b8cc9ea855a0afa7347d23e8d664e
7191dfc1bbef90c4f80301c6c0a796bb
8522717d3ad1fbfeafa1ceaafdf56565
```

### Ciphertextout1.txt
```
66e94bd4ef8a2c3b884cfa59ca342b2e
66e94bd4ef8a2c3b884cfa59ca342b2e
3f5b8cc9ea855a0afa7347d23e8d664e
7191dfc1bbef90c4f80301c6c0a796bb
8522717d3ad1fbfeafa1ceaafdf56565