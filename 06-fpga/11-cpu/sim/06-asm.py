#!/usr/bin/env python3
"""asm.py  小さな CPU のアセンブラ (11-6)。

命令表を差し替えて、TD4 (5-8)・TD4X (11-5)・cpu8 (11-11)・cpu8i (11-10) の 4 つを扱う。
出力は Verilog の $readmemh で読める 16 進 (1 行 1 語)。

    python3 asm.py --isa td4x sum.s -o sum.hex
    python3 asm.py --isa cpu8 mul.s --list

書き方 (1 行に 1 つ):
    label:  MNEMONIC 引数, 引数   ; 注釈
    .org  番地          ここから置く
    .db   値, 値, ...   1 語ずつ置く
    .equ  名前, 値      名前に値を付ける
値は 10 進・0x (16 進)・0b (2 進)・ラベル・.equ の名前と、それらの + と -。
"""
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass

IMM = "imm"  # 引数の型: 値 (即値か番地)。ほかは "A" "B" のように、その字そのもの


@dataclass(frozen=True)
class Isa:
    """命令表。layout が "nibble" なら 1 語 = 上 4 ビットの命令 + 下 4 ビットの即値 (TD4)。
    "byte2" なら命令 1 語 + 引数 1 語の 2 語 (cpu8)。"""

    name: str
    mem_words: int
    layout: str
    table: tuple[tuple[str, tuple[str, ...], int], ...]

    @property
    def imm_bits(self) -> int:
        return 4 if self.layout == "nibble" else 8

    @property
    def size(self) -> int:
        return 1 if self.layout == "nibble" else 2

    def registers(self) -> set[str]:
        return {o for _, ops, _ in self.table for o in ops if o != IMM}


TD4_TABLE = (
    ("ADD", ("A", IMM), 0x0),
    ("MOV", ("A", "B"), 0x1),
    ("IN", ("A",), 0x2),
    ("MOV", ("A", IMM), 0x3),
    ("MOV", ("B", "A"), 0x4),
    ("ADD", ("B", IMM), 0x5),
    ("IN", ("B",), 0x6),
    ("MOV", ("B", IMM), 0x7),
    ("OUT", ("B",), 0x9),
    ("OUT", (IMM,), 0xB),
    ("JNC", (IMM,), 0xE),
    ("JMP", (IMM,), 0xF),
)
TD4X_EXTRA = (
    ("OUT", ("A",), 0x8),
    ("ADD", ("A", "B"), 0xA),
    ("JZ", (IMM,), 0xC),
    ("SUB", ("A", "B"), 0xD),
)
CPU8_TABLE = (
    ("NOP", (), 0x00),
    ("LDI", (IMM,), 0x01),
    ("LD", (IMM,), 0x02),
    ("ST", (IMM,), 0x03),
    ("ADD", (IMM,), 0x04),
    ("SUB", (IMM,), 0x05),
    ("ADDI", (IMM,), 0x06),
    ("SUBI", (IMM,), 0x07),
    ("AND", (IMM,), 0x08),
    ("OR", (IMM,), 0x09),
    ("XOR", (IMM,), 0x0A),
    ("SHL", (), 0x0B),
    ("SHR", (), 0x0C),
    ("JMP", (IMM,), 0x10),
    ("JZ", (IMM,), 0x11),
    ("JNZ", (IMM,), 0x12),
    ("JC", (IMM,), 0x13),
    ("JNC", (IMM,), 0x14),
    ("IN", (), 0x18),
    ("OUT", (), 0x19),
    ("HLT", (), 0x1F),
)
CPU8I_EXTRA = (
    ("EI", (), 0x20),
    ("DI", (), 0x21),
    ("RETI", (), 0x22),
)

ISAS = {
    "td4": Isa("td4", 16, "nibble", TD4_TABLE),
    "td4x": Isa("td4x", 16, "nibble", TD4_TABLE + TD4X_EXTRA),
    "cpu8": Isa("cpu8", 256, "byte2", CPU8_TABLE),
    "cpu8i": Isa("cpu8i", 256, "byte2", CPU8_TABLE + CPU8I_EXTRA),
}


class AsmError(Exception):
    """行の番号つきの誤り。"""

    def __init__(self, line_no: int, message: str):
        super().__init__(f"{line_no}: {message}")
        self.line_no = line_no
        self.message = message


@dataclass(frozen=True)
class Line:
    no: int          # 元の行の番号 (1 から)
    text: str        # 元の行から注釈 (; から後) を除いた字
    label: str | None
    op: str | None   # 命令か疑似命令 (大文字)
    args: tuple[str, ...]


