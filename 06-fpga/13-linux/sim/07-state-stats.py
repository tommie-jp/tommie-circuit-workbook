#!/usr/bin/env python3
"""13-7: 保存ファイル (.state) の中の 0 を数え、縮め方を比べる。

使い方: python3 07-state-stats.py <保存ファイル .state> [--compress] [--region 名前:始まり:長さ ...]
  --compress を付けると gzip -1/-6/-9・zstd -3/-19・xz -6 のコマンドで縮めて、大きさと時間を出す
  (zstd と xz はコマンドがあれば。元のファイルは書き換えない)
  --region はファイルの中の区間 (バイト) ごとに 0 でないバイトを数える。
  例 (mmRISC-2 の模型 67c16bf6): --region mem:340561:268435456 --region sd:268915313:67108864
"""
import shutil
import subprocess
import sys
import time

PAGE = 4096
MIB = 1 << 20


def page_stats(data):
    """0 のバイトの数、全部 0 のページの数、ページの数を返す。"""
    zero_bytes = data.count(0)
    zero_page = bytes(PAGE)
    pages = (len(data) + PAGE - 1) // PAGE
    zero_pages = sum(1 for i in range(0, len(data), PAGE) if data[i:i + PAGE] == zero_page[:len(data[i:i + PAGE])])
    return zero_bytes, zero_pages, pages


def per_mib(data):
    """1 MiB ごとの「0 でないバイト」の数の並び。"""
    return [MIB - data[i:i + MIB].count(0) - max(0, i + MIB - len(data)) for i in range(0, len(data), MIB)]


def timed(fn):
    t0 = time.perf_counter()
    out = fn()
    return out, time.perf_counter() - t0


def tool(cmd, data):
    return subprocess.run(cmd, input=data, stdout=subprocess.PIPE, check=True).stdout


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    with open(sys.argv[1], 'rb') as f:
        data = f.read()
    size = len(data)
    zero_bytes, zero_pages, pages = page_stats(data)
    print(f'size            {size} bytes ({size / MIB:.1f} MiB)')
    print(f'zero bytes      {zero_bytes} ({100 * zero_bytes / size:.2f} %)')
    print(f'non-zero bytes  {size - zero_bytes} ({(size - zero_bytes) / MIB:.1f} MiB)')
    print(f'4 KB pages      {pages}, all-zero {zero_pages} ({100 * zero_pages / pages:.2f} %), '
          f'used {pages - zero_pages} ({(pages - zero_pages) * PAGE / MIB:.1f} MiB)')
    used = per_mib(data)
    busy = [i for i, n in enumerate(used) if n > 0]
    print(f'1 MiB blocks    {len(used)}, with any non-zero byte {len(busy)}')
    print('non-zero bytes per 16 MiB: ' +
          ' '.join(f'{sum(used[i:i + 16]) / MIB:.2f}' for i in range(0, len(used), 16)))
    covered = 0
    for i, arg in enumerate(sys.argv):
        if arg != '--region':
            continue
        name, start, length = sys.argv[i + 1].split(':')
        part = data[int(start):int(start) + int(length)]
        nonzero = len(part) - part.count(0)
        covered += len(part)
        print(f'region {name:5s} {len(part)} bytes at {int(start)}, non-zero {nonzero} ({100 * nonzero / len(part):.2f} %)')
    if covered:
        print(f'outside regions {size - covered} bytes')
    if '--compress' not in sys.argv:
        return
    rows = [(f'gzip -{lv}', (lambda lv=lv: tool(['gzip', f'-{lv}', '-c'], data)),
             lambda z: tool(['gzip', '-d', '-c'], z)) for lv in (1, 6, 9)]
    if shutil.which('zstd'):
        for lv in (3, 19):
            rows.append((f'zstd -{lv}', (lambda lv=lv: tool(['zstd', f'-{lv}', '-c', '-q'], data)),
                         lambda z: tool(['zstd', '-d', '-c', '-q'], z)))
    if shutil.which('xz'):
        rows.append(('xz -6', lambda: tool(['xz', '-6', '-c'], data), lambda z: tool(['xz', '-d', '-c'], z)))
    for name, comp, decomp in rows:
        packed, t_c = timed(comp)
        back, t_d = timed(lambda: decomp(packed))
        assert back == data, name
        print(f'{name:9s} {len(packed):10d} bytes ({len(packed) / MIB:5.2f} MiB, 1/{size / len(packed):.1f})  '
              f'compress {t_c:5.1f} s  decompress {t_d:4.2f} s')


if __name__ == '__main__':
    main()
