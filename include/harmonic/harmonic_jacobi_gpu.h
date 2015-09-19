/**
 *  The MIT License (MIT)
 *
 *  Copyright (c) 2015 Kyle Hollins Wray, University of Massachusetts
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


#ifndef HARMONIC_JACOBI_GPU_H
#define HARMONIC_JACOBI_GPU_H


/**
 *  Compute the fixed point of the 2-dimensional harmonic function provided following
 *  the Jacobi method. The harmonic function u must be defined such that boundaries
 *  or "goal states" (i.e., any fixed value) have the sign bit flipped. All other
 *  values will be modified in-place. The process terminates when the maximal
 *  change between any state is less than epsilon.
 *  @param  harmonic    The Harmonic object.
 *  @param  numThreads  The number of threads, as a multiple of 32 (e.g., 1024).
 *  @return Returns zero upon success, non-zero otherwise.
 */
//extern "C" int harmonic_jacobi_2d_gpu(Harmonic *harmonic, unsigned int numThreads);

/**
 *  Compute the fixed point of the 3-dimensional harmonic function provided following
 *  the Jacobi method. The harmonic function u must be defined such that boundaries
 *  or "goal states" (i.e., any fixed value) have the sign bit flipped. All other
 *  values will be modified in-place. The process terminates when the maximal
 *  maximal change between any state is less than epsilon.
 *  @param  harmonic    The Harmonic object.
 *  @param  numThreads  The number of threads, as a multiple of 32 (e.g., 1024).
 *  @return Returns zero upon success, non-zero otherwise.
 */
//extern "C" int harmonic_jacobi_3d_gpu(Harmonic *harmonic, unsigned int numThreads);

/**
 *  Compute the fixed point of the 3-dimensional harmonic function provided following
 *  the Jacobi method. The harmonic function u must be defined such that boundaries
 *  or "goal states" (i.e., any fixed value) have the sign bit flipped. All other
 *  values will be modified in-place. The process terminates when the maximal
 *  maximal change between any state is less than epsilon.
 *  @param  harmonic    The Harmonic object.
 *  @param  numThreads  The number of threads, as a multiple of 32 (e.g., 1024).
 *  @return Returns zero upon success, non-zero otherwise.
 */
//extern "C" int harmonic_jacobi_4d_gpu(Harmonic *harmonic, unsigned int numThreads);


#endif // HARMONIC_JACOBI_GPU_H
