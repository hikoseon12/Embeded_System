// ***********************************************************************
// TITLE       : random_generator.c   
// AUTHOR      : Jiseon Kim 
// AFFILIATION : Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Test vector generator to create operand data                      
// **********************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define START 0 
#define END 255

#define ITR 76800 

int main(void) {

	FILE *fp[3];
	fp[0] = fopen("./MemP.txt", "w");
    fp[1] = fopen("./MemP_4.txt", "w");
	fp[2] = fopen("./tv.h", "w");
	int i, j, k;
	
	unsigned char number;
	unsigned char tmp_num[4] = {0};


	for(i=0;i<3;i++)
		if(fp[i]==NULL)
		{
			printf("error occurs when opening fp[%d]!\n", i);
			exit(1);
		}
	
	
	srand((long) time(NULL));
        
	j=0;
	fprintf(fp[2], "unsigned char a[%d] = {\n", ITR);
	for(i=0;i<ITR;i++) //2^15 = 256 x 128
	{
		number=rand()%(END-START+1)+START;
		fprintf(fp[2], "0x%02x,\n", number);
		fprintf(fp[0], "%02x\n", number);
		tmp_num[j] = number;
		j=j+1;
	        if(j==4)
		{
			for(k=3;k>=0;k--)
				fprintf(fp[1], "%02x", tmp_num[k]);
			fprintf(fp[1], "\n");
			j=0;
		}
	}
	fprintf(fp[2], "};\n");
	
	for(i=0;i<3;i++)
		fclose(fp[i]);
	
	return 0;
}