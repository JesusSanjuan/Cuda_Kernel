
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <math.h>  

typedef struct {

    int width;
    int height;
    int stride;
    float* elements;

    } Matrix;


__global__ void bordes( const int *A, const int *B, const  int filas, const int columnas, int LongVector )
{
	// Reserva de memoria
	int ** matriz = new int*[filas];
	for (int a = 0; a < filas; a++)
	{
		matriz[a] = new int[columnas];
	}
	// ingreso de valores
	int contador = 0;
	for (int a = 0; a < filas; a++)
	{
		for (int b = 0; b < columnas; b++)
		{
			contador = contador + 1;
			matriz[a][b] = A[contador];
		}
	}

	// Liberación de la memoria
	/*for (int i = 0; i < filas; i++)
	{
		delete[] matriz[i];
	}

	delete[] matriz;*/


	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;

	int blockRow = blockIdx.y; 
	int blockCol = blockIdx.x;

}

/*__global__ void MatMulKernel(Matrix A, Matrix B, Matrix C)
{
	int blockRow = blockIdx.y; int blockCol = blockIdx.x;
	Matrix Csub = GetSubMatrix(C, blockRow, blockCol);
	float Cvalue = 0; // Variable para guardar resultado
	int row = threadIdx.y; int col = threadIdx.x;
	//Bucle para multiplicar submatrices Asubi y Bsubi
	for (int m = 0; m < (A.width / BLOCK_SIZE); ++m) {

		Matrix Asub = GetSubMatrix(A, blockRow, m); // Obten Asub de A
		Matrix Bsub = GetSubMatrix(B, m, blockCol); // Obten Bsub de B
		// Declara y carga variables en memoria compartida
		__shared__ float As[BLOCK_SIZE][BLOCK_SIZE];
		__shared__ float Bs[BLOCK_SIZE][BLOCK_SIZE];
		As[row][col] = GetElement(Asub, row, col);
		Bs[row][col] = GetElement(Bsub, row, col);
		__syncthreads(); // Sincroniza para asegurar carga
		// Multiplica Asubi y Bsubi para actualizar Cvalue
		for (int e = 0; e < BLOCK_SIZE; ++e)
			Cvalue += As[row][e] * Bs[e][col];
		__syncthreads(); // Sincroniza para asegurar fin cómputo previo }
		SetElement(Csub, row, col, Cvalue); // Escribe Csub a memoria global
	}*/

int main()
{
	return 0;
}