@dataclass(frozen=True)
class Word:
    addr: int
    value: int
    line: Line


NAME_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*$")
TOKEN_RE = re.compile(r"\s*([+-])?\s*([^+\-\s]+)")


def parse_line(no: int, raw: str) -> Line:
    code = raw.split(";", 1)[0].rstrip()
    text = code.strip()
    label = None
    if ":" in text:
        head, text = text.split(":", 1)
        head = head.strip()
        if not NAME_RE.match(head):
            raise AsmError(no, f"ラベルの名前にできない字です: {head!r}")
        label = head
        text = text.strip()
    if not text:
        return Line(no, code, label, None, ())
    parts = text.split(None, 1)
    op = parts[0].upper()
    args = tuple(a.strip() for a in parts[1].split(",")) if len(parts) > 1 else ()
    if any(a == "" for a in args):
        raise AsmError(no, "空の引数があります")
    return Line(no, code, label, op, args)


def parse_number(tok: str) -> int | None:
    t = tok.lower()
    try:
        if t.startswith("0x"):
            return int(t[2:], 16)
        if t.startswith("0b"):
            return int(t[2:], 2)
        if t.isdigit():
            return int(t, 10)
    except ValueError:
        return None
    return None


def evaluate(expr: str, symbols: dict[str, int], no: int) -> int:
    """値の式 (項を + と - でつないだもの) を計算する。"""
    pos, total, first = 0, 0, True
    expr = expr.strip()
    while pos < len(expr):
        m = TOKEN_RE.match(expr, pos)
        if not m or (m.group(1) is None and not first):
            raise AsmError(no, f"式が読めません: {expr!r}")
        sign = -1 if m.group(1) == "-" else 1
        tok = m.group(2)
        val = parse_number(tok)
        if val is None:
            if not NAME_RE.match(tok):
                raise AsmError(no, f"数でも名前でもありません: {tok!r}")
            if tok not in symbols:
                raise AsmError(no, f"定義されていない名前です: {tok}")
            val = symbols[tok]
        total += sign * val
        pos, first = m.end(), False
    if first:
        raise AsmError(no, "値がありません")
    return total


def fit(value: int, bits: int, no: int) -> int:
    """bits ビットに収める。負の数は 2 の補数にする (-1 → 全部 1)。"""
    lo, hi = -(1 << (bits - 1)), (1 << bits) - 1
    if not lo <= value <= hi:
        raise AsmError(no, f"値 {value} は {bits} ビットに入りません ({lo}〜{hi})")
    return value & ((1 << bits) - 1)


def match(isa: Isa, line: Line) -> tuple[int, tuple[str, ...]]:
    """命令表から、名前と引数の形が合う行を探す。(命令の番号, 値の引数) を返す。"""
    regs = isa.registers()
    names = {m for m, _, _ in isa.table}
    if line.op not in names:
        raise AsmError(line.no, f"知らない命令です: {line.op}")
    for mnem, pattern, code in isa.table:
        if mnem != line.op or len(pattern) != len(line.args):
            continue
        values = []
        for want, got in zip(pattern, line.args):
            if want == IMM:
                if got.upper() in regs:
                    break
                values.append(got)
            elif got.upper() != want:
                break
        else:
            return code, tuple(values)
    forms = [f"{m} {','.join(p)}".strip() for m, p, _ in isa.table if m == line.op]
    raise AsmError(line.no, f"{line.op} の引数の形が合いません。使える形: {' / '.join(forms)}")


