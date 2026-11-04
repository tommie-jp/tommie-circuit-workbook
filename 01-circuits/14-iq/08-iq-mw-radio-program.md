---
book: circuits
chapter: 14
id: 14-8
title: IQ 中波ラジオのプログラム — PIO の LO と DMA の ADC で AM を復調する
tier: 300
source: 自作
board: BB
era: 今
---

# 14-8 IQ 中波ラジオのプログラム — PIO の LO と DMA の ADC で AM を復調する

14-7 で組んだ IQ 中波ラジオ (バーアンテナ・74HC4052 の Tayloe 検波器・MCP6002 の増幅・LM386) の基板を**そのまま使い**、
Pico 2 のプログラムを書く。プログラムは PIO で LO (S0・S1) を出し、DMA で ADC から I と Q を読み、
計算で AM を復調して PWM で音にする。選局は局ごとに sys クロックを選び直して LO を局に寄せ、残ったずれは計算で消す。

- 回路図と実体配線図は 14-7 の図1〜図6 と同じなので載せない (前の題と同じ回路の再掲は、前の題を指して載せない)
- AD3 の設定と計器の画面 (Logic で LO、Scope で I と Q) も 14-7 と同じなので載せない (Spectrum で I の中身を見るのは 14-10)。この題で見るのは、シリアルの表示と耳で聞く音

**LO を局に寄せる — sys クロックを局ごとに選び直す。**

sys を 150 MHz に固定して整数 M だけで割ると、LO は 150 MHz ÷ 4M の飛び飛びの値しか取れない。
1602 kHz の近くでは M = 23 で 1630.4 kHz、M = 24 で 1562.5 kHz で、間が 68 kHz も空き、局から 30 kHz 近くずれる。

そこで**局ごとに sys クロックそのものを選び直す**。RP2350 の sys の PLL は

f<sub>sys</sub> = 12 MHz × FBDIV ÷ PD1 ÷ PD2 (VCO = 12 MHz × FBDIV は 750〜1600 MHz、PD1・PD2 は 1〜7)

で、sys を 100〜150 MHz に収める組 (FBDIV・PD1・PD2) は 157 通りある。そのどれかと整数 M の組で、LO を局の近くに置ける。
プログラムは、選局のたびにこの組を全部試し、**局から 1 kHz 以上離れた中で一番近い LO** を選ぶ (1 kHz 以上離す理由は次の節)。
531〜1602 kHz の 120 局のすべてで、残るずれ Δf は **1.0〜2.9 kHz** に収まる (計算値。一番ずれるのは 1503 kHz の 2.88 kHz)。

| 局 | sys | PLL (VCO ÷ PD1 ÷ PD2) | M | LO | Δf = 局 − LO |
| --- | --- | --- | --- | --- | --- |
| 531 kHz | 127.200 MHz | 1272 MHz ÷ 5 ÷ 2 | 60 | 530.000 kHz | +1.000 kHz |
| **594 kHz** | **142.800 MHz** | **1428 MHz ÷ 5 ÷ 2** | **60** | **595.000 kHz** | **−1.000 kHz** |
| 693 kHz | 102.400 MHz | 1536 MHz ÷ 5 ÷ 3 | 37 | 691.892 kHz | +1.108 kHz |
| 954 kHz | 129.600 MHz | 1296 MHz ÷ 5 ÷ 2 | 34 | 952.941 kHz | +1.059 kHz |
| 1134 kHz | 126.857 MHz | 888 MHz ÷ 7 ÷ 1 | 28 | 1132.653 kHz | +1.347 kHz |
| 1503 kHz | 102.400 MHz | 1536 MHz ÷ 5 ÷ 3 | 17 | 1505.882 kHz | −2.882 kHz |
| 1602 kHz | 108.857 MHz | 1524 MHz ÷ 7 ÷ 2 | 17 | 1600.840 kHz | +1.160 kHz |

- 表は計算値。14-7 の図と数は **594 kHz** (表の太字) で書く
- **ADC は sys を変えても狂わない**。ADC のクロックは USB 用の PLL (48 MHz) から来るので、sys の選び直しの影響を受けない。
  USB のシリアルも同じ 48 MHz で動くので、選局しても切れない
- **PWM は sys で動く**ので、選び直すたびに分周 (wrap の値) を計算し直す。プログラムの `tune()` がする
- 残った Δf は計算で消す。I + jQ を複素数と見て、1 標本ごとに e<sup>+j2πΔf t</sup> を掛けて回し戻すと、局がちょうど 0 Hz に来る (数値の発振器)

**LO を局から 1 kHz 以上離す理由。**

ずれ Δf が 0 なら一番よさそうに見えるが、わざと 1 kHz 以上離す。
I と Q には、増幅のオフセット (MCP6002 で最大 ±4.5 mV。1 段目で 11 倍の 約 50 mV になるが、C10 (14-7 の図2) で切れて 2 段目に渡るのは 4.5 mV ほど) と、74HC4052 の電荷の注入による**直流**が乗る。
プログラムは最初に直流を引く (3.9 Hz の高域通過) が、局の搬送波が 0 Hz にいると、**搬送波まで直流と一緒に消える**。
AM の包絡線は搬送波が基準なので、消えると音が歪む。局を 1 kHz 以上離しておけば、直流を引いたあとで回し戻せる。

**題の芯の実験 — I だけで聞くと、なぜ足りないか。**

プログラムには切り替えを 1 つ置く (USB のシリアルに `i` か `e` を送る)。

- **`i` = I だけ** (掛け算 1 つの直接変換と同じ): 回し戻したあとの I = m(t) · cos(2πδ t + φ)。δ は計算で消しきれない残りのずれで、
  Pico 2 と放送局の水晶の差から来る (数十 ppm の目安で、600 kHz なら数 Hz〜数十 Hz)。
  **音が δ の速さで大きくなったり消えたりする**。`o` で回し戻しを切ると δ は Δf (1〜2.9 kHz) になり、音声に唸りが重なって聞き取れない
- **`e` = √(I² + Q²)** (この題の既定): cos と sin の 2 乗の和は 1 なので、δ も φ も消え、AM の包絡線 m(t) がそのまま出る。
  回し戻しを切っても包絡線は変わらない (隣の局が低域通過を抜けてくるだけ)

9-12 と 14-2 で見た「掛け算 1 つでは足りない」が、ここで耳で分かる。

## プログラム

プログラムは **C/C++ (Pico SDK) が本体**、MicroPython は選局と I・Q の大きさの表示だけにした。
**MicroPython では音声の計算が間に合わない**: 25 kS/s × 2 本の標本ごとに、回し戻し (sin・cos)・4 次の低域通過 2 本・平方根をするのは、
MicroPython の 1 行に数 µs〜十数 µs かかる速さでは 40 µs に収まらない。ADC を 500 kS/s で DMA に読ませる設定も、MicroPython の標準の `machine.ADC` からはできない。

**C/C++ (Pico SDK)**。`iqradio.c`。

```c
// iqradio.c — IQ 中波ラジオ (Pico 2)
#include <stdio.h>
#include <math.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include "hardware/clocks.h"
#include "hardware/dma.h"
#include "hardware/pio.h"
#include "hardware/pwm.h"

#define PIN_S0     2              // GP2 = S0、GP3 = S1
#define PIN_ENC_A  10
#define PIN_ENC_B  11
#define PIN_PWM    15
#define FS         25000.0f       // I・Q それぞれの標本化 (Hz)
#define AVG        10             // 1 本あたり 10 個を平均 (250 kS/s → 25 kS/s)
#define OUT_N      50             // 1 ブロックで出す標本 (2 ms)
#define BLOCK      (2 * AVG * OUT_N)  // ADC の生の標本 (I と Q が交互)
#define PWM_HZ     100000.0       // PWM の搬送波
#define MIN_OFS    1000.0         // LO を局から 1 kHz 以上離す
#define F_FIRST    531000
#define F_STEP     9000
#define N_CH       120            // 531〜1602 kHz

// set pins, 0 → 1 → 3 → 2 (S1 S0 = 00 → 01 → 11 → 10)。.pio で書いた 4 行を手で組んだもの
static const uint16_t lo_insn[] = {0xe000, 0xe001, 0xe003, 0xe002};
static const pio_program_t lo_prog = {.instructions = lo_insn, .length = 4, .origin = -1};

typedef struct { uint32_t vco; uint pd1, pd2, m; double sys, lo; } tune_t;
typedef struct { float b0, b1, b2, a1, a2, z1, z2; } biquad_t;

static uint16_t buf[2][BLOCK];
static uint dma_ch[2], sm, slice;
static volatile uint pwm_wrap = 1000;
static volatile float ring[256];
static volatile uint8_t wr, rd;   // 8 bit の添字なので 256 で一周する
static float dphi;                // 回し戻しの 1 標本あたりの角
static int mode = 'e';            // 'e' = √(I² + Q²)、'i' = I だけ
static bool fix_ofs = true;       // 'o' で Δf の回し戻しを切る

// 局 f に一番近い LO (1 kHz 以上離す) を作る PLL と M を探す
static tune_t find_tune(double f) {
    tune_t best = {0};
    double best_e = 1e9;
    for (uint fb = 63; fb <= 133; fb++) {                // VCO = 12 MHz × fb = 756〜1596 MHz
        for (uint p1 = 1; p1 <= 7; p1++) {
            for (uint p2 = 1; p2 <= p1; p2++) {
                double sys = 12e6 * fb / (p1 * p2);
                if (sys < 100e6 || sys > 150e6) continue;
                uint m0 = (uint)(sys / (4.0 * f));
                for (uint m = m0 - 1; m <= m0 + 2; m++) {
                    double lo = sys / (4.0 * m), e = fabs(lo - f);
                    if (e < MIN_OFS) continue;           // 局を 0 Hz に置かない
                    if (e < best_e - 1e-6 || (e < best_e + 1e-6 && sys > best.sys)) {
                        best = (tune_t){12000000u * fb, p1, p2, m, sys, lo};
                        best_e = e;
                    }
                }
            }
        }
    }
    return best;
}

static void tune(double f) {
    tune_t t = find_tune(f);
    set_sys_clock_pll(t.vco, t.pd1, t.pd2);              // ADC と USB は 48 MHz の PLL なので変わらない
    pio_sm_set_clkdiv(pio0, sm, (float)t.m);             // 整数で割る (小数部 0)
    pio_sm_clkdiv_restart(pio0, sm);
    pwm_wrap = (uint)(t.sys / PWM_HZ) - 1;               // PWM は sys で動くので直す
    pwm_set_wrap(slice, pwm_wrap);
    double df = f - t.lo;                                // Δf = 局 − LO
    dphi = (float)(2.0 * M_PI * df / FS);
    printf("%.0f kHz  sys %.3f MHz  LO %.3f kHz  M %u  df %+.0f Hz\n",
           f / 1e3, t.sys / 1e6, t.lo / 1e3, t.m, df);
}

static biquad_t lowpass(float fc, float q) {             // 2 次の低域通過 (双一次変換)
    float w = 2.0f * (float)M_PI * fc / FS, al = sinf(w) / (2.0f * q), c = cosf(w), a0 = 1.0f + al;
    return (biquad_t){(1 - c) / 2 / a0, (1 - c) / a0, (1 - c) / 2 / a0, -2 * c / a0, (1 - al) / a0, 0, 0};
}

static float run(biquad_t *b, float x) {
    float y = b->b0 * x + b->z1;
    b->z1 = b->b1 * x - b->a1 * y + b->z2;
    b->z2 = b->b2 * x - b->a2 * y;
    return y;
}

static bool pwm_tick(repeating_timer_t *t) {             // 25 kHz で 1 標本ずつ PWM へ
    float a = (rd != wr) ? ring[rd++] : 0.0f;
    float lv = 0.5f * (1.0f + 0.8f * a);
    lv = lv < 0.0f ? 0.0f : (lv > 1.0f ? 1.0f : lv);
    pwm_set_gpio_level(PIN_PWM, (uint16_t)(lv * pwm_wrap));
    return true;
}

static void setup(void) {
    uint off = pio_add_program(pio0, &lo_prog);          // LO: PIO の 4 状態
    sm = pio_claim_unused_sm(pio0, true);
    pio_sm_config c = pio_get_default_sm_config();
    sm_config_set_wrap(&c, off, off + 3);
    sm_config_set_set_pins(&c, PIN_S0, 2);
    pio_gpio_init(pio0, PIN_S0);
    pio_gpio_init(pio0, PIN_S0 + 1);
    pio_sm_set_consecutive_pindirs(pio0, sm, PIN_S0, 2, true);
    pio_sm_init(pio0, sm, off, &c);
    pio_sm_set_enabled(pio0, sm, true);

    gpio_set_function(PIN_PWM, GPIO_FUNC_PWM);           // 音声の PWM
    slice = pwm_gpio_to_slice_num(PIN_PWM);
    pwm_set_enabled(slice, true);

    gpio_init(PIN_ENC_A);                                // エンコーダ (内蔵のプルアップ)
    gpio_pull_up(PIN_ENC_A);
    gpio_init(PIN_ENC_B);
    gpio_pull_up(PIN_ENC_B);

    adc_init();                                          // ADC0 = I、ADC1 = Q を交互に 500 kS/s
    adc_gpio_init(26);
    adc_gpio_init(27);
    adc_set_round_robin(0x3);
    adc_select_input(0);
    adc_fifo_setup(true, true, 1, false, false);
    adc_set_clkdiv(0);                                   // 48 MHz ÷ 96 = 500 kS/s
    dma_ch[0] = dma_claim_unused_channel(true);
    dma_ch[1] = dma_claim_unused_channel(true);
    for (int k = 0; k < 2; k++) {                        // 2 本の DMA が交互に buf[0]・buf[1] を埋める
        dma_channel_config d = dma_channel_get_default_config(dma_ch[k]);
        channel_config_set_transfer_data_size(&d, DMA_SIZE_16);
        channel_config_set_read_increment(&d, false);
        channel_config_set_write_increment(&d, true);
        channel_config_set_dreq(&d, DREQ_ADC);
        channel_config_set_chain_to(&d, dma_ch[k ^ 1]);
        dma_channel_configure(dma_ch[k], &d, buf[k], &adc_hw->fifo, BLOCK, false);
    }
}

int main(void) {
    stdio_init_all();
    setup();
    int ch = (594000 - F_FIRST) / F_STEP;                // 最初は 594 kHz
    tune(F_FIRST + ch * F_STEP);
    static repeating_timer_t timer;
    add_repeating_timer_us(-40, pwm_tick, NULL, &timer); // 25 kHz
    dma_channel_start(dma_ch[0]);
    adc_run(true);

    biquad_t lp[4] = {lowpass(4000, 0.5412f), lowpass(4000, 1.3066f),   // 4 次のバターワース
                      lowpass(4000, 0.5412f), lowpass(4000, 1.3066f)};
    float dci = 2048, dcq = 2048, qprev = 2048, ph = 0, car = 1;
    int k = 0, last_a = 1;
    while (true) {
        dma_channel_wait_for_finish_blocking(dma_ch[k]);
        const uint16_t *b = buf[k];
        for (int n = 0; n < OUT_N; n++) {
            float si = 0, sq = 0;
            for (int j = 0; j < AVG; j++) {
                si += b[2 * (n * AVG + j)];              // 偶数が ADC0 (I)
                sq += b[2 * (n * AVG + j) + 1];          // 奇数が ADC1 (Q)。I より 2 µs 遅い
            }
            si /= AVG;
            sq /= AVG;
            float qa = sq - 0.05f * (sq - qprev);        // Q を 2 µs (40 µs の 1/20) 戻す
            qprev = sq;
            dci += (si - dci) * (1.0f / 1024);           // 直流 (1.65 V とオフセット) を引く。角 3.9 Hz
            dcq += (qa - dcq) * (1.0f / 1024);
            float i = si - dci, q = qa - dcq;
            if (fix_ofs) {                               // I + jQ に e^(+j2πΔf t) を掛け、局を 0 Hz へ
                float c = cosf(ph), s = sinf(ph), i2 = i * c - q * s;
                q = i * s + q * c;
                i = i2;
                ph += dphi;
                if (ph > (float)M_PI) ph -= 2.0f * (float)M_PI;
                if (ph < -(float)M_PI) ph += 2.0f * (float)M_PI;
            }
            i = run(&lp[1], run(&lp[0], i));             // ±4 kHz だけ通す (隣の局 ±9 kHz を落とす)
            q = run(&lp[3], run(&lp[2], q));
            float env = sqrtf(i * i + q * q);
            car += (env - car) * (1.0f / 2048);          // 搬送波の大きさ (82 ms の平均)。これで割るのが AGC
            float a = (mode == 'e') ? (env - car) / car : i / car;
            ring[wr++] = a;
        }
        dma_channel_set_write_addr(dma_ch[k], buf[k], false);  // 次の番の書き先を戻す
        k ^= 1;

        int a = gpio_get(PIN_ENC_A);                     // A の立ち下がりで B を見る
        if (last_a && !a) {
            ch += gpio_get(PIN_ENC_B) ? 1 : -1;
            ch = ch < 0 ? 0 : (ch >= N_CH ? N_CH - 1 : ch);
            tune(F_FIRST + ch * F_STEP);
        }
        last_a = a;
        int key = getchar_timeout_us(0);                 // USB のシリアルから i / e / o
        if (key == 'i' || key == 'e') printf("mode %c\n", mode = key);
        if (key == 'o') printf("offset fix %s\n", (fix_ofs = !fix_ofs) ? "on" : "off");
    }
}
```

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるもの) と `CMakeLists.txt` を置く。ビルドと書き込みは 9-16 と同じ
(`cmake -B build -DPICO_BOARD=pico2`、`cmake --build build`、BOOTSEL を押しながら USB をつなぎ `build/iqradio.uf2` をコピー)。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(iqradio C CXX ASM)
pico_sdk_init()
add_executable(iqradio iqradio.c)
target_link_libraries(iqradio pico_stdlib hardware_adc hardware_clocks hardware_dma hardware_pio hardware_pwm)
pico_enable_stdio_usb(iqradio 1)
pico_add_extra_outputs(iqradio)
```

- **ADC の交互読みと 2 µs のずれ**: ADC は 1 つしかなく、ADC0 と ADC1 を 1 回ずつ交互に読む。500 kS/s なら I と Q は **2 µs** ずれて取られる。
  音声の帯の端 7.4 kHz (4.5 + 2.9 kHz) で 360° × 7.4 kHz × 2 µs ≈ **5.3°** の位相の誤差になる (計算値)。
  ずれの時間は 2 µs で一定なので、プログラムは Q を 1 標本 (40 µs) の 1/20 だけ前の値の側へ寄せて戻す (`qa` の行)。
  遅い速さ (たとえば 1 本 48 kS/s ずつ) で交互に読むと、ずれは 10 µs、7.4 kHz で約 27° になる。速く回して平均するのはこのため
- **10 個の平均**は、25 kS/s に落とす前の簡単な低域通過も兼ねる (25 kHz の倍数に零点)。前の Tayloe の 9 kHz の角と合わせて、折り返しを抑える
- この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが通る (警告なし) ことを確かめた。**実機では動かしていない** (未確認)。
  確かめた数は PLL と M の表 (Python で 120 局を計算) まで

**MicroPython** (選局と I・Q の大きさの表示だけ)。Pico 2 用の MicroPython (`RPI_PICO2`) を入れ、Thonny で実行する。

```python
import machine, rp2, time
from machine import Pin, ADC

