#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <fcntl.h>

#define N 256 

int main(int argc, char *argv[]){
	
	if(argc < 2){
		printf("Too few arguments\narguments: \"key\"\n");
		exit(1);
	}


	//KSA
	int key_len = strlen(argv[1]);
	int i = 0, j = 0;
	uint8_t S[N] = {0};
	uint8_t T[N] = {0};

	for(i = 0; i < N; i++){
		S[i] = i;
		T[i] = argv[1][i % key_len];
	}

	for(i = 0, j = 0; i < N ; i++){
		j = (j + S[i] + T[i]) % N;
		//swap
		uint8_t tmp = S[i];
		S[i] = S[j];
		S[j] = tmp;
	}
 

	int fd_loader, fd_payload, fd_image;
	if((fd_loader = open("loader", O_RDWR)) == -1){
		perror("error opening loader");
		return __LINE__;
	}

	if((fd_payload = open("payload", O_RDWR)) == -1){
		perror("error opening payload");
		return __LINE__;
	}

	if((fd_image = open("image.bin", O_RDWR | O_CREAT, 0600)) == -1){
		perror("error opening image");
		return __LINE__;
	}


	//copy loader to image 
	uint8_t copy_byte;
	while(read(fd_loader, &copy_byte, sizeof(copy_byte))){
		if((write(fd_image, &copy_byte, sizeof(copy_byte))) == -1){
			perror("error writing from loader to image");
			return __LINE__;
		}
	}
	

	//PRGA
	uint8_t rb, wb, k;
	j = 0;
	i = 0;
	while(read(fd_payload, &rb, sizeof(rb))){
		i = (i + 1) % N;
		j = (j + S[i]) % N;	
		//swap 
		uint8_t tmp = S[i];
		S[i] = S[j];
		S[j] = tmp;
		uint32_t t = (S[i] + S[j]) % N;
		k = S[t];

		wb = rb ^ k;
		if((write(fd_image, &wb, sizeof(wb))) == -1){
			perror("write error");
			return __LINE__;
		}	
	}

	close(fd_image);
	close(fd_loader);
	close(fd_payload); 
	return 0;
}
