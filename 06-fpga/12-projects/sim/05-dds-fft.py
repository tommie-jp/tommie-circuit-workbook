#!/usr/bin/env python3
"""tb_dds が書いた dds_samples.txt (DAC の値、27 MHz で 65 536 点) のスペクトルを見る。

    python3 fft.py [dds_samples.txt]

窓は掛けない (ftw = k × 65 536 にしてあるので、65 536 点にちょうど k 周期が入る)。
基本波・直流を除いた残りから SINAD と ENOB、いちばん高いスプリアスから SFDR を出し、
8 ビットの理想 (SINAD 49.9 dB) との差で合否を言う。
"""
import sys

import numpy as np

FS = 27e6
BITS = 8


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else "dds_samples.txt"
    x = np.loadtxt(path)
    n = len(x)
    spec = np.abs(np.fft.rfft(x - x.mean())) ** 2
    k0 = int(np.argmax(spec))
    p_sig = spec[k0]
    rest = spec.copy()
    rest[0] = 0.0
    rest[k0] = 0.0
    p_noise = rest.sum()
    sinad = 10 * np.log10(p_sig / p_noise)
    enob = (sinad - 1.76) / 6.02
    order = np.argsort(rest)[::-1]
    print(f"samples {n}, fundamental bin {k0} = {k0 * FS / n / 1e6:.6f} MHz")
    print(f"SINAD {sinad:.2f} dB (ideal {6.02 * BITS + 1.76:.2f} dB for {BITS} bit), ENOB {enob:.2f} bit")
    print("largest spurs (dBc):")
    for k in order[:5]:
        print(f"  {k * FS / n / 1e6:9.6f} MHz  {10 * np.log10(rest[k] / p_sig):7.2f} dBc")
    sfdr = 10 * np.log10(p_sig / rest[order[0]])
    print(f"SFDR {sfdr:.2f} dBc")
    ok = enob > BITS - 0.5 and sfdr > 50.0
    print("PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
