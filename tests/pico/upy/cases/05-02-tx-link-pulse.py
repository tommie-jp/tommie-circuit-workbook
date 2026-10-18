PROGRAM = '05-etc/05-ethernet-10base-t/02-tx-link-pulse-1.py'
BUDGET_US = 2_300_000


def unmanchester(w):
    b = 0
    for i in range(8):
        nib = (w >> (4 * i)) & 0xF
        if nib == 0x9:
            b |= 1 << i
        elif nib != 0x6:
            return -1
    return b


def crc32_ref(data):
    crc = 0xFFFFFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ (0xEDB88320 if crc & 1 else 0)
    return crc ^ 0xFFFFFFFF


def check(S, out, ok):
    ok(120_000_000 in S.freq_calls, f'machine.freq は 120 MHz: {S.freq_calls}')
    ok(len(S.sm) == 1 and S.sm[0]['freq'] == 20_000_000, '状態機械は 20 MHz')
    ok(S.sm[0]['prog'] == 'ser_10base_t' and S.sm[0]['kw'].get('out_base') is not None and S.sm[0]['kw']['out_base'].id == 16, 'out_base は GP16')
    ok(S.sm[0]['active'] == 1, '状態機械を有効にする')
    puts = S.sm[0]['puts']
    frames, last_nlp, nlps, i = [], None, 0, 0
    while i < len(puts):
        t, w = puts[i]
        if w == 0xA:
            if nlps > 0:
                ok(16_000 <= t - last_nlp <= 16_200, f'NLP の間隔 16 ms: {t - last_nlp} us')
            last_nlp, nlps = t, nlps + 1
            i += 1
            continue
        words = [x for _, x in puts[i:i + 72]]
        f = bytes(max(unmanchester(x), 0) for x in words)
        ok(all(unmanchester(x) >= 0 for x in words) and len(f) == 72, 'フレームは 72 語')
        ok(i + 72 < len(puts) and puts[i + 72][1] == 0xAAA, 'フレームの後に TP_IDL 0xAAA')
        ok(f[:8] == b'\x55' * 7 + b'\xd5', 'プリアンブル 7 + SFD 0xD5')
        ok(f[8:14] == b'\xff' * 6 and f[20:22] == b'\x08\x00', '宛先 MAC はブロードキャスト、EtherType 0x0800')
        s = sum((f[22 + k] << 8) | f[23 + k] for k in range(0, 20, 2))
        while s >> 16:
            s = (s & 0xFFFF) + (s >> 16)
        ok(s == 0xFFFF, f'IP ヘッダの検査和が合う: {s:#06x}')
        ok(f[31] == 17 and f[38:42] == b'\xff' * 4 and f[44:48] == b'\x04\xd2\x00\x1a', 'UDP、宛先 255.255.255.255:1234、長さ 26')
        got = int.from_bytes(f[68:72], 'little')
        ok(crc32_ref(f[8:68]) == got, 'FCS が CRC-32 と一致')
        ok(f[50:66] == b'P2 10BASE-T 0000', f'payload: {f[50:67]!r}')
        frames.append(t)
        i += 73
        last_nlp, nlps = puts[i - 1][0], 0
    ok(len(frames) == 2, f'2.3 s にフレーム 2 つ: {len(frames)}')
    ok(len(frames) == 2 and 1_000_000 <= frames[1] - frames[0] <= 1_000_200, 'フレームの間隔 1 s')
    ok(len(puts) > 100, f'NLP が 16 ms ごとに積まれている: {len(puts)} 語')
    ok(out.startswith('frame 1\n'), f'frame 1 を印字: {out[:20]!r}')
