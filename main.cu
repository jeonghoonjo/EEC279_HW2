#include <utility>
#include <cassert>
#include <iostream>
#include "matrix.hpp"

#define CUDA_CHECK_ERROR(X) do { \
    auto ret_code  = X; \
    if (ret_code != 0) { \
        std::cerr << __FILE__ << ":" << __LINE__ << \
        ": CUDA assertion failed: " << cudaGetErrorString(ret_code) << '\n' ; \
        std::flush(std::cout); \
        std::flush(std::cerr); \
        assert(ret_code == 0); \
    } \
} while(0)

void print_matrix(const float* data, size_t rows, size_t cols) {
    std::cout << rows << " x " << cols << '\n';
    for (size_t i = 0; i < rows; ++i) {
        for (size_t j = 0; j < cols; ++j) {
            // print 6 decimal places, padded to 10 total characters
            // printf("% 10.6f   ", mat.data()[mat.rows * i + j]);

            // print 0 decimal places, padded to 5 characters - for wikipedia test data
            printf("%5.0f", data[(cols * i) + j]);
        }
        printf("\n");
    }
    printf("\n");
}

void print_matrix(const matrix::matrix_t& mat) {
    print_matrix(mat.data(), mat.rows, mat.cols);
}

void scale_matrix(
    const float scale,
    const float *b,
    float *c,
    size_t x, // block inx in mat c
    size_t y, // block inx in mat c
    size_t stride, // elements to jump in c to access only the blocks
    size_t b_rows,
    size_t b_cols) {

    for (size_t i = 0; i < b_rows; ++i) {
        for (size_t j = 0; j < b_cols; ++j) {
            auto c_flat_inx = (i + x * b_rows) * stride + (j + y * b_cols);
            c[c_flat_inx] = scale * b[i * b_cols + j];
        }
    }
}

void
unpartitionedKhatriRaoProduct(float * C, const float * A, const float * B,
                              unsigned int ah, unsigned int aw,
                              unsigned int bh, unsigned int bw) {
    for (int i = 0; i < ah; ++i) {
        for (int j = 0; j < aw; ++j) {
            // for each block, scale matrix B with element from A, and store into C
            scale_matrix(
                A[aw * i + j],
                B,
                C,
                i, // locate block a[i,j] * B
                j, // locate block a[i,j] * B
                aw * bw,  // stride is a_col * b_col
                bh,
                bw
            );
        }
    }
}

int main(int argc, const char *argv[]) {

    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " mata matb\n";
        return -1;
    }

    // read in the matrix, returns types matrix::matrix_t, in a std::vector<float>
    const auto mat_a = matrix::load_matrix(std::string { argv[1] });
    const auto mat_b = matrix::load_matrix(std::string { argv[2] });

    // The Khatri-Rao product of two arbitrary-sized unpartitioned matrices. This is
    // the equivalent of the Kronecker product of these two matrices.
    // if A is an m x n matrix and B is a p x q matrix, then the Kronecker product C = A ⊗ B is the
    // pm x qn block matrix
    auto [m, n] = std::pair(mat_a.rows, mat_a.cols); // same as m = mat_a.row, n = mat_a.cols
    auto [p, q] = std::pair(mat_b.rows, mat_b.cols); // same as p = mat_b.row, q = mat_b.cols

    matrix::matrix_t mat_c {};
    mat_c.rows = (m * p);
    mat_c.cols = (n * q);

    // allocate and initialize memory for mat_c
    mat_c.arr.resize( (m * p) * (n * q) );

    unpartitionedKhatriRaoProduct(
        mat_c.data(),
        mat_a.data(),
        mat_b.data(),
        mat_a.rows, mat_a.cols,
        mat_b.rows, mat_b.cols
    );

    print_matrix(mat_a);
    print_matrix(mat_b);
    print_matrix(mat_c);

    return EXIT_SUCCESS;
}
