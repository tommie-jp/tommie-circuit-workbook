# test_counter4.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge


async def reset(dut, clocks=2):
    """rst_n を 0 にして clocks 回の立ち上がりを待ち、1 に戻す。"""
    dut.rst_n.value = 0
    for _ in range(clocks):
        await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)      # クロックの谷で入力を変える
    dut.rst_n.value = 1


@cocotb.test()
async def count_up_and_wrap(dut):
    """リセットのあと 1 ずつ増え、15 の次は 0 に戻る。"""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    assert dut.q.value == 0, f"リセット直後の q が {dut.q.value}"

    expected = 0
    for _ in range(20):             # 16 より長く回し、15 → 0 も通す
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)  # 更新が済んだ谷で読む
        expected = (expected + 1) & 0xF
        assert dut.q.value == expected, (
            f"q={dut.q.value}, 期待は {expected}"
        )


@cocotb.test()
async def reset_returns_to_zero(dut):
    """数えている途中でリセットを掛けると 0 に戻る。"""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    for _ in range(5):
        await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.q.value == 5

    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.q.value == 0
