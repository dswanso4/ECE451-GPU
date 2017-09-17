/*
Assignment: ECE 451 Programming Assignment 2
Code: GpuSumPrimes.cu
Group: David Swanson, Daniel Caballero, Michael Wilder

Description: This code adds all the prime numbers up to a certain number input by the user.
This code takes one parameter (SIZE) from the user and uses the CUDA library to run the 
calculations needed in parallel on 1024 threads.
*/
#include <stdio.h>
#define BLOCK_SIZE 1024


/* SumPrimes the function on the device that calculates if a number is prime. It takes a 
pointer to the allocated array on the GPU and the size of the array. */

__global__ void SumPrimes (int *device_array, int SIZE) {
  
  // Index is calculated based on which block and thread is being worked.
  int index = threadIdx.x + blockIdx.x * blockDim.x;
  int i;
  int Prime = 1;

  // If the index is valid, then we need to check if it is prime.
  if (index < SIZE) {
    if ((index) == 0 || (index) == 1) {
      device_array[index] = 0;
	}

    // If the number is not prime, the value in the array is set to 0
	else {
      for (i=2; i*i <= index; i++) {
        if (index % i == 0) {
		  Prime = 0;
		  device_array[index] = 0;
		  break;
		}
	  }

      // if the number is prime, the value in the array is set to the number.
	  if (Prime)
		device_array[index] = index;
	}
  }
}

/* The main function of the code allocates memory on the host and device, transfers data
between the two, and calls the SumPrimes function. */

int main(int argc, char* argv []){
 
  int SIZE = atoi(argv[1]) + 1; 	
  int i;
  long int sum;
  int *host_array;
  int *device_array;
	
  sum = 0;
	
  // Allocate memory for host array and device array then copy host array to device array.
  host_array = (int *)malloc(SIZE*sizeof(int));
  cudaMalloc(&device_array, SIZE*sizeof(int));
  cudaMemcpy(device_array, host_array, SIZE*sizeof(int), cudaMemcpyHostToDevice);

  // Define how many blocks and threads that need to be used when calling SumPrimes.
  // A 1D array is used. The size of blocksPerGrid is set in a way to prevent overflow.
  dim3 blocksPerGrid((SIZE + BLOCK_SIZE - 1)/BLOCK_SIZE,1,1);
  dim3 threadsPerBlock(BLOCK_SIZE,1,1);
	
  SumPrimes <<<blocksPerGrid, threadsPerBlock>>>(device_array, SIZE);

  // Copy final array from device to host then clear memory in the device.
  cudaMemcpy(host_array, device_array, SIZE*sizeof(int), cudaMemcpyDeviceToHost);
  cudaFree(device_array);

  // Testing print statement.
  printf("I am adding: ");
  
  // Add all the elements in the array. Only prime numbers will be non-zero.
  for (i = 0; i < SIZE; i++) {
    if (host_array[i] != 0)
	  printf("%d ", host_array[i]);
    sum += host_array[i];
  }

  printf("\nSum = %ld \n", sum);
	
  return 0;

}
