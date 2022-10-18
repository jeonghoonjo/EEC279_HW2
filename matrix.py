#!/usr/bin/env python3

import sys
import time
import argparse
import numpy as np
from numpy.random import Generator, PCG64, SeedSequence

OUT = sys.stdout

HEADER = """%%MatrixMarket matrix array real general
% Generated with seed {0}
"""

def gen_matrix(m, n, filename, seed):
    rng = Generator(PCG64(SeedSequence(seed)))
    data = rng.random((m, n))

    lines = [ HEADER.format(seed), f"{m} {n}\n" ] + [ f"{num:.10f}\n" for num in data.reshape(-1) ]

    with open(filename, 'w', newline='\n') as fh:
        fh.writelines(lines)


def get_seed():
    return int(time.time() * 10000)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate random m x n matrices')
    parser.add_argument('rows', metavar='rows', type=int,
                    help='Number of rows')
    parser.add_argument('cols', metavar='cols', type=int,
                    help='Number of cols')
    parser.add_argument('file', metavar='file', type=str,
                    help='Name of file to write to')
    parser.add_argument('seed', metavar='seed', type=float, nargs='?',
                    help='Seed to use to generate matrix elements')

    cli_opts = parser.parse_args()

    gen_matrix(cli_opts.rows, cli_opts.cols, cli_opts.file, seed = get_seed() if cli_opts.seed == None else cli_opts.seed)
