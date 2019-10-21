#!/usr/bin/env python
"""
Unit tests for async_fifo.v
"""

import random

from libdigital.tools.cocotb_helpers import *

import cocotb
from cocotb.result import TestFailure
from cocotb.triggers import *
from cocotb.clock import *
from cocotb.binary import *


def retrieve_clocks(dut):
    """Access clocks."""
    clocks = [(dut.rdclk, 60), (dut.wrclk, 40)]
    return clocks


def gen_clocks(dut):
    """
    Generate testbench clock signals.
    """
    clocks = retrieve_clocks(dut)
    freqs = [clock[1] for clock in clocks]
    periods = clock_valid_periods(freqs)
    clock_objs = [clock[0] for clock in clocks]
    for i, _ in enumerate(periods):
        clk = Clock(clock_objs[i], periods[i], "ns")
        cocotb.fork(clk.start())


@cocotb.coroutine
async def reset(dut):
    """
    Trigger a synchronous reset and ensure all clocks register it.
    """
    trigs = []
    for clk in retrieve_clocks(dut):
        trigs.append(RisingEdge(clk[0]))

    await Combine(*trigs)
    dut.rst_n <= 0
    dut.wren <= 0
    dut.rden <= 0
    await Combine(*trigs)
    dut.rst_n <= 1


@cocotb.coroutine
async def setup_dut(dut):
    """Instantiate test module."""
    gen_clocks(dut)
    await reset(dut)


@cocotb.coroutine
async def write_val(dut, val):
    """Write a value to the FIFO."""
    dut.wren <= 1
    dut.wrdata <= val
    await RisingEdge(dut.wrclk)


@cocotb.coroutine
async def read_val(dut):
    """Read a value from the FIFO."""
    await NextTimeStep()
    dut.rden <= 1
    await RisingEdge(dut.rdclk)
    await ReadOnly()
    return dut.rddata.value


@cocotb.coroutine
async def wait_n_cycles(dut, n, clk):
    """Wait n cycles for clock clk."""
    dut.wren <= 0
    dut.rden <= 0
    while n > 0:
        n -= 1
        await RisingEdge(clk)


@cocotb.test()
async def write_and_check_addr(dut):
    """
    Write a single value to the FIFO and ensure the internal address
    increments.
    """
    await setup_dut(dut)
    await ReadOnly()
    old_addr = dut.wraddr.value.integer
    await RisingEdge(dut.wrclk)
    dut.wren <= 1
    await RisingEdge(dut.wrclk)
    await ReadOnly()
    if dut.wraddr.value.integer != old_addr + 1:
        raise TestFailure(
            (
                "Write failed to increment internal FIFO address (wraddr)."
                " Actual: %d, expected: %d."
            )
            % (dut.wraddr.value.integer, old_addr.value.integer + 1)
        )


@cocotb.test()
async def write_single_val_immediate_read(dut):
    """
    Write a single value to the FIFO, immediately read and check the
    values match.
    """
    await setup_dut(dut)
    wrval = random.randint(0, 2 ** 64 - 1)
    await write_val(dut, wrval)
    rdval = await read_val(dut)
    if wrval != rdval.integer:
        raise TestFailure(
            ("Write value differs from read value." " Write: %d, read: %d.")
            % (wrval, rdval.integer)
        )


@cocotb.test()
async def write_single_val_delay_read(dut):
    """
    Write a single value to the FIFO, wait some number of clock cycles
    and then read and check that the values match.
    """
    await setup_dut(dut)
    wrval = random.randint(0, 2 ** 64 - 1)
    await write_val(dut, wrval)
    await wait_n_cycles(dut, 20, dut.rdclk)
    rdval = await read_val(dut)
    if wrval != rdval.integer:
        raise TestFailure(
            ("Write value differs from read value." " Write: %d, read: %d.")
            % (wrval, rdval.integer)
        )


@cocotb.test()
async def write_sequence_continuous_immediate_read_sequence_continuous(dut):
    """
    Write an uninterrupted sequence of values to the FIFO, then
    immediately read them (also uninterrupted) and check that the
    values match.
    """
    await setup_dut(dut)
    num_items = 500
    wrvals = [random.randint(0, 2 ** 64 - 1) for n in range(num_items)]
    for i, _ in enumerate(wrvals):
        await write_val(dut, wrvals[i])

    for i in range(num_items):
        rdval = await read_val(dut)
        if wrvals[i] != rdval.integer:
            raise TestFailure(
                (
                    "Sequence item %d: Write value differs from read value."
                    " Write: %d, read: %d."
                )
                % (i, wrvals[i], rdval.integer)
            )


@cocotb.test()
async def write_sequence_continuous_delay_read_sequence_continuous(dut):
    """
    Write an uninterrupted sequence of values to the FIFO, delay some
    number of read clock cycles then read them (also uninterrupted)
    and check that the values match.
    """
    await setup_dut(dut)
    num_items = 500
    wrvals = [random.randint(0, 2 ** 64 - 1) for n in range(num_items)]
    for i, _ in enumerate(wrvals):
        await write_val(dut, wrvals[i])

    await wait_n_cycles(dut, random.randint(0, 100), dut.rdclk)

    for i in range(num_items):
        rdval = await read_val(dut)
        if wrvals[i] != rdval.integer:
            raise TestFailure(
                (
                    "Sequence item %d: Write value differs from read value."
                    " Write: %d, read: %d."
                )
                % (i, wrvals[i], rdval.integer)
            )


@cocotb.test()
async def write_sequence_broken_delay_read_sequence_continuous(dut):
    """
    Write a sequence of values (interspersed with non-writes) to the
    FIFO, delay some number of read clock cycles then read them
    (uninterrupted) and check that the values match.
    """
    await setup_dut(dut)
    num_items = 500
    wrvals = [random.randint(0, 2 ** 64 - 1) for n in range(num_items)]
    interrupt = 1
    i = 0
    while i < len(wrvals):
        if i % 10 == 0:
            if interrupt:
                await wait_n_cycles(dut, 1, dut.wrclk)
                interrupt = 0
                continue
            else:
                interrupt = 1

        await write_val(dut, wrvals[i])
        i += 1

    await wait_n_cycles(dut, random.randint(0, 100), dut.rdclk)

    for i in range(num_items):
        rdval = await read_val(dut)
        if wrvals[i] != rdval.integer:
            raise TestFailure(
                (
                    "Sequence item %d: Write value differs from read value."
                    " Write: %d, read: %d."
                )
                % (i, wrvals[i], rdval.integer)
            )
