#!/usr/bin/env python
"""
Parameterize the Verilog fir_poly_2channel file.
"""

from libdigital.tools import fir
import numpy as np

NUMTAPS = 120
SAMPLING_FREQ = 40e6
NYQUIST_FREQ = SAMPLING_FREQ / 2
BANDS = [0, 1e6, 1.5e6, NYQUIST_FREQ]
BAND_GAIN = [1, 0]
FIR = fir.FIR(NUMTAPS, BANDS, BAND_GAIN, SAMPLING_FREQ, pass_db=0.5)

M = 20
M_LOG2 = int(np.ceil(np.log2(M)))
BANK_LEN = int(NUMTAPS / M)
BANK_LEN_LOG2 = int(np.ceil(np.log2(BANK_LEN)))
INPUT_WIDTH = 12
TAP_WIDTH = 16
INTERNAL_WIDTH = INPUT_WIDTH + TAP_WIDTH + int(np.ceil(np.log2(NUMTAPS)))
NORM_SHIFT = FIR.tap_normalization_shift()
OUTPUT_WIDTH = FIR.output_bit_width(INPUT_WIDTH)
DSP_A_WIDTH = 25
DSP_B_WIDTH = 18
DSP_P_WIDTH = 48

with open("fir_poly_defines.vh", "w") as f:
    f.write("`define FIR_POLY_PARAMS parameter \\\n")

    f.write("N_TAPS = {}, \\\n".format(NUMTAPS))
    f.write("M = {}, \\\n".format(M))
    f.write("M_LOG2 = {}, \\\n".format(M_LOG2))
    f.write("BANK_LEN = {}, \\\n".format(BANK_LEN))
    f.write("BANK_LEN_LOG2 = {}, \\\n".format(BANK_LEN_LOG2))
    f.write("INPUT_WIDTH = {}, \\\n".format(INPUT_WIDTH))
    f.write("TAP_WIDTH = {}, \\\n".format(TAP_WIDTH))
    f.write("INTERNAL_WIDTH = {}, \\\n".format(INTERNAL_WIDTH))
    f.write("NORM_SHIFT = {}, \\\n".format(NORM_SHIFT))
    f.write("OUTPUT_WIDTH = {}, \\\n".format(OUTPUT_WIDTH))
    f.write("DSP_A_WIDTH = {}, \\\n".format(DSP_A_WIDTH))
    f.write("DSP_B_WIDTH = {}, \\\n".format(DSP_B_WIDTH))
    f.write("DSP_P_WIDTH = {}".format(DSP_P_WIDTH))
