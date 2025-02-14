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
        if (strlen(hex) < 2*i+1) {
            memset(bytes, 0, BLOCK_SIZE);
            return;
        }
        sscanf(hex + 2 * i, "%2hhx", &bytes[i]);
    }
}

int main() {
    FILE *fkeys = fopen("Key.txt", "r");
    FILE *fplaintext = fopen("Plaintextin.txt", "r");
    FILE *fciphertextin = fopen("Ciphertextin.txt", "r");
    if (!fkeys || !fplaintext) {
        fprintf(stderr, "Error: Missing Key.txt or Plaintextin.txt\n");
        return 1;
    }
    if (!fciphertextin) {
        printf("Note: No ciphertext input file - skipping decryption\n");
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
        printf("Generated encryption results for Key %d\n", k+1);
    }
    
    // Decrypt ciphertexts with each key
    if (fciphertextin) {
        BYTE ciphertexts[NUM_PLAINTEXTS][BLOCK_SIZE];
        char ciphertext_line[40];
        
        // Read ciphertext inputs
        for (int i = 0; i < NUM_PLAINTEXTS; i++) {
            if (fgets(ciphertext_line, sizeof(ciphertext_line), fciphertextin) == NULL) break;
            ciphertext_line[strcspn(ciphertext_line, "\r\n")] = '\0';
            hexstr_to_bytes(ciphertext_line, ciphertexts[i]);
        }
        fclose(fciphertextin);

        // Decrypt with each key
        for (int k = 0; k < NUM_KEYS; k++) {
            char outfilename[20];
            sprintf(outfilename, "Plaintextout%d.txt", k + 1);
            FILE *foutput = fopen(outfilename, "w");
            if (!foutput) continue;

            WORD key_schedule[60];
            BYTE dec_buf[BLOCK_SIZE];
            aes_key_setup(keys[k], key_schedule, 128);

            for (int c = 0; c < NUM_PLAINTEXTS; c++) {
                aes_decrypt(ciphertexts[c], dec_buf, key_schedule, 128);
                for (int j = 0; j < BLOCK_SIZE; j++) {
                    fprintf(foutput, "%02x", dec_buf[j]);
                }
                fprintf(foutput, "\n");
            }
            fclose(foutput);
            printf("Generated decryption results for Key %d\n", k+1);
        }
    }

    printf("Processing complete. Check output files.\n");
    return 0;
}
