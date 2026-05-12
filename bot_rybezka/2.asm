; Отфильтровать 16-битный знаковый массив в два выходных буфера: один для неотрицательных чисел (≥0), другой для оригинальных индексов всех отрицательных чисел (<0). Подсчитать количество отрицательных.

ORG 0x20
LEN:      WORD 10
ARR_ADDR: WORD 0x100
NEG_CNT:  WORD 0
POS_BUF:  WORD 0x200
NEG_BUF:  WORD 0x300
CUR_IDX:  WORD 0          ; 0-based element index
PTR_ARR:  WORD 0x100      ; Runtime array pointer
PTR_POS:  WORD 0x200      ; Runtime positive buffer pointer
PTR_NEG:  WORD 0x300      ; Runtime negative index buffer pointer

START:
    LD ARR_ADDR
    ST PTR_ARR            ; Initialize array pointer
    LD POS_BUF
    ST PTR_POS            ; Initialize positive buffer pointer
    LD NEG_BUF
    ST PTR_NEG            ; Initialize negative buffer pointer
    CLA
    ST NEG_CNT
    ST CUR_IDX            ; Clear counters

LOOP_START:
    LD (PTR_ARR)+         ; Load element, PTR_ARR ← PTR_ARR + 1
    BGE STORE_POS         ; If signed AC >= 0, branch to positive handler

    ; --- NEGATIVE ELEMENT (<0) ---
    ; LD CUR_IDX            ; Load current index
    ST (PTR_NEG)+         ; Store index, PTR_NEG ← PTR_NEG + 1

    LD NEG_CNT
    INC
    ST NEG_CNT            ; Increment negative count

    JUMP NEXT_ITER

STORE_POS:
    ; AC still holds the non-negative value from LD
    ST (PTR_POS)+         ; Store value, PTR_POS ← PTR_POS + 1

NEXT_ITER:
    LD CUR_IDX
    INC
    ST CUR_IDX            ; Advance index for next iteration

    LOOP LEN              ; Decrement LEN. If LEN > 0, fall through. If ≤ 0, skip JUMP.
    JUMP LOOP_START
    HLT

org 0x100
word -1,1,1,1,-1,1,1,1,-1,-1

