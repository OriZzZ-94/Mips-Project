#define _CRT_SECURE_NO_WARNINGS
#include<stdio.h>
#include<stdlib.h>
#include <math.h>

typedef struct Way
{
	int Set; // the index int cach
	int Tag;

}Way;

typedef struct Command
{
	Way way0; //ways
	Way way1; //ways
	int Priority; // for priority set the Last insert.

}Command;

//functions signture
Command binarytransfer(long long int num, int Tagbit, int Setbit, int Offestbit, int* tmp1, int* tmp2);
void UpdatePrority(Command* Cache, int size);
int Findmax(Command* Cache, int size);
int searchTag(Command* cache, int size, int tag);
int SearchinChace(Command* Cache, int size, int Tag);
void IinitializeP(Command* Cache, int size);

void main(int argc, char** argv)
{
	int hits = 0;
	int misses = 0;
	int Icounter = 0;
	int Setbit;
	int Tagbit;
	int sets;
	int index = 0;
	int Sizecount = 0;
	FILE* fp = fopen(argv[4], "r");
	Command temp;
	int Offestbit = log(atoi(argv[3])) / log(2);
	if (atoi(argv[2]) == 3)
	{
		Setbit = 0;
		Tagbit = 32 - Offestbit;
		sets = atoi(argv[1]) / atoi(argv[3]);
	}
	else
	{
		Setbit = log(atoi(argv[1]) / (atoi(argv[3]) * atoi(argv[2]))) / log(2);
		Tagbit = 32 - (Offestbit + Setbit);
		sets = atoi(argv[1]) / (atoi(argv[3]) * atoi(argv[2]));
	}
	long long int x;
	//char c[100];//Array to read from file
	int j = 0; // index for the Cache array
	int* tmp1 = (int*)malloc(Tagbit * sizeof(int));//array for binary function
	int* tmp2 = (int*)malloc(Setbit * sizeof(int));//array for binary function

	int* LRU = (int*)calloc(sets, sizeof(int));

	if (fp == NULL) {
		printf("Error! opening file");
		// Program exits if file pointer returns NULL.
		exit(1);
	}
	//Allocate tha Chace Memory
	Command* cache = (Command*)malloc(sets * sizeof(Command));
	while (!feof(fp))
	{
		//read from file line by line
		if (fscanf(fp, "%lld\n", &x) > 0)
		{
			Icounter++;
			//transfer to binary
			temp = binarytransfer(x, Tagbit, Setbit, Offestbit, tmp1, tmp2);
			switch (atoi(argv[2]))
			{
				//One Way
			case 1:
				if (cache[temp.way0.Set].way0.Tag == temp.way0.Tag)
				{
					hits++;
				}
				else
				{
					misses++;
					cache[temp.way0.Set] = temp;
				}
				break;
				// 2 Way
			case 2:
				if (cache[temp.way0.Set].way0.Tag == temp.way0.Tag)
				{
					hits++;
					LRU[temp.way0.Set] = 0;
				}
				else if (cache[temp.way0.Set].way1.Tag == temp.way0.Tag)
				{
					hits++;
					LRU[temp.way0.Set] = 1;
				}
				else
				{
					misses++;
					if (LRU[temp.way0.Set] == 1)
					{
						cache[temp.way0.Set].way0 = temp.way0;
						LRU[temp.way0.Set]--;
					}
					else
					{
						cache[temp.way0.Set].way1 = temp.way0;
						LRU[temp.way0.Set]++;
					}
				}
				break;
				//Fully Associative
			case 3:
				
				int index = SearchinChace(cache, sets, temp.way0.Tag);
				IinitializeP(cache, sets);
					if (index != -1)
					{
						hits++;
						cache[index].Priority--;
					}
					else if (index == -1 && Sizecount != sets)
					{
						misses++;
						UpdatePrority(cache, sets);//add prority each command in the cache
						cache[Sizecount++] = temp; //find the command most old and replace it;
					}
					else if (index == -1 && Sizecount == sets)
					{
						misses++;
						cache[Findmax(cache, sets)] = temp; //find the command most old and replace it
						UpdatePrority(cache, sets); //add prority each command in the cache
					}
				break;
			}
		}
		else break;
	}
	float result = misses / (float)Icounter;
	printf("Precentage:%.3f\nHits=%d\nMiss=%d\nInstructions=%d\n", result*100, hits, misses, Icounter);
	//free memory
	free(tmp1);
	free(tmp2);
	free(cache);
	fclose(fp);

}



int searchTag(Command* cache, int size, int tag)
{
	int index = 0;
	for (index = 0; index < size; index++)
	{
		if (cache[index].way0.Tag == tag)
		{
			return index;
		}
	}
	return 0;
}

// Make it binary number to take the set and offset
Command binarytransfer(long long int num, int Tagbit, int Setbit, int Offestbit, int* tmp1, int* tmp2)
{
	long long int y = num;
	int size = Tagbit + Setbit;
	int power = 0;
	Command tmp;
	tmp.way0.Set = 0;
	tmp.way0.Tag = 0;
	tmp.way1.Set = 0;
	tmp.way1.Tag = 0;
	tmp.Priority = 0;
	y = y >> Offestbit;
	for (int i = 0; i < Setbit; i++)
	{
		tmp2[i] = y % 2;
		y = y / 2;
	}
	/*y = y / 2;*/
	for (int i = 0; i < Setbit; i++)
	{
		power = tmp2[i] * pow(2, i);
		tmp.way0.Set += power;
		tmp.way1.Set += power;




	}
	for (int i = 0; i < Tagbit; i++)
	{
		tmp1[i] = y % 2;
		y = y / 2;
	}
	for (int i = 0; i < Tagbit; i++)
	{
		power = tmp1[i] * pow(2, i);
		tmp.way0.Tag += power;
		tmp.way1.Tag += power;

	}
	return tmp;

}

//update Prority in the Cache
void UpdatePrority(Command* Cache, int size)
{
	for (int i = 0; i < size; i++)
	{
		Cache[i].Priority++;
	}
}
//find the old command index ( the less use command)
int Findmax(Command* Cache, int size)
{
	int max = 0;
	for (int i = 0; i < size; i++)
	{
		if (max < Cache[i].Priority)
			max = Cache[i].Priority;
	}
	return max;
}

//Find int the Cache the command
int SearchinChace(Command* Cache, int size, int Tag)
{
	int check = 0;
	for (int i = 0; i < size; i++)
	{
		if(Cache[i].way0.Tag == Tag)
		return i;
	}
	return -1;
}
//Iinitialize Prority 
void IinitializeP(Command* Cache, int size)
{
	int check = 0;
	for (int i = 0; i < size; i++)
	{
		Cache[i].Priority = 0;
	}
}



