
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <math.h>  
#include <stdlib.h>
#include <string.h>

#define Columnas 10
#define Filas 10
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

		//int my_val = val1[thread_id5];

		//printf("row: %d, \tcol: %d, \tvalor: %d\n", row, column, my_val);

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
			//printf("row: %d,\t col: %d,\t Valor Original: %d,\t Nuevo Valor: %d\n", row, column, my_val5,output);
			//printf("Salida: %d \n", output);
			//printf("Entro\n");
			val2[thread_id5] = output;
		}
	}
}

int main(int argc, char* argv[])
{
	//int a[Columnas * Filas] = { 0 };
	//int a[Columnas * Filas] = { 0,	0	,0	,97	,176,	176,	127,	0,0,	0,0	,0,	0	,108,	191,	191	,142,	0,	0,	0,0,	0,	0,	101,	191	,191,	136	,0,	0,	0, 99,	110,	110	,155,	191	,191,	169	,110,	110,	102,182	,191,	191	,191,	191,	191,	191	,191,	191,	189, 180,	191	,191,	191	,191,	191	,191,	191	,191,	187, 120,	134,	133	,165,	191	,191,	176,	133,	134,	124,0,	0,	0,	102,	191,	191	,136,	0,	0,	0,0	,0,	0,	107	,191,	191,	141,	0,	0,	0 ,0,	0	,0,	98	,177,	177,	129	,0	,0,	0 };
	//int c[Columnas * Filas] = { 0 };

	if(argc != 2) {
		printf("Usage: display_Image ImageToLoadandDisplay");
		return -1;
	}
		int m = 0;
		int n = 0;

		FILE* archivo = fopen(argv[1], "r");
		char* buffer = NULL;
		int* array = NULL;
		int j, c, x;

		array = (int*)realloc(NULL, sizeof(int));

		c = fgetc(archivo);
		buffer = (char*)realloc(NULL, sizeof(char));
		j = 0;
		x = 0;
		while (!feof(archivo))
		{
			if (c == '\t' || c == '\n')
			{
				array = (int*)realloc(array, (x + 1) * sizeof(int));
				array[x] = atoi(buffer);
				buffer = (char*)realloc(NULL, sizeof(char));
				j = 0;
				x++;
				if (c == '\n')
				{
					n++;
				}
			}
			else
			{
				buffer[j] = c;
				j++;
				buffer = (char*)realloc(buffer, (j + 1) * sizeof(char));
			}
			c = fgetc(archivo);
		}
		fclose(archivo);
		m = x / n;   
		
    int* prueba= (int*)realloc(NULL, (m*n)*sizeof(int));	


	FILE* ImagenO1 = fopen("ImagenOriginalAntes.txt", "w");
	int Col = 0;
	for (int j = 0; j < m *n; j++)
	{
		fprintf(ImagenO1, "%d\t", array[j]);
		if (n-1 == Col)
		{
			fprintf(ImagenO1, "\n");
			Col = -1;
		}
		Col++;
	}
	fclose(ImagenO1);


	// Add vectors in parallel.
	cudaError_t cudaStatus = addWithCuda(prueba, array, Columnas * Filas);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addWithCuda failed! Global");
		return 1;
	}

	/*Imprime Resultados
	FILE* R = fopen("R.txt", "w");
	
	for (int i = 0; i < Columnas * Filas; i++)
	{
		//printf("\nPosicion: %d\tValor Original: %d\tValor Procesado: %d",i,a[i],c[i]);	
		fprintf(R, "\nPosicion: %d\tValor Original: %d\tValor Procesado: %d", i, array[i], prueba[i]);
	}
	fclose(R);*/

	/*FILE* ImagenO = fopen("ImagenOriginal.txt", "w");
	Col = 0;
	for (int j = 0; j < Columnas * Filas; j++)
	{
		fprintf(ImagenO, "%d\t", a[j]);
		if (Columnas - 1 == Col)
		{
			fprintf(ImagenO, "\n");
			Col = -1;
		}
		Col++;
	}
	fclose(ImagenO);*/

	FILE* Imagen = fopen("ImagenProce.txt", "w");
	Col = 0;
	for (int a = 0; a < Columnas*Filas; a++)
	{
		fprintf(Imagen, "%d\t", prueba[a]);
		if (Columnas - 1 == Col)
		{
			fprintf(Imagen, "\n");
			Col = -1;
		}
		Col++;
	}
	fclose(Imagen);

	/*Imprime Resultados*/
	printf("Terminado");
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

	const dim3 gridSize = dim3(Columnas*Filas, Columnas*Filas);
	const dim3 gridThread = dim3(16, 16);
	// Launch a kernel on the GPU with one thread for each element.
	bordes << <gridSize, gridThread >> > (dev_c, dev_a, Columnas, Filas);
	// Check for any errors launching the kernel
	cudaStatus = cudaGetLastError();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "\naddKernel launch failed AQUI: %s\n", cudaGetErrorString(cudaStatus));
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