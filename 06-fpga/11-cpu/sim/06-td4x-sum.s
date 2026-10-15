; sum.s  5+4+3+2+1 を A に足して OUT に出す (11-5 の 05-td4x-sum.hex と同じ機械語になる)
        MOV A, 0
        MOV B, 5
loop:   ADD A, B        ; A ← A + B
        ADD B, -1       ; B ← B - 1 (15 を足すのと同じ)。0 になればゼロフラグ
        JZ  done
        JMP loop
done:   OUT A
halt:   JMP halt
