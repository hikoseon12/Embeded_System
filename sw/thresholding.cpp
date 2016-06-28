// **********************************************************************************
// TITLE       : Adaptive Thresholding with Gaussian Algorithm    
// AUTHOR      : Jiseon Kim
// AFFILIATION : Embedded systems Lab. Dept. of CS, Sookmyung Women's University 
// DESCRIPTION : Image resolution 320x240                      
// **********************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "tv.h"

#define KSIZE 5
#define SIZE (5 - 1) / 2
#define SUM 256
#define ROW 320
#define COL 240


int main(void)
{
	FILE *fp;
	int i = 0, j = 0, x = 0, y = 0;
	int val;
	int MaskGaussian[25] = {1,4,7,4,1,4,16,26,16,4,7,26,41,26,7,4,16,26,16,4,1,4,7,4,1};	
	unsigned int binary[76800] = {0};

	fp = fopen("./sw_result.txt", "w");
	
	if(fp==NULL)
	{
		printf("error occurs when opening sw_result.txt!\n", i);
		exit(1);
	}
	
	for (y = 0; y < ROW; y++) 
	{
		for (x = 0; x < COL; x++) 
		{
			val = 0;
			for (i = -SIZE; i  <= SIZE; i++) 
			{
				for (j = -SIZE; j <= SIZE; j++) 
				{
					if (y + i >= 0 && y + i < ROW && x + j >= 0 && x + j < COL)
						val += a[COL*(y + i) + (x + j)]*MaskGaussian[(i + SIZE)*KSIZE + (j + SIZE)];		
				}
			}
			val = val / SUM;
			binary[y*COL + x] = (a[y*COL + x] < val) ? 255 : 0;
			fprintf(fp, "%02x\n", binary[y*COL + x]);
		}
	}
	fclose(fp);
	
	return 0;
}
