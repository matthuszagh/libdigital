#!/usr/bin/env python
"""
Parameterize the Verilog fft_r22sdf file.
"""

from libdigital.tools import fir
import numpy as np
import math

N = 1024
if N % 4 != 0:
    print("Error: {} is not a power of 4", N)
    exit(1)

N_LOG2 = int(np.log2(N))
N_STAGES = int(math.log(N, 4))
# TODO this should be FIR output width
INPUT_WIDTH = 14
TWIDDLE_WIDTH = 10
INTERNAL_WIDTH = INPUT_WIDTH + N_LOG2 + 1
OUTPUT_WIDTH = INTERNAL_WIDTH

with open("fft_r22sdf_defines.vh", "w") as f:
    f.write("`define FFT_PARAMS parameter \\\n")

    f.write("N = {}, \\\n".format(N))
    f.write("N_LOG2 = {}, \\\n".format(N_LOG2))
    f.write("N_STAGES = {}, \\\n".format(N_STAGES))
    f.write("INPUT_WIDTH = {}, \\\n".format(INPUT_WIDTH))
    f.write("TWIDDLE_WIDTH = {}, \\\n".format(TWIDDLE_WIDTH))
    f.write("INTERNAL_WIDTH = {}, \\\n".format(INTERNAL_WIDTH))
    f.write("OUTPUT_WIDTH = {}".format(OUTPUT_WIDTH))
