; cmp.s  IN が LIMIT 以上なら OUT に 1、小さければ 0 (11-5 の 05-td4x-cmp.hex と同じ)
        .equ LIMIT, 5
start:  IN  A
        MOV B, LIMIT
        SUB A, B        ; 借りが無い (A >= LIMIT) なら桁上げが立つ
        JNC less
        OUT 1
        JMP start
less:   OUT 0
        JMP start
