//Nicholas Schroeder	[NIS102]
// ECE 1160 - LAB4		[WORK_FILE]
// DUE 11-20-2019

#include <iostream>
#include <time.h>

#define EXIT_SUCCESS	0

using namespace std;

int main(int argc,char** argv){
	clock_t start_time = clock();

	const long int REPEAT_CYCLES = 500000000;
	int result = 0;

	for(long int i=0;i<REPEAT_CYCLES;i++)
		result = (result > 1000) ? result-1 : result+1; 

	clock_t finish_time = clock();

	cout << "WORK EXECUTION TIME: " << (double)(finish_time - start_time)/1000000 << "s" << endl;

	return EXIT_SUCCESS;
}


