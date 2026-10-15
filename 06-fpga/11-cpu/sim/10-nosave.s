; nosave.s  main.s から A の退避と戻しを抜いた物 (11-10)。割り込みが来ると和が狂う
        JMP  main       ; 00: リセットで来る
        JMP  isr        ; 02: 割り込みで来る (ベクタ)
main:   LDI  0
        ST   ticks
        LDI  3
        ST   rep
        EI              ; ここから割り込みを受ける
again:  LDI  0
        ST   sum
        LDI  10
        ST   n
loop:   LD   sum
        ADD  n
        ST   sum        ; sum ← sum + n
        LD   n
        SUBI 1
        ST   n          ; n ← n - 1。ゼロフラグが立てば終わり
        JNZ  loop
        LD   sum
        OUT             ; 55
        LD   rep
        SUBI 1
        ST   rep
        JNZ  again
        DI
        HLT

isr:    LD   ticks      ; A を退避しないで使う
        ADDI 1
        ST   ticks      ; ticks ← ticks + 1
        RETI

        .org 0xF0
sum:    .db  0
n:      .db  0
rep:    .db  0
ticks:  .db  0
save_a: .db  0