def assemble(source: str, isa: Isa) -> tuple[list[Word], dict[str, int]]:
    """2 回読む。1 回目でラベルの番地を決め、2 回目で語を作る。"""
    lines = [parse_line(i + 1, raw) for i, raw in enumerate(source.splitlines())]
    regs = isa.registers()

    symbols: dict[str, int] = {}
    addr = 0
    for ln in lines:
        if ln.label is not None:
            if ln.label.upper() in regs:
                raise AsmError(ln.no, f"レジスタの名前はラベルにできません: {ln.label}")
            if ln.label in symbols:
                raise AsmError(ln.no, f"ラベルが 2 回定義されています: {ln.label}")
            symbols[ln.label] = addr
        if ln.op is None:
            continue
        if ln.op == ".ORG":
            if len(ln.args) != 1:
                raise AsmError(ln.no, ".org には値を 1 つ書きます")
            new = evaluate(ln.args[0], symbols, ln.no)
            if new < addr:
                raise AsmError(ln.no, f".org {new} は今の番地 {addr} より前です")
            addr = new
        elif ln.op == ".EQU":
            if len(ln.args) != 2 or not NAME_RE.match(ln.args[0]):
                raise AsmError(ln.no, ".equ は 名前, 値 と書きます")
            if ln.args[0].upper() in regs:
                raise AsmError(ln.no, f"レジスタの名前は .equ の名前にできません: {ln.args[0]}")
            if ln.args[0] in symbols:
                raise AsmError(ln.no, f"名前が 2 回定義されています: {ln.args[0]}")
            symbols[ln.args[0]] = evaluate(ln.args[1], symbols, ln.no)
        elif ln.op == ".DB":
            if not ln.args:
                raise AsmError(ln.no, ".db には値を 1 つ以上書きます")
            addr += len(ln.args)
        else:
            match(isa, ln)          # 1 回目でも知らない命令はここで止める
            addr += isa.size

    words: list[Word] = []
    addr = 0
    for ln in lines:
        if ln.op is None or ln.op == ".EQU":
            continue
        if ln.op == ".ORG":
            addr = evaluate(ln.args[0], symbols, ln.no)
            continue
        if ln.op == ".DB":
            for a in ln.args:
                words.append(Word(addr, fit(evaluate(a, symbols, ln.no), 8, ln.no), ln))
                addr += 1
            continue
        code, values = match(isa, ln)
        imm = fit(evaluate(values[0], symbols, ln.no), isa.imm_bits, ln.no) if values else 0
        if isa.layout == "nibble":
            words.append(Word(addr, (code << 4) | imm, ln))
        else:
            words.append(Word(addr, code, ln))
            words.append(Word(addr + 1, imm, ln))
        addr += isa.size

    for w in words:
        if w.addr >= isa.mem_words:
            raise AsmError(w.line.no, f"番地 {w.addr} はメモリ ({isa.mem_words} 語) の外です")
    return words, symbols


def to_image(words: list[Word], isa: Isa) -> list[int]:
    image = [0] * isa.mem_words
    for w in words:
        image[w.addr] = w.value
    return image


def to_readmemh(words: list[Word], isa: Isa, title: str) -> str:
    """$readmemh の形。メモリの全部の語を 1 行ずつ書き、各行の頭の語に元の行を注釈で添える。"""
    head: dict[int, Word] = {}
    seen: set[int] = set()
    for w in words:
        if w.line.no not in seen:
            seen.add(w.line.no)
            head[w.addr] = w
    out = [f"// {title}"]
    for addr, value in enumerate(to_image(words, isa)):
        w = head.get(addr)
        note = f" // {addr:02X}: {w.line.text.strip()}" if w else ""
        out.append(f"{value:02X}{note}")
    return "\n".join(out) + "\n"


def listing(words: list[Word]) -> str:
    """番地・語・元の行の表。2 語の命令 (cpu8) は 1 行にまとめる。"""
    rows, i = [], 0
    while i < len(words):
        w = words[i]
        if w.line.op != ".DB" and i + 1 < len(words) and words[i + 1].line is w.line:
            rows.append(f"{w.addr:02X}  {w.value:02X} {words[i + 1].value:02X}  {w.line.text}")
            i += 2
        else:
            rows.append(f"{w.addr:02X}  {w.value:02X}     {w.line.text}")
            i += 1
    return "\n".join(rows) + "\n"


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="小さな CPU のアセンブラ (11-6)")
    ap.add_argument("source")
    ap.add_argument("--isa", choices=sorted(ISAS), required=True)
    ap.add_argument("-o", "--output", help="$readmemh の 16 進を書くファイル (無ければ画面)")
    ap.add_argument("--list", action="store_true", help="番地・語・元の行の表を画面に出す")
    args = ap.parse_args(argv)
    isa = ISAS[args.isa]
    try:
        with open(args.source, encoding="utf-8") as f:
            source = f.read()
        words, _ = assemble(source, isa)
    except AsmError as e:
        print(f"{args.source}:{e.line_no}: {e.message}", file=sys.stderr)
        return 1
    except OSError as e:
        print(f"{args.source}: 読めません: {e.strerror}", file=sys.stderr)
        return 1
    text = to_readmemh(words, isa, f"asm.py --isa {isa.name} {args.source}")
    if args.list:
        sys.stdout.write(listing(words))
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(text)
    elif not args.list:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
