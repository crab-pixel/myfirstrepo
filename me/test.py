# AI-assisted file: generated with OpenAI Codex.
# This Cocotb smoke test is intended to be placed in the Tiny Tapeout
# template's test/test.py after its author has read and understood it.

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, ReadOnly, RisingEdge


PIXEL_CLOCK_PERIOD_NS = 39.722
HORIZONTAL_LINE_CYCLES = 800
HORIZONTAL_SYNC_LOW_CYCLES = 96
HSYNC_OUTPUT_BIT = 7
VSYNC_OUTPUT_BIT = 3


def output_bit(dut, bit_number):
    return (int(dut.uo_out.value) >> bit_number) & 1


@cocotb.test()
async def test_vga_sync_and_unused_pins(dut):
    """Check the top-level reset state and one complete HSYNC period."""
    cocotb.start_soon(
        Clock(dut.clk, PIXEL_CLOCK_PERIOD_NS, unit="ns").start()
    )

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.uio_oe.value) == 0, "All bidirectional pins must be inputs"
    assert int(dut.uio_out.value) == 0, "Bidirectional outputs must be zero"
    assert output_bit(dut, VSYNC_OUTPUT_BIT) == 1, "VSYNC should start inactive"

    hsync_low_count = 0
    for _ in range(HORIZONTAL_LINE_CYCLES):
        await RisingEdge(dut.clk)
        await ReadOnly()
        if output_bit(dut, HSYNC_OUTPUT_BIT) == 0:
            hsync_low_count += 1

    assert hsync_low_count == HORIZONTAL_SYNC_LOW_CYCLES, (
        f"Expected {HORIZONTAL_SYNC_LOW_CYCLES} low HSYNC cycles, "
        f"observed {hsync_low_count}"
    )
