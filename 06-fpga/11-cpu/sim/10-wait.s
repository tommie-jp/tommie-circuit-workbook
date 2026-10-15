; wait.s  HLT で割り込みを待ち、起こされるたびに数を OUT に出す (11-10)
        JMP  main
        JMP  isr        ; 02: ベクタ
main:   LDI  0
        ST   ticks
        EI
idle:   HLT             ; 割り込みが来るまで止まる。RETI で次の命令から続く
        LD   ticks
        OUT
        JMP  idle

isr:    ST   save_a
        LD   ticks
        ADDI 1
        ST   ticks
        LD   save_a
        RETI

        .org 0xF0
ticks:  .db  0
save_a: .db  0
