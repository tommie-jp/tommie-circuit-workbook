; ops.s  命令を 1 つずつ試し、結果を OUT に出す (11-11)。IN には 0x5A を入れておく
;        OUT の並びは 5A 0A FA 05 00 FE FF 42。フラグが違えば EE を出して止まる
        IN
        OUT             ; 5A
        AND  m0f
        OUT             ; 0A
        OR   mf0
        OUT             ; FA
        XOR  mff
        OUT             ; 05
        LDI  0x80
        SHL             ; 00、桁上げ 1、ゼロ 1
        JNC  bad
        JNZ  bad
        OUT             ; 00
        LDI  3
        SUBI 5          ; FE、借りが有るので桁上げ 0
        JC   bad
        OUT             ; FE
        SUBI 0xFE       ; 00、借りが無いので桁上げ 1、ゼロ 1
        JNC  bad
        JNZ  bad
        LDI  1
        SHR             ; 00、桁上げ 1
        JNC  bad
        ADDI 0xFF       ; FF、桁上げ 0
        JC   bad
        NOP
        OUT             ; FF
        LDI  0x42
        OUT             ; 42
        HLT
bad:    LDI  0xEE
        OUT
        HLT
m0f:    .db  0x0F
mf0:    .db  0xF0
mff:    .db  0xFF
