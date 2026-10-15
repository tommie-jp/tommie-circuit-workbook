#!/usr/bin/env python3
"""test_asm.py  asm.py の単体試験 (11-6)。python3 test_asm.py で回す (unittest)。

この置き場ではファイル名が 06-asm.py (題の番号つき) なので、名前を指して読み込む。
"""
from __future__ import annotations

import importlib.util
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("asm", os.path.join(HERE, "06-asm.py"))
asm = importlib.util.module_from_spec(_spec)
sys.modules["asm"] = asm     # dataclass が型の名前を引くので、先に登録する
_spec.loader.exec_module(asm)

TD4, TD4X, CPU8, CPU8I = (asm.ISAS[k] for k in ("td4", "td4x", "cpu8", "cpu8i"))


def image(src: str, isa) -> list[int]:
    words, _ = asm.assemble(src, isa)
    return asm.to_image(words, isa)


def read_hex(path: str) -> list[int]:
    """$readmemh のファイルを読む (// から後は注釈)。"""
    vals = []
    with open(os.path.join(HERE, path), encoding="utf-8") as f:
        for line in f:
            tok = line.split("//", 1)[0].split()
            vals.extend(int(t, 16) for t in tok)
    return vals


class TestTd4(unittest.TestCase):
    def test_each_instruction_matches_the_5_8_table(self):
        src = """
            ADD A, 1
            MOV A, B
            IN  A
            MOV A, 2
            MOV B, A
            ADD B, 3
            IN  B
            MOV B, 4
            OUT B
            OUT 5
            JNC 6
            JMP 7
        """
        want = [0x01, 0x10, 0x20, 0x32, 0x40, 0x53, 0x60, 0x74, 0x90, 0xB5, 0xE6, 0xF7]
        self.assertEqual(image(src, TD4)[:12], want)

    def test_program_b_of_5_8(self):
        src = "IN A\nADD A, 1\nMOV B, A\nOUT B\nJMP 0\n"
        self.assertEqual(image(src, TD4)[:5], [0x20, 0x01, 0x40, 0x90, 0xF0])

    def test_program_a_of_5_8_from_led_s(self):
        with open(os.path.join(HERE, "06-td4-led.s"), encoding="utf-8") as f:
            img = image(f.read(), TD4)
        self.assertEqual(img[:10], [0xB3, 0xB6, 0xBC, 0xB8, 0xB8, 0xBC, 0xB6, 0xB3, 0xB1, 0xF0])

    def test_lower_case_and_spaces_are_accepted(self):
        self.assertEqual(image("  mov   a ,  b  ; 注釈\n", TD4)[0], 0x10)

    def test_negative_immediate_wraps_to_4_bits(self):
        self.assertEqual(image("ADD A, -1\n", TD4)[0], 0x0F)

    def test_new_instructions_are_not_in_td4(self):
        for line in ("OUT A", "ADD A, B", "JZ 0", "SUB A, B"):
            with self.subTest(line=line), self.assertRaises(asm.AsmError):
                image(line + "\n", TD4)


class TestTd4x(unittest.TestCase):
    def test_new_instructions(self):
        img = image("OUT A\nADD A, B\nJZ 3\nSUB A, B\n", TD4X)
        self.assertEqual(img[:4], [0x80, 0xA0, 0xC3, 0xD0])

    def test_sum_s_equals_the_hand_written_hex_of_11_5(self):
        with open(os.path.join(HERE, "06-td4x-sum.s"), encoding="utf-8") as f:
            self.assertEqual(image(f.read(), TD4X), read_hex("05-td4x-sum.hex"))

    def test_cmp_s_equals_the_hand_written_hex_of_11_5(self):
        with open(os.path.join(HERE, "06-td4x-cmp.s"), encoding="utf-8") as f:
            self.assertEqual(image(f.read(), TD4X), read_hex("05-td4x-cmp.hex"))

    def test_mov_a_b_is_register_form_not_immediate(self):
        # B はレジスタの名前なので、値 (ラベル) とは読まない
        self.assertEqual(image("MOV A, B\n", TD4X)[0], 0x10)


