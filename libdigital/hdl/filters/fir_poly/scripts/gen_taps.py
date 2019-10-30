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

fir.write_poly_taps_files(["../taps"], 16, 20, True, False)
