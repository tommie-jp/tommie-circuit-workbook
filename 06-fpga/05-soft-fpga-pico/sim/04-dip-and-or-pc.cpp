// 1-1 の gates.v を Pico 2 で回す。a・b は DIP スイッチ、出力は LED
#include "pico/stdlib.h"
#include "Vgates.h"

#define PIN_A    17   // SW1 (ON で L)
#define PIN_B    16   // SW2 (ON で L)
#define PIN_AND  14   // D1
#define PIN_OR   15   // D2
#define PIN_NOT  25   // Pico 2 の基板の上の LED

static void setpin(unsigned p,int v){ if(v) g_gpio|=1u<<p; else g_gpio&=~(1u<<p); }
static int getpin(unsigned p){ return (g_gpio>>p)&1; }
int main() {
    const uint in_pins[]  = {PIN_A, PIN_B};
    const uint out_pins[] = {PIN_AND, PIN_OR, PIN_NOT};
    for (uint p : in_pins) {
        gpio_init(p);
        gpio_set_dir(p, GPIO_IN);
        gpio_pull_up(p);               // 内蔵プルアップ。スイッチは GND へ落とす
    }
    for (uint p : out_pins) {
        gpio_init(p);
        gpio_set_dir(p, GPIO_OUT);
    }

    VerilatedContext ctx;
    Vgates top{&ctx};

    const int tbl[4][2]={{1,1},{1,0},{0,1},{0,0}};
    for (int loop=0; loop<4; loop++) {
        setpin(17,tbl[loop][0]); setpin(16,tbl[loop][1]);
        top.a = !gpio_get(PIN_A);      // 1. 読む (ON = L を 1 に反転)
        top.b = !gpio_get(PIN_B);
        top.eval();                    // 2. eval (クロックは無い)
        gpio_put(PIN_AND, top.y_and);  // 3. 書く
        gpio_put(PIN_OR,  top.y_or);
        gpio_put(PIN_NOT, top.y_not);
        printf("GP17=%d GP16=%d (a=%d b=%d) -> GP14(AND)=%d GP15(OR)=%d GP25(NOT)=%d\n",getpin(17),getpin(16),!getpin(17),!getpin(16),getpin(14),getpin(15),getpin(25));
    }
}
