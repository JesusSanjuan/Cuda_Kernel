
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>



__global__ void add3(float *val1, float *val2, int *num_elem)
{
	int i = threadIdx.x;
	val1[i] += val2[i];
}

__global__ void sub3(float *val1, float *val2, int *num_elem)
{
	int i = threadIdx.x;
	val1[i] += val2[i]+1;
}

int main()
{
	return 0;
}

