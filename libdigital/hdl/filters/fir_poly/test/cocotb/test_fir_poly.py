#!/usr/bin/env python
"""
Unit tests for fir_poly.
"""

import numpy as np
from scipy import signal

from libdigital.tools.cocotb_helpers import Clock, ClockEnable
from libdigital.tools.fir import FIR
from libdigital.tools import bit

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, ReadOnly
from cocotb.result import TestFailure


class FIRTB:
    """
    FIR testbench class.
    """

    def __init__(self, dut):
        self.clk = Clock(dut.clk, 40)
        self.clk_en = ClockEnable(dut.clk, dut.clk_2mhz_pos_en, dut.rst_n, 20)
        self.dut = dut

    @cocotb.coroutine
    async def setup(self):
        """
        Initialize FIR filter in a defined state.
        """
        cocotb.fork(self.clk.start())
        cocotb.fork(self.clk_en.start())
        await self.reset()

    @cocotb.coroutine
    async def reset(self):
        """
        Assert a reset and ensure it's registered by the clock.
        """
        await RisingEdge(self.dut.clk)
        self.dut.rst_n <= 0
        await RisingEdge(self.dut.clk)
        self.dut.rst_n <= 1

    @cocotb.coroutine
    async def write_continuous(self, inputs):
        """
        Continously write inputs. When inputs have been exhausted, write
        zeros.
        """
        sample_ctr = 0
        num_samples = len(inputs)
        while True:
            if sample_ctr < num_samples:
                self.dut.din <= inputs[sample_ctr].item()
            else:
                self.dut.din <= 0
            sample_ctr += 1
            await RisingEdge(self.dut.clk)


@cocotb.test()
async def check_sequence(dut):
    """
    Compare the output from a randomly-generated sequence with scipy.
    """
    fir = FIR(
        numtaps=120,
        bands=[0, 0.95e6, 1e6, 20e6],
        band_gain=[1, 0],
        fs=40e6,
        pass_db=0.5,
        stop_db=-40,
    )
    tb = FIRTB(dut)
    await tb.setup()
    num_samples = 10000
    downsample_factor = 20
    num_outputs = int(num_samples / downsample_factor)
    input_width = 12
    quantize_taps = True
    tap_width = 16

    input_seq = np.zeros(num_samples)
    for i, _ in enumerate(input_seq):
        input_seq[i] = np.random.randint(
            -2 ** (input_width - 1), 2 ** (input_width - 1)
        )
    input_seq = input_seq.astype(int)
    cocotb.fork(tb.write_continuous(input_seq))

    if quantize_taps:
        taps = fir.quantized_taps(tap_width)
    else:
        taps = fir.taps

    out_pre_dec = np.convolve(input_seq, taps)
    outputs = [out_pre_dec[i] for i in range(len(out_pre_dec)) if i % 20 == 0]
    # outputs = signal.resample_poly(input_seq, 1, downsample_factor, 0, taps)

    tol = 2
    i = num_outputs
    clk_en_ctr = 0
    diffs = []
    while i > 0:
        await FallingEdge(tb.dut.clk_2mhz_pos_en)
        await ReadOnly()
        if tb.dut.dvalid.value.integer:
            out_val = tb.dut.dout.value.signed_integer
            out_exp = int(round(outputs[num_outputs - i].item()))
            diffs.append(out_val - out_exp)
            # print(
            #     "expected: {:5}, actual: {:5}, difference: {:5}".format(
            #         out_exp, out_val, out_val - out_exp
            #     )
            # )
            if abs(out_val - out_exp) > tol:
                raise TestFailure(
                    (
                        "Actual output differs from expected."
                        " Actual: %d, expected: %d. Tolerance set at %d."
                    )
                    % (out_val, out_exp, tol)
                )

            i -= 1


@cocotb.test()
async def bank_output_vals(dut):
    """
    Ensure the bank output values are correct at all points time.
    """
    fir = FIR(
        numtaps=120,
        bands=[0, 0.95e6, 1e6, 20e6],
        band_gain=[1, 0],
        fs=40e6,
        pass_db=0.5,
        stop_db=-40,
    )
    tb = FIRTB(dut)
    await tb.setup()
    num_samples = 10000
    downsample_factor = 20
    num_outputs = int(num_samples / downsample_factor)
    input_width = 12
    quantize_taps = False
    tap_width = 16
    norm_shift = 3

    input_seq = np.zeros(num_samples)
    for i, _ in enumerate(input_seq):
        input_seq[i] = np.random.randint(
            -2 ** (input_width - 1), 2 ** (input_width - 1)
        )
    input_seq = input_seq.astype(int)
    cocotb.fork(tb.write_continuous(input_seq))

    if quantize_taps:
        taps = fir.quantized_taps(tap_width)
    else:
        taps = fir.taps

    i = num_outputs
    bank_outs = np.zeros(downsample_factor, dtype=int)
    while i > 0:
        outputs_count_up = num_outputs - i
        cur_input_index = downsample_factor * outputs_count_up
        last_120_inputs_indices = np.linspace(
            max(cur_input_index - 120, 0),
            cur_input_index,
            min(cur_input_index + 1, 120),
            dtype=int,
        )
        last_120_inputs_indices = np.flip(last_120_inputs_indices)
        bank_outs.fill(0)

        for j, input_index in enumerate(last_120_inputs_indices):
            # print(j)
            # print(input_index)
            # print(last_120_inputs_indices)
            # print(input_seq[input_index])
            # print(
            #     bit.sub_integral_to_sint(
            #         fir.taps[j] * (2 ** norm_shift), tap_width
            #     )
            # )
            # print(bank_outs)
            bank_outs[j % 20] += input_seq[
                input_index
            ] * bit.sub_integral_to_sint(
                fir.taps[j] * (2 ** norm_shift), tap_width
            )
            # print(bank_outs)
            # print("\n")

        await RisingEdge(tb.dut.clk_2mhz_pos_en)
        await ReadOnly()
        # if tb.dut.dvalid.value.integer:
        bank_output_vars = [
            tb.dut.bank0.dout,
            tb.dut.bank1.dout,
            tb.dut.bank2.dout,
            tb.dut.bank3.dout,
            tb.dut.bank4.dout,
            tb.dut.bank5.dout,
            tb.dut.bank6.dout,
            tb.dut.bank7.dout,
            tb.dut.bank8.dout,
            tb.dut.bank9.dout,
            tb.dut.bank10.dout,
            tb.dut.bank11.dout,
            tb.dut.bank12.dout,
            tb.dut.bank13.dout,
            tb.dut.bank14.dout,
            tb.dut.bank15.dout,
            tb.dut.bank16.dout,
            tb.dut.bank17.dout,
            tb.dut.bank18.dout,
            tb.dut.bank19.dout,
        ]

        for bank in range(downsample_factor):
            bank_out = bank_output_vars[bank].value.signed_integer
            exp_out = bank_outs[bank]
            if bank_out != exp_out:
                raise TestFailure(
                    (
                        "Actual bank %d output differs from expected."
                        " Actual: %d, expected: %d."
                    )
                    % (bank, bank_out, exp_out)
                )

        i -= 1
