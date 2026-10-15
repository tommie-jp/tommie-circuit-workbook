; led.s  5-8 のプログラム A (LED の点き方を 9 通り出して頭に戻る)。TD4 の 12 命令だけで書く
start:  OUT 0b0011
        OUT 0b0110
        OUT 0b1100
        OUT 0b1000
        OUT 0b1000
        OUT 0b1100
        OUT 0b0110
        OUT 0b0011
        OUT 0b0001
        JMP start
