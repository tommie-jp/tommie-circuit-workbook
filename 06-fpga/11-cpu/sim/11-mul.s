; mul.s  a × b をシフトと足し算で求めて OUT に出す (11-11)。a は 0xF0、b は 0xF1 番地 (既定 13 × 11 → 143)
;        b を右へずらして出た桁が 1 なら p に a を足し、a を左へずらす。b が 0 になったら終わり
start:  LDI  0
        ST   p
loop:   LD   b
        JZ   done
        SHR             ; 出た桁は桁上げに入る
        ST   b
        JNC  skip
        LD   p
        ADD  a
        ST   p          ; p ← p + a
skip:   LD   a
        SHL
        ST   a          ; a ← a × 2
        JMP  loop
done:   LD   p
        OUT
        HLT

        .org 0xF0
a:      .db  13
b:      .db  11
p:      .db  0
