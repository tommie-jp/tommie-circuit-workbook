#!/usr/bin/env python3
"""層 A': 本文の MicroPython (out/pico) を CPython + スタブで走らせ、cases/*.py の期待値と突き合わせる。
使い方: python3 -I tests/pico/upy/run.py [名前の一部 ...]
cases/<題>.py は PROGRAM・BUDGET_US・setup(S)・check(S, out, ok) を定義する。"""
import contextlib
import importlib.util
import io
import os
import sys
import traceback

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
OUT = os.path.join(ROOT, 'out', 'pico')
sys.path.insert(0, HERE)
import mpstub  # noqa: E402


def load_case(path):
    spec = importlib.util.spec_from_file_location('case', path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run_case(path):
    case = load_case(path)
    S = mpstub.install(mpstub.State(case.BUDGET_US))
    if hasattr(case, 'setup'):
        case.setup(S)
    src_path = os.path.join(OUT, case.PROGRAM)
    if not os.path.exists(src_path):
        return [f'プログラムが無い: {case.PROGRAM}']
    code = compile(open(src_path, encoding='utf8').read(), src_path, 'exec')
    buf = io.StringIO()
    fails = []
    try:
        with contextlib.redirect_stdout(buf):
            exec(code, {'__name__': '__main__'})
    except mpstub.StopSim:
        pass
    except Exception:
        return ['実行中に例外:\n' + traceback.format_exc()]

    def ok(cond, what):
        if not cond:
            fails.append(what)
    case.check(S, buf.getvalue(), ok)
    return fails


def main():
    names = sorted(f for f in os.listdir(os.path.join(HERE, 'cases')) if f.endswith('.py'))
    filt = sys.argv[1:]
    if filt:
        names = [n for n in names if any(x in n for x in filt)]
    bad = 0
    for n in names:
        fails = run_case(os.path.join(HERE, 'cases', n))
        if fails:
            bad += 1
            print(f'NG  {n}')
            for f in fails:
                print(f'  NG: {f}')
        else:
            print(f'ok  {n}')
    print(f'\n{bad} 件 NG' if bad else f'\n全 {len(names)} 件 ok')
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
