
// =================================================================================================
// This file is part of the CLTune project. The project is licensed under the MIT license by
// SURFsara, (c) 2014.
//
// Author: cedric.nugteren@surfsara.nl (Cedric Nugteren)
//
// This file contains an example OpenCL kernel as part of the simple.cc example
//
// =================================================================================================

// Parameters set by the tuner
// TS: Tile size of vector X and workgroup size

// Tiled version of the matrix-vector multiplication example. This only tiles the input vector
// X. Note: this kernel assumes that matrix A is pre-transposed.
__kernel void matvec_tiled(const int kSizeM, const int kSizeN,
                           const __global float* mat_a,
                           const __global float* vec_x,
                           __global float* vec_y) {

  // Thread identifiers
  const int i = get_global_id(0); // From 0 to kSizeM-1
  const int tile_id = get_local_id(0); // From 0 to TS-1

  // Initializes the local memory
  __local float vec_x_tile[TS];

  // Initializes the accumulation register
  float result = 0.0f;

  // Loops over the tiles
  for (int t=0; t<kSizeN/TS; ++t) {

    // Loads a tile of the vector x into the local memory
    vec_x_tile[tile_id] = vec_x[t*TS + tile_id];

    // Synchronizes to make sure the tile is loaded
    barrier(CLK_LOCAL_MEM_FENCE);

    // Computes the partial result
    for (int j=0; j<TS; ++j) {
      result += mat_a[(t*TS + j)*kSizeM + i] * vec_x_tile[j];
    }

    // Synchronizes before loading the next tile
    barrier(CLK_LOCAL_MEM_FENCE);
  }

  // Stores the result
  vec_y[i] = result;
}

// =================================================================================================
