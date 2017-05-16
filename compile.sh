#!/bin/bash

#
#

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


# If the user asks for help or tries to run the script without arguments
if [[ "$1" == "--help" ]] || [ "$#" -eq 0 ]; then
	extended_usage
	exit -1
fi

# Make sure that the file exists
if [ ! -f $1.nasm ]; then
	echo "[!!!] File '$1.nasm' not found"
	exit -1
fi


# Get the ip and port variables from args
ip=""
port=""
# 3 args, ip and port provided
if [ "$#" -eq 3 ]; then
    ip=$2
    port=$3
# 2 args, only ip or port provided
elif [ "$#" -eq 2 ]; then
	# If the arg contains a ".", it is the IP
	if [[ $2 == *"."* ]] ; then
		ip=$2
	else
		# No, this is the port
		port=$2
	fi	
	echo "ip: $ip port $port"
fi


# Convert the port to hex
hexport=$(printf "%04x" $port)

# Compile input file to object file
echo "[***] Compiling with nasm..."
nasm -f elf32 -o $1.o $1.nasm

# Link object file
echo "[***] Linking with ld..." 
echo ""
ld -m elf_i386 -o $1 $1.o

# List the opcode
#echo "[***] Listing opcode"
#objdump -d $1 -M intel

# Extract shellcode
shellcode=$(for i in $(objdump -d $1 -M intel |grep "^ " |cut -f2); do echo -n '\x'$i; done;)


# Should we replace the IP?
ipmarker="\\\xbb\\\xbb\\\xbb\\\xbb"
if [[ $shellcode == *$ipmarker* ]] ; then
	# Yes, shellcode contains ip marker bytes	

	if [[ $ip == "" ]]; then
	 	echo "[!!!] Error, ip marker bytes in code, but no ip was provided"
        usage
        exit -1
	fi

	ipbytes=$(echo $ip | tr "." "\n")

	iphexbytes=""
	for byte in $ipbytes
	do
		iphexbyte=$(printf "%02x" $byte)
		iphexbytes=$iphexbytes"\\x$iphexbyte"
	done

	if [[ $iphexbytes == *"00"* ]] ; then
		echo "[!!!] The selected IP number causes null-byte when converting to hex" 
		echo "[!!!] Illegal value: $iphexbytes ($ip)" 
		exit -1
	fi

	echo "[***] Replacing the ip to $ip ($iphexbytes)"
	shellcode="${shellcode/$ipmarker/$iphexbytes}"
fi

#
# Should we replace the port?
portmarker="\\\xaa\\\xaa"
if [[ $shellcode == *$portmarker* ]] ; then
	# Yes, shellcode contains port marker bytes		

	# if hexport is 0000, no port was provided, EXIT
	if [ $hexport != "0000" ]; then

		# Notify user that ports below 1024 requires root priv to run
		if [ $port -lt 1024 ] ; then
			echo "[---] Note: Port numbers under 1024 requires root to run!"
		fi

		# Port contains zero-byte, no good here
		if [[ $hexport == *"00"* ]] ; then
			echo "[!!!] The selected portnumber causes null-byte when converting to hex" 
			echo "[!!!] Illegal value: $hexport" 
			echo "[!!!] Please select another port."	
			echo ""
			exit -1
		fi

		# Split the port in upper/lower bytes
		hb=${hexport:2:2}
		lb=${hexport:0:2}

		# 'Reverse' the byte order 
		porthex=\\x$lb\\x$hb

		echo "[***] Replacing the port to $port ($porthex)"
		shellcode="${shellcode/$portmarker/$porthex}"
	else
		echo "[!!!] Error, port marker bytes in code, but no port was provided"
		usage
		exit -1	
	fi
fi

echo ""
echo "[***] Extracted shellcode:"
echo $shellcode

# Get the length of the shellcode
leng=${#shellcode}
length=$((leng/4))
echo "Shellcode length: $length"

#echo "[***] Generating shellcode-test compiler..."
cat > shellcode-$1.c << EOF
// 
#include<stdio.h>
#include<string.h>

unsigned char code[] = "$shellcode";

int main()
{
	printf("Shellcode length: %d\n", strlen(code));
	int (*ret)() = (int(*)())code;
	ret();
}

EOF
# Here we can print the generated program to the user if we want..
#cat shellcode-$1.c
#echo "[***] Generated"

#echo "Compiling 'shellcode-$1.c'..."
gcc -m32 -fno-stack-protector -z  execstack shellcode-$1.c -o shellcode-$1

echo ""
echo "[*** DONE ***]"
echo ""
# Tell the user (again) that ports below 1024 needs root..
if [ $hexport != "0000" ] && [ $port -lt 1024 ]; then
	echo "[---] Note: Port numbers under 1024 requires root to run!"
fi
