
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <math.h>  
#include <stdlib.h>

cudaError_t addWithCuda(int* c, const int* a, unsigned int size);


__device__ unsigned int computeOutputEdge(int mask[][3], int vecinos[][3], int rows, int cols) {

	float result = 1;
	int sum = 0;

	for (int i = 0; i < rows; i++) {
		for (int j = 0; j < cols; j++) {
			float mul = mask[i][j] * vecinos[i][j];
			sum = sum + mul;
		}
	}
	result = abs(sum);
	return (int)result;
}



__global__ void bordes(int* val2, int* val1, int m, int n)
{

	int column = threadIdx.x + blockDim.x * blockIdx.x;
	int row = threadIdx.y + blockDim.y * blockIdx.y;

	int myEdge[3][3] = { {0,1,0},{1,-4,1},{0,1,0} };
	//int filas = (sizeof(myMask)/sizeof(myMask[0]));

	if (row < m && column < n) {

		int thread_id1 = (row - 1) * n + (column - 1);
		int thread_id2 = (row - 1) * n + (column);
		int thread_id3 = (row - 1) * n + (column + 1);

		int thread_id4 = (row)* n + (column - 1);

		int thread_id5 = (row)* n + (column);

		int thread_id6 = (row)* n + (column + 1);

		int thread_id7 = (row + 1) * n + (column - 1);
		int thread_id8 = (row + 1) * n + (column);
		int thread_id9 = (row + 1) * n + (column + 1);


		int my_val = val1[thread_id5];

		printf("row: %d, col: %d, value: %d\n", row, column, my_val);

		val2[thread_id5] = val1[thread_id5];

		if ((row > 0 && row < (m - 1)) && (column > 0 && column < (n - 1)))
		{
			int my_val0 = val1[thread_id1];
			int my_val2 = val1[thread_id2];
			int my_val3 = val1[thread_id3];
			int my_val4 = val1[thread_id4];
			int my_val5 = val1[thread_id5]; //doubly-subscripted access
			int my_val6 = val1[thread_id6];
			int my_val7 = val1[thread_id7];
			int my_val8 = val1[thread_id8];
			int my_val9 = val1[thread_id9];
			//printf("row: %d, col: %d, value: %d\n", row, column, my_val);

			int myMask2[3][3] = { {(my_val0),(my_val2),(my_val3)},
								 {(my_val4),(my_val5),(my_val6)},
								 {(my_val7),(my_val8),(my_val9)} };

			unsigned int output = computeOutputEdge(myEdge, myMask2, 3, 3);
			printf("output: %d", output);

			val2[thread_id5] = output;
		}
	}
}



/*__global__ void addKernel(int *c, const int *a, const int *b)
{
	int i = threadIdx.x;
	c[i] = a[i] + b[i];
}*/

int main()
{
	const int arraySize = 100;
	int a[arraySize] = { 0 };
	int c[arraySize] = { 0 };


	for (int i = 0; i < arraySize; i++)
	{
		int num = 1 + rand() % (256 - 1);
		a[i] = num;
	}
	printf("Valor: %d\n", a[0]);

	// Add vectors in parallel.
	cudaError_t cudaStatus = addWithCuda(c, a, arraySize);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addWithCuda failed! Global");
		return 1;
	}

	// printf("{1,2,3,4,5} + {10,20,30,40,50} = {%d,%d,%d,%d,%d}\n",c[0], c[1], c[2], c[3], c[4]);

	 // cudaDeviceReset must be called before exiting in order for profiling and
	 // tracing tools such as Nsight and Visual Profiler to show complete traces.
	cudaStatus = cudaDeviceReset();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceReset failed!");
		return 1;
	}

	return 0;
}

// Helper function for using CUDA to add vectors in parallel.
cudaError_t addWithCuda(int* c, const int* a, unsigned int size)
{
	int* dev_a = 0;
	int* dev_c = 0;
	cudaError_t cudaStatus;

	// Choose which GPU to run on, change this on a multi-GPU system.
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	// Allocate GPU buffers for two vectors (one input, one output)    .
	cudaStatus = cudaMalloc((void**)& dev_c, size * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed! C");
		goto Error;
	}

	cudaStatus = cudaMalloc((void**)& dev_a, size * sizeof(int));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	// Copy input vectors from host memory to GPU buffers.
	cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed! A");
		goto Error;
	}


	// Launch a kernel on the GPU with one thread for each element.
	//addKernel<<<1, size>>>(dev_c, dev_a, dev_b);
	bordes << <1, size >> > (dev_c, dev_a, 10, 10);
	// Check for any errors launching the kernel
	cudaStatus = cudaGetLastError();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
		goto Error;
	}

	// cudaDeviceSynchronize waits for the kernel to finish, and returns
	// any errors encountered during the launch.
	cudaStatus = cudaDeviceSynchronize();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
		goto Error;
	}

	// Copy output vector from GPU buffer to host memory.
	cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed! CC");
		goto Error;
	}

Error:
	cudaFree(dev_c);
	cudaFree(dev_a);

	return cudaStatus;
}