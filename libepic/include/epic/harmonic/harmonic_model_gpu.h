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


#ifndef HARMONIC_MODEL_GPU_H
#define HARMONIC_MODEL_GPU_H


#include "harmonic.h"

namespace epic {

/**
 *  Initialize CUDA by transferring dimension size information to the device.
 *  @param  harmonic    The Harmonic object.
 *  @return Returns zero upon success, non-zero otherwise.
 */
extern "C" int harmonic_initialize_dimension_size_gpu(Harmonic *harmonic);

/**
 *  Uninitialize CUDA by transferring dimension size information to the device.
 *  @param  harmonic    The Harmonic object.
 *  @return Returns zero upon success, non-zero otherwise.
 */
extern "C" int harmonic_uninitialize_dimension_size_gpu(Harmonic *harmonic);

/**
 *  Initialize CUDA by transferring potential value information to the device.
 *  @param  harmonic    The Harmonic object.
 *  @return Returns zero upon success, non-zero otherwise.
 */
extern "C" int harmonic_initialize_potential_values_gpu(Harmonic *harmonic);

/**
 *  Uninitialize CUDA by transferring potential value information to the device.
 *  @param  harmonic    The Harmonic object.
 *  @return Returns zero upon success, non-zero otherwise.
 */
extern "C" int harmonic_uninitialize_potential_values_gpu(Harmonic *harmonic);

/**
 *  Initialize CUDA by transferring locked information to the device.
 *  @param  harmonic    The Harmonic object.
 *  @return Returns zero upon success, non-zero otherwise.
 */
extern "C" int harmonic_initialize_locked_gpu(Harmonic *harmonic);

/**
 *  Uninitialize CUDA by transferring locked information to the device.
 *  @param  harmonic    The Harmonic object.
 *  @return Returns zero upon success, non-zero otherwise.
 */
extern "C" int harmonic_uninitialize_locked_gpu(Harmonic *harmonic);

/**
 *  Update the potential values and the locked values from host to device.
 *  @param  harmonic    The Harmonic object.
 *  @return Returns zero upon success, non-zero otherwise.
 */
extern "C" int harmonic_update_model_gpu(Harmonic *harmonic);

};


#endif // HARMONIC_MODEL_GPU_H

