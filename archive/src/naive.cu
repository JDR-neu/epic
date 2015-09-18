/**
 *  The MIT License (MIT)
 *
 *  Copyright (c) 2014 Kyle Hollins Wray, University of Massachusetts
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of
 *  this software and associated documentation files (the "Software"), to deal in
 *  the Software without restriction, including without limitation the rights to
 *  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 *  the Software, and to permit persons to whom the Software is furnished to do so,
 *  subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#include <stdio.h>

#include "../include/naive.h"

__device__ void index_to_coordinate(unsigned int n, unsigned int *m, unsigned long long int i, unsigned int *&c)
{
	// Actually allocate the memory for the coordinate.
//	c = new unsigned int[n];

	// Compute the coordinate by modifying the through the index and continually
	// removing the 'pieces' corresponding to each dimension, based on its size.
	for (unsigned int k = 0; k < n; k++) {
		c[k] = i % m[k];
		i = (unsigned long long int)(i / m[k]);
	}
}

__device__ void coordinate_to_index(unsigned int n, unsigned int *m, unsigned int *c, unsigned long long int &i)
{
	// The index offset based on the current dimension.
	unsigned long long int mk = 1;

	i = 0;

	// For each of the dimensions, compute the adjustment using the coordinate.
	for (unsigned int k = 0; k < n; k++) {
		// This is the offset based on previously computed dimensions.
		mk = 1;
		for (unsigned int j = 0; j < k; j++) {
			mk *= m[j];
		}

		i += c[k] * mk;
	}
}

__device__ unsigned long long int get_global_id()
{
	unsigned long long int blockId = blockIdx.x
			 + blockIdx.y * gridDim.x
			 + gridDim.x * gridDim.y * blockIdx.z;

	unsigned long long int threadId = blockId * (blockDim.x * blockDim.y * blockDim.z)
			  + (threadIdx.z * (blockDim.x * blockDim.y))
			  + (threadIdx.y * blockDim.x)
			  + threadIdx.x;

	return threadId;
}

__global__ void harmonic_iteration(unsigned long long int numElements, unsigned int n, unsigned int *m,
		float *u, float *uPrime, float epsilon) //, unsigned long long int *running)
{
	// The index of this thread.
	unsigned long long int i;

	// The corresponding coordinate of the index.
	unsigned int *c;

	// A temporary variable used to compute the coordinate of the index.
	unsigned long long int j;

	// The actual new value for u[i].
	float val;

	// Ignore if the index is greater than the number of elements defined in the n-array,
	// or this is a boundary or goal region (i.e., sign bit is on).
	i = get_global_id();
	if (i >= numElements || signbit(u[i]) != 0) {
//		__syncthreads();
		return;
	}

	// Resolve the index i to the actual coordinate in m.
	c = (unsigned int *)malloc(n * sizeof(unsigned int));
//	index_to_coordinate(n, m, i, c);


	unsigned long long z = i;
	for (unsigned int k = 0; k < n; k++) {
		c[k] = z % m[k];
		z = (unsigned long long int)(z / m[k]);
	}


	// Average the 2n-neighborhood around this location, following Jacobi Iteration.
	val = 0.0f;

	for (unsigned int k = 0; k < n; k++) {
		// Subtract one from this dimension, clamping it to within bounds. If it does
		// go over, then it's fine because this clamping essentially does 'repeating'
		// of the boundaries. Avoid branch divergence (no if statement) by using 'max'.
		c[k] = max(0, c[k] - 1);

		// The index offset based on the current dimension.
//		coordinate_to_index(n, m, c, j);
		unsigned long long int mk = 1;
		j = 0;
		for (unsigned int l = 0; l < n; l++) {
			mk = 1;
			for (unsigned int w = 0; w < l; w++) {
				mk *= m[w];
			}
			j += c[l] * mk;
		}

		// Add the value of the neighbor. Note that the absolute value handles the bit-sign
		// for boundaries and goals.
		val += fabsf(u[j]);

		// Also do the same as above except with the other neighbor. Note the adjustment
		// for the subtraction by 1 above.
		c[k] = min(m[k] - 1, c[k] + 2);

//		coordinate_to_index(n, m, c, j);
		mk = 1;
		j = 0;
		for (unsigned int l = 0; l < n; l++) {
			mk = 1;
			for (unsigned int w = 0; w < l; w++) {
				mk *= m[w];
			}
			j += c[l] * mk;
		}

		val += fabsf(u[j]);

		// Finally, put the coordinate back to where it was originally for this dimension.
		c[k]--;
	}

	val /= (float)(2 * n);

	// Wait for all threads to compute the updated value.
//	__syncthreads();

	// Set the flag to keep looping if the delta was over the epsilon threshold specified.
//	*running = *running + (unsigned long long int)(fabs(val - u[i]) > epsilon);

	// Update the value in u to this new value.
	uPrime[i] = val;

	// Free memory of the actual coordinate now that we are done using it.
	free(c);
}

unsigned long long int compute_num_elements(unsigned int n, const unsigned int *m)
{
	unsigned long long int numElements;

	numElements = 1;
	for (unsigned int i = 0; i < n; i++) {
		numElements *= m[i];
	}

	return numElements;
}

int harmonic_alloc(unsigned int n, const unsigned int *m, const float *h,
		unsigned int *&d_m, float *&d_u, float *&d_uPrime)
{
	unsigned long long int numElements;

	// Ensure the data is valid.
	if (h == nullptr || n == 0 || m == nullptr) {
		fprintf(stderr, "Error[harmonic_alloc]: %s\n",
				"Invalid data.");
		return 1;
	}

	// Compute the total number of elements in the harmonic function.
	numElements = compute_num_elements(n, m);

	// Allocate the memory on the device.
	if (cudaMalloc(&d_m, n * sizeof(unsigned int)) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_alloc]: %s\n",
				"Failed to allocate device-side memory for the dimension size values.");
		return 2;
	}
	if (cudaMalloc(&d_u, numElements * sizeof(float)) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_alloc]: %s\n",
				"Failed to allocate device-side memory for the harmonic function values.");
		return 2;
	}
	if (cudaMalloc(&d_uPrime, numElements * sizeof(float)) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_alloc]: %s\n",
				"Failed to allocate device-side memory for the harmonic function values.");
		return 2;
	}

	// Copy the data from the host to the device. Note: Even if things like d_uPrime get overwritten,
	// you MUST malloc AND memcpy to use them!
	if (cudaMemcpy(d_m, m, n * sizeof(unsigned int), cudaMemcpyHostToDevice) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_alloc]: %s\n",
				"Failed to copy memory from host to device for the dimension size function.");
		return 3;
	}
	if (cudaMemcpy(d_u, h, numElements * sizeof(float), cudaMemcpyHostToDevice) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_alloc]: %s\n",
				"Failed to copy memory from host to device for the harmonic function.");
		return 3;
	}
	if (cudaMemcpy(d_uPrime, h, numElements * sizeof(float), cudaMemcpyHostToDevice) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_alloc]: %s\n",
				"Failed to copy memory from host to device for the harmonic function (prime).");
		return 3;
	}

	return 0;
}

int harmonic_execute(unsigned int n, const unsigned int *m, float epsilon,
		unsigned int *d_m, float *d_u, float *d_uPrime,
		unsigned int *b, unsigned int *t,
		unsigned int stagger)
{
	// Ensure the data is valid.
	if (n == 0 || epsilon <= 0.0f || d_m == nullptr || d_u == nullptr || b == nullptr || t == nullptr) {
		return 1;
	}

	// Also ensure that the number of threads executed are valid.
	unsigned int numThreads = t[0] * t[1] * t[2];
	if (numThreads % 32 != 0) {
		return 1;
	}

	// Compute the number of elements.
	unsigned long long int numElements = compute_num_elements(n, m);

	// Now ensure that there are enough total threads (over all blocks) to run the solver.
	if (b[0] * b[1] * b[2] * t[0] * t[1] * t[2] < numElements) {
		fprintf(stderr, "Error[harmonic_execute]: %s\n",
				"Failed to specify enough blocks and threads to execute the solver.");
		return 1;
	}

	// Allocate a heap for dynamic memory allocation inside a kernel. This is required if you ever want
	// to dynamically allocate memory inside kernels. We also know the size of the heap in the worst-case,
	// since each thread will need exactly n. We'll make this 2x the size though, just in case.
//	cudaThreadSetLimit(cudaLimitMallocHeapSize, 128 * 1024 * 1024);
	cudaThreadSetLimit(cudaLimitMallocHeapSize, 2 * numElements * n);

	// Create the running value, which keeps the iterations going so long as at least one element needs updating.
//	unsigned long long int *running = new unsigned long long int[1];
//	*running = 0;
//
//	unsigned long long int *d_running = nullptr;
//	if (cudaMalloc(&d_running, sizeof(unsigned long long int)) != cudaSuccess) {
//		fprintf(stderr, "Error[harmonic_execute]: %s",
//				"Failed to allocate device-side memory for the running variable.");
//		return 2;
//	}

	// Iterate until convergence.
	unsigned long long int iterations = 0;

	// Note: Must ensure that iterations is even so that d_u stores the final result, not d_uPrime.
	while (iterations <= 200) {
//	while (*running > 0) {
//		// Reset delta on the device.
//		if (iterations % stagger == 0) {
//			*running = 0;
//
//			if (cudaMemcpy(d_running, running, sizeof(unsigned long long int), cudaMemcpyHostToDevice) != cudaSuccess) {
//				fprintf(stderr, "Error[harmonic_execute]: %s",
//						"Failed to copy running object from host to device.");
//				return 3;
//			}
//		}

		printf("iteration %i ", iterations);

		// Perform one step of the iteration.
		if (iterations % 2 == 0) {
			printf("first\n");
			harmonic_iteration<<< dim3(b[0], b[1], b[2]), dim3(t[0], t[1], t[2]) >>>(numElements, n, d_m, d_u, d_uPrime, epsilon); //, d_running);
		} else {
			printf("second\n");
			harmonic_iteration<<< dim3(b[0], b[1], b[2]), dim3(t[0], t[1], t[2]) >>>(numElements, n, d_m, d_uPrime, d_u, epsilon); //, d_running);
		}

//		// Copy the running value computed by each thread back to the host.
//		if (iterations % stagger == 0) {
//			if (cudaMemcpy(running, d_running, sizeof(unsigned long long int), cudaMemcpyDeviceToHost) != cudaSuccess) {
//				fprintf(stderr, "Error[harmonic_execute]: %s",
//						"Failed to copy running object from device to host.");
//				return 3;
//			}
//		}

		iterations++;
	}

	printf("Completed in %i iterations.\n", iterations);

	// Free the memory of the delta value.
//	delete [] running;
//	if (cudaFree(d_running) != cudaSuccess) {
//		fprintf(stderr, "Error[harmonic_execute]: %s",
//				"Failed to free memory for the running flag.");
//		return 4;
//	}

	return 0;
}

int harmonic_get(unsigned int n, const unsigned int *m, float *d_u, float *u)
{
	unsigned long long int numElements = compute_num_elements(n, m);

	if (cudaMemcpy(u, d_u, numElements * sizeof(float), cudaMemcpyDeviceToHost) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_get]: %s\n",
				"Failed to copy memory from device to host for the entire result.");
		return 1;
	}
	return 0;
}

//int harmonic_get(const unsigned long long int i, float *d_u, float &val)
//{
//	if (cudaMemcpy(&val, d_u + i * sizeof(float), sizeof(float), cudaMemcpyDeviceToHost) != cudaSuccess) {
//		fprintf(stderr, "Error[harmonic_get]: %s",
//				"Failed to copy memory from device to host for an index.");
//		return 1;
//	}
//	return 0;
//}

int harmonic_free(unsigned int *d_m, float *d_u, float *d_uPrime)
{
	if (cudaFree(d_m) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_free]: %s\n",
				"Failed to free memory for the dimension sizes.");
		return 1;
	}
	if (cudaFree(d_u) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_free]: %s\n",
				"Failed to free memory for the harmonic function.");
		return 1;
	}
	if (cudaFree(d_uPrime) != cudaSuccess) {
		fprintf(stderr, "Error[harmonic_free]: %s\n",
				"Failed to free memory for the harmonic function (prime).");
		return 1;
	}
	return 0;
}