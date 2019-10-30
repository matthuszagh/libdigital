#!/usr/bin/env python

from libdigital.tools.fir import FIR

fir = FIR(
    numtaps=120,
    bands=[0, 0.95e6, 1e6, 20e6],
    band_gain=[1, 0],
    fs=40e6,
    pass_db=0.5,
    stop_db=-40,
)

tap_bits = 16
input_bits = 12
downsample_factor = 20
fir.write_poly_taps_files(
    ["../taps"], tap_bits, downsample_factor, True, False
)
print("normalization shift: {}".format(fir.tap_normalization_shift()))
print("output bits: {}".format(fir.output_bit_width(input_bits)))
