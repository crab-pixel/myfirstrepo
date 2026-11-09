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
    cocotb.start_soon(Clock(dut.clk, PIXEL_CLOCK_PERIOD_NS, unit="ns").start())
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    await RisingEdge(dut.clk)
    await ReadOnly()
    assert int(dut.uio_oe.value) == 0
    assert int(dut.uio_out.value) == 0
    assert output_bit(dut, VSYNC_OUTPUT_BIT) == 1

    hsync_low_count = 0
    for _ in range(HORIZONTAL_LINE_CYCLES):
        await RisingEdge(dut.clk)
        await ReadOnly()
        if output_bit(dut, HSYNC_OUTPUT_BIT) == 0:
            hsync_low_count += 1
    assert hsync_low_count == HORIZONTAL_SYNC_LOW_CYCLES
