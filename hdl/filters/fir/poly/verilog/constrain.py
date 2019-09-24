#!/usr/bin/env python
"""
Parameterize the Verilog fir_poly file.
"""

from ......scripts import fir

NUMTAPS = 1200
SAMPLING_FREQ = 40e6
NYQUIST_FREQ = SAMPLING_FREQ / 2
BANDS = [0, 0.95e6, 1e6, NYQUIST_FREQ]
BAND_GAIN = [1, 0]
FIR = fir.FIR(NUMTAPS, BANDS, BAND_GAIN, SAMPLING_FREQ, pass_db=0.5)