@rp2.asm_pio(set_init=(rp2.PIO.OUT_LOW, rp2.PIO.OUT_LOW))
def lo():                     # S1 S0 = 00 → 01 → 11 → 10
    set(pins, 0)
    set(pins, 1)
    set(pins, 3)
    set(pins, 2)

MIN_OFS = 1000                # LO を局から 1 kHz 以上離す
SM0_CLKDIV = 0x50200000 + 0x0C8   # PIO0 の SM0 の分周のレジスタ

def find_tune(f):
    best = None
    for fb in range(63, 134):                    # VCO = 12 MHz × fb
        for p1 in range(1, 8):
            for p2 in range(1, p1 + 1):
                if (12_000_000 * fb) % (p1 * p2 * 1000):
                    continue                     # machine.freq() は kHz の整数だけ
                sys_hz = 12_000_000 * fb // (p1 * p2)
                if not 100_000_000 <= sys_hz <= 150_000_000:
                    continue
                m0 = sys_hz // (4 * f)
                for m in range(m0 - 1, m0 + 3):
                    lo_hz = sys_hz / (4 * m)
                    e = abs(lo_hz - f)
                    if e >= MIN_OFS and (best is None or e < best[0]):
                        best = (e, sys_hz, m, lo_hz)
    return best

def tune(f):
    e, sys_hz, m, lo_hz = find_tune(f)
    machine.freq(sys_hz)
    sm = rp2.StateMachine(0, lo, freq=sys_hz // m, set_base=Pin(2))
    machine.mem32[SM0_CLKDIV] = m << 16          # 分周を整数 M にそろえる (小数部 0)
    sm.active(1)
    print("%d kHz  sys %.3f MHz  LO %.3f kHz  df %+d Hz" % (f // 1000, sys_hz / 1e6, lo_hz / 1e3, f - lo_hz))

adc_i, adc_q = ADC(26), ADC(27)
def levels(n=2000):                              # I と Q の交流分の rms (V)
    xi, xq = [], []
    for _ in range(n):
        xi.append(adc_i.read_u16())
        xq.append(adc_q.read_u16())              # I の 10〜20 µs 後 (目安)
    def rms(x):
        m = sum(x) / len(x)
        return (sum((v - m) ** 2 for v in x) / len(x)) ** 0.5 * 3.3 / 65535
    return rms(xi), rms(xq)

ch = (594_000 - 531_000) // 9_000
tune(531_000 + ch * 9_000)
while True:
    i, q = levels()
    print("I %.3f V  Q %.3f V" % (i, q))
    time.sleep(0.5)
```

- `machine.freq()` は sys を kHz の整数でしか受けないので、使える PLL の組が 157 通りから 100 通りに減る。
  そのぶん LO のずれは大きくなり、120 局で最大 **5.4 kHz** になる (計算値)。音を出さないので、ずれは表示に出るだけ
- `rp2.StateMachine` の `freq=` は分周を小数で決めることがあるので、作ったあとに分周のレジスタ (SM0_CLKDIV、上位 16 bit が整数部) へ M を直に書く
- I と Q を Python の行で 1 回ずつ読むので、2 本の間は 10〜20 µs ずれる (目安。測っていない)。大きさ (rms) を見るだけなら影響しない。
  位相を見るなら C/C++ の 2 µs が要る。**MicroPython は実行していない** (未確認)

**PC のサウンドカードで聞く手もある。** ステレオのライン入力がある PC なら、14-7 の図5 の I と Q (直流を 1 µF で切って) を左と右に入れ、
SDR のソフト (HDSDR など) で聞ける。昔の SoftRock の形だ。今の PC はマイク (モノラル) の入力しか無いことが多いので、この題は Pico 2 で閉じた。
RTL-SDR などの SDR の受信機が PC に送ってくるのも、この I と Q の標本の列だ (14-6)。

## 見るべき値

計算値。音の聞こえ方は目安。

| 確かめること | 期待する値 |
| --- | --- |
| 594 kHz を選んだときのシリアルの表示 | `594 kHz  sys 142.800 MHz  LO 595.000 kHz  M 60  df -1000 Hz` |
| 120 局の LO のずれ Δf | 1.0〜2.9 kHz (C/C++。最大は 1503 kHz の 2.88 kHz)。MicroPython は最大 5.4 kHz |
| I と Q の 2 µs のずれ | 7.4 kHz で 5.3°。プログラムで戻す |
| `i` (I だけ) で聞く | 音が数 Hz〜数十 Hz で大きくなったり消えたりする (残りのずれ δ。目安) |
| `e` (√(I² + Q²)) で聞く | 音が途切れない |
| `o` で回し戻しを切って `i` で聞く | Δf (1〜2.9 kHz) の唸りが重なる |

## プログラムでの確かめ

本文のプログラムを PC で動かし、本文の表と同じ量を突き合わせた (`npm run pico:test`・`npm run pico`)。**実機では動かしていない。**

| 見た物 | 結果 | 道具 |
| --- | --- | --- |
| PIO の LO | set pins の 4 命令 (0xe000・0xe001・0xe003・0xe002)。S1 S0 は 00 → 01 → 11 → 10 を 4 サイクルで 1 周 | C: Pico SDK のモック・rp2040-pio-emulator |
| 同調 | 594 kHz のとき sys が 100〜150 MHz、LO は局から 1 kHz 以上 1.5 kHz 未満離れる。PIO の分周は整数 | C: Pico SDK のモック・MicroPython: `machine` のスタブ |

見ていない物: PLL の追従・音声・エンコーダ・DMA の取りこぼし。PIO のサイクル数は 1 状態機械の模型で、FIFO・割り込みは見ていない

- 次の数は Python の算術で確かめた: PLL の組は sys を 100〜150 MHz に収めて 157 通り (FBDIV 63〜133、PD1・PD2 1〜7)。
  531〜1602 kHz の 120 局の Δf は 1.0〜2.88 kHz で最大は 1503 kHz。表の 7 局の LO と Δf も一致 (PLL の組は同じ LO になる別の組でもよい)。
  sys 150 MHz 固定の M = 23・24 は 1630.4・1562.5 kHz。7.4 kHz で 2 µs は 5.3°

## 出典

自作。回路は 14-7 と同じ。
Pico 2 のピンは [Raspberry Pi Pico 2 データシート](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf)、
RP2350 の PLL の式と範囲 (VCO 750〜1600 MHz、PD1・PD2 1〜7)・PIO の命令と分周・ADC の 500 kS/s と交互読みは
[RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) による。
SDK の関数は [Raspberry Pi Pico SDK のドキュメント](https://www.raspberrypi.com/documentation/pico-sdk/)、MicroPython の `rp2.StateMachine` と
`machine.freq()` は MicroPython の rp2 のドキュメントによる。PLL と M の表は計算値。