class TestLabelsAndDirectives(unittest.TestCase):
    def test_forward_and_backward_labels(self):
        src = "top: JMP end\n     JMP top\nend: JMP end\n"
        self.assertEqual(image(src, TD4)[:3], [0xF2, 0xF0, 0xF2])

    def test_equ_and_expression(self):
        src = ".equ BASE, 3\nMOV A, BASE + 2\nMOV B, BASE - 1\n"
        self.assertEqual(image(src, TD4)[:2], [0x35, 0x72])

    def test_org_and_db(self):
        src = "JMP 0\n.org 0x0E\n.db 0xAB, 0b1100\n"
        img = image(src, TD4)
        self.assertEqual((img[0], img[14], img[15]), (0xF0, 0xAB, 0x0C))

    def test_label_on_its_own_line(self):
        self.assertEqual(image("here:\n  JMP here\n", TD4)[0], 0xF0)

    def test_symbols_are_returned(self):
        _, sym = asm.assemble("p: JMP q\nq: JMP p\n.equ K, 9\n", TD4)
        self.assertEqual(sym, {"p": 0, "q": 1, "K": 9})


class TestErrors(unittest.TestCase):
    def assert_error(self, src: str, isa, line_no: int, fragment: str):
        with self.assertRaises(asm.AsmError) as cm:
            asm.assemble(src, isa)
        self.assertEqual(cm.exception.line_no, line_no)
        self.assertIn(fragment, cm.exception.message)

    def test_unknown_mnemonic(self):
        self.assert_error("JMP 0\nFOO 1\n", TD4, 2, "知らない命令")

    def test_wrong_operand_form(self):
        self.assert_error("MOV B, B\n", TD4, 1, "引数の形")

    def test_immediate_out_of_range(self):
        self.assert_error("MOV A, 16\n", TD4, 1, "4 ビットに入りません")
        self.assert_error("LDI 256\n", CPU8, 1, "8 ビットに入りません")

    def test_undefined_label(self):
        self.assert_error("JMP nowhere\n", TD4, 1, "定義されていない")

    def test_duplicate_label(self):
        self.assert_error("x: JMP x\nx: JMP x\n", TD4, 2, "2 回")

    def test_register_name_as_label(self):
        # 引数は大文字・小文字を区別しないので、a も A と同じに扱う
        self.assert_error("a: JMP 0\n", TD4, 1, "レジスタの名前")
        self.assert_error(".equ B, 3\n", TD4, 1, "レジスタの名前")

    def test_program_too_big(self):
        self.assert_error("JMP 0\n" * 17, TD4, 17, "メモリ (16 語) の外")

    def test_org_backwards(self):
        self.assert_error(".org 4\nJMP 0\n.org 2\n", TD4, 3, "より前")

    def test_bad_expression(self):
        self.assert_error("MOV A, 1 2\n", TD4, 1, "式が読めません")


class TestCpu8(unittest.TestCase):
    def test_two_words_per_instruction(self):
        img = image("LDI 5\nADD x\nOUT\nHLT\nx: .db 7\n", CPU8)
        self.assertEqual(img[:9], [0x01, 0x05, 0x04, 0x08, 0x19, 0x00, 0x1F, 0x00, 0x07])

    def test_every_opcode(self):
        for mnem, pattern, code in CPU8.table:
            src = f"{mnem} 3\n" if pattern else f"{mnem}\n"
            with self.subTest(mnem=mnem):
                self.assertEqual(image(src, CPU8)[:2], [code, 3 if pattern else 0])

    def test_interrupt_instructions_only_in_cpu8i(self):
        self.assertEqual(image("EI\nDI\nRETI\n", CPU8I)[:6], [0x20, 0, 0x21, 0, 0x22, 0])
        with self.assertRaises(asm.AsmError):
            image("EI\n", CPU8)

    def test_negative_operand_is_twos_complement(self):
        self.assertEqual(image("ADDI -1\n", CPU8)[:2], [0x06, 0xFF])


class TestOutput(unittest.TestCase):
    def test_readmemh_has_one_line_per_word_and_notes(self):
        words, _ = asm.assemble("loop: JMP loop\n", TD4)
        text = asm.to_readmemh(words, TD4, "t")
        lines = text.splitlines()
        self.assertEqual(lines[0], "// t")
        self.assertEqual(len(lines), 1 + 16)
        self.assertEqual(lines[1], "F0 // 00: loop: JMP loop")
        self.assertEqual(lines[2], "00")

    def test_main_reports_file_and_line_on_error(self):
        import contextlib
        import io
        import tempfile
        with tempfile.NamedTemporaryFile("w", suffix=".s", delete=False, encoding="utf-8") as f:
            f.write("JMP 0\nBAD\n")
            name = f.name
        err = io.StringIO()
        try:
            with contextlib.redirect_stderr(err):
                rc = asm.main(["--isa", "td4", name])
        finally:
            os.unlink(name)
        self.assertEqual(rc, 1)
        self.assertIn(f"{name}:2: 知らない命令", err.getvalue())


if __name__ == "__main__":
    unittest.main()
