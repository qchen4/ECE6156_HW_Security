#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "aes.h"

#define NUM_KEYS 5
#define NUM_PLAINTEXTS 5
#define BLOCK_SIZE 16

// Convert hex string to byte array
void hexstr_to_bytes(const char *hex, BYTE *bytes) {
    for (int i = 0; i < BLOCK_SIZE; i++) {
        sscanf(hex + 2 * i, "%2hhx", &bytes[i]);
    }
}

int main() {
    FILE *fkeys = fopen("Key.txt", "r");
    FILE *fplaintext = fopen("Plaintextin.txt", "r");
    if (!fkeys || !fplaintext) {
        fprintf(stderr, "Error opening input files.\n");
        return 1;
    }
    
    char key_line[40], plaintext_line[40]; // 32 hex digits + null terminator
    BYTE keys[NUM_KEYS][BLOCK_SIZE];
    BYTE plaintexts[NUM_PLAINTEXTS][BLOCK_SIZE];

    // Read keys
    for (int i = 0; i < NUM_KEYS; i++) {
        if (fgets(key_line, sizeof(key_line), fkeys) == NULL) break;
        key_line[strcspn(key_line, "\r\n")] = '\0'; // Remove newline
        hexstr_to_bytes(key_line, keys[i]);
    }
    fclose(fkeys);

    // Read plaintexts
    for (int i = 0; i < NUM_PLAINTEXTS; i++) {
        if (fgets(plaintext_line, sizeof(plaintext_line), fplaintext) == NULL) break;
        plaintext_line[strcspn(plaintext_line, "\r\n")] = '\0'; // Remove newline
        hexstr_to_bytes(plaintext_line, plaintexts[i]);
    }
    fclose(fplaintext);

    // Encrypt plaintexts with each key
    for (int k = 0; k < NUM_KEYS; k++) {
        char outfilename[20];
        sprintf(outfilename, "Ciphertextout%d.txt", k + 1);
        FILE *foutput = fopen(outfilename, "w");
        if (!foutput) continue;

        WORD key_schedule[60];
        aes_key_setup(keys[k], key_schedule, 128);
        BYTE enc_buf[BLOCK_SIZE];

        for (int p = 0; p < NUM_PLAINTEXTS; p++) {
            aes_encrypt(plaintexts[p], enc_buf, key_schedule, 128);
            for (int j = 0; j < BLOCK_SIZE; j++) {
                fprintf(foutput, "%02x", enc_buf[j]);
            }
            fprintf(foutput, "\n");
        }
        fclose(foutput);
    }
    
    printf("Encryption complete. Check the Ciphertextout*.txt files.\n");
    return 0;
}
