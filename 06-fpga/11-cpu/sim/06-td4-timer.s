; timer.s  OUT を 1 つずつ増やし、15 の次に桁上げで 0 へ戻るのを JNC で見分ける (TD4 の 12 命令)
;          B を OUT に出し、B に 1 を足す。桁上げが無ければ頭へ、有れば OUT を 0b1111 にして止まる
start:  OUT B
        ADD B, 1
        JNC start
        OUT 0b1111
halt:   JMP halt
