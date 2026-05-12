; ==========================================
; ВЕКТОРЫ ПРЕРЫВАНИЙ (0x000 - 0x00F)
; ==========================================
ORG 0x0
V0: WORD $def, 0x180
V1: WORD $def, 0x180
V2: WORD $int2, 0x180
V3: WORD $int3, 0x180
V4: WORD $def, 0x180
V5: WORD $def, 0x180
V6: WORD $def, 0x180
V7: WORD $def, 0x180
def: IRET

; ==========================================
; ПЕРЕМЕННЫЕ
; ==========================================
ORG 0x012
CURR:            WORD ?
PREV_NEXT_ADDR:  WORD ?
NODE_PTR:        WORD ?
CHAR_BUF:        WORD ?
TEMP_VAL:        WORD ?
TEMP_ADDR:       WORD ?
TEMP2:           WORD ?
TEMP3:           WORD ?
LIST_START:      WORD 0x200

; ==========================================
; СПИСОК (Циклический)
; Структура узла: [Значение, АдресСледующего]
; ==========================================
ORG 0x200
NODE1: WORD 1
       WORD $NODE2
NODE2: WORD 2
       WORD $NODE3
NODE3: WORD 3
       WORD $NODE1

; ==========================================
; ОСНОВНАЯ ПРОГРАММА
; ==========================================
ORG 0x020
START:
    DI
    CLA
    OUT 0x1
    OUT 0x3
    OUT 0x9
    OUT 0xB
    OUT 0xD
    OUT 0xF
    OUT 0x11
    OUT 0x13
    OUT 0x15
    OUT 0x17
    OUT 0x19
    OUT 0x1B
    OUT 0x1D
    OUT 0x1F
    LD #0xA
    OUT 5
    LD #0xB
    OUT 7
    EI

    LD LIST_START
    ST CURR

    LD CURR
    ST NODE_PTR
FIND_INIT:
    LD NODE_PTR
    ADD #1
    ST $TEMP2
    LD (TEMP2)
    SUB CURR
    BEQ INIT_DONE
    LD NODE_PTR
    ADD #1
    ST $TEMP2
    LD (TEMP2)
    ST NODE_PTR
    JUMP FIND_INIT
INIT_DONE:
    LD $TEMP2
    ST PREV_NEXT_ADDR

MAIN_LOOP:
    EI
    CALL PRINT_NODE
    JUMP MAIN_LOOP

; ==========================================
; ОБРАБОТЧИК ВУ-2: Изменение значения
; ==========================================
int2:
    DI
    IN 4
    SXTB
    ST TEMP_VAL
    LD CURR
    ST $TEMP2
    LD TEMP_VAL
    ST (TEMP2)
    EI
    IRET

; ==========================================
; ОБРАБОТЧИК ВУ-3: Удаление узла
; ==========================================
int3:
    DI
    IN 7
    LD CURR
    BEQ EXIT_INT3
    LD CURR
    ADD #1
    ST $TEMP2
    LD (TEMP2)
    SUB CURR
    BEQ LAST_NODE
    LD CURR
    ADD #1
    ST $TEMP2
    LD (TEMP2)
    ST $TEMP3
    LD PREV_NEXT_ADDR
    ST $TEMP2
    LD $TEMP3
    ST (TEMP2)
    LD $TEMP3
    ST CURR
    JUMP EXIT_INT3
LAST_NODE:
    CLA
    ST CURR
    ST PREV_NEXT_ADDR
EXIT_INT3:
    EI
    IRET

; ==========================================
; ВЫВОД УЗЛА
; ==========================================
PRINT_NODE:
    PUSH
    LD CURR
    ST NODE_PTR

    LD #0x5B
    CALL $OUT_CHAR

    LD NODE_PTR
    CALL PRINT_HEX4

    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR

    LD (NODE_PTR)
    CALL PRINT_DEC

    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR

    LD NODE_PTR
    ADD #1
    ST $TEMP2
    LD (TEMP2)
    CALL PRINT_HEX4

    LD CURR
    ADD #1
    ST PREV_NEXT_ADDR
    LD NODE_PTR
    ADD #1
    ST $TEMP2
    LD (TEMP2)
    ST CURR

    LD #0x5D
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    LD #0x2D
    CALL $OUT_CHAR
    LD #0x3E
    CALL $OUT_CHAR
    LD #0x0D
    CALL $OUT_CHAR
    LD #0x0A
    CALL $OUT_CHAR

    POP
    RET

; ==========================================
; ВЫВОД HEX
; ==========================================
PRINT_HEX4:
    PUSH
    ST $TEMP2

    LD $TEMP2
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    AND #0x0F
    CALL HEX_DIGIT

    LD $TEMP2
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    AND #0x0F
    CALL HEX_DIGIT

    LD $TEMP2
    ASR
    ASR
    ASR
    ASR
    AND #0x0F
    CALL HEX_DIGIT

    LD $TEMP2
    AND #0x0F
    CALL HEX_DIGIT

    POP
    RET

HEX_DIGIT:
    PUSH
    ADD #0x30
    CMP #0x3A
    BCS IS_LETTER
    JUMP PRINT_IT
IS_LETTER:
    ADD #7
PRINT_IT:
    CALL $OUT_CHAR
    POP
    RET

; ==========================================
; ВЫВОД DEC
; ==========================================
PRINT_DEC:
    PUSH
    ST $TEMP2

    LD $TEMP2
    BPL POSITIVE
    NEG
    ST $TEMP2
    LD #0x2D
    CALL $OUT_CHAR
POSITIVE:
    LD $TEMP2
    BEQ PRINT_ZERO

    CLA
    ST $TEMP3
DIVIDE_LOOP:
    LD $TEMP2
    BEQ OUTPUT_DIGITS

    CLA
    ST $TEMP_ADDR
DIV_BY_10:
    LD $TEMP2
    CMP #10
    BCC DIV_END
    LD $TEMP2
    SUB #10
    ST $TEMP2
    LD $TEMP_ADDR
    INC
    ST $TEMP_ADDR
    JUMP DIV_BY_10
DIV_END:
    LD $TEMP2
    PUSH
    LD $TEMP_ADDR
    ST $TEMP2
    LD $TEMP3
    INC
    ST $TEMP3
    JUMP DIVIDE_LOOP

PRINT_ZERO:
    LD #0x30
    CALL $OUT_CHAR
    JUMP DONE_DEC

OUTPUT_DIGITS:
    LD $TEMP3
    BEQ DONE_DEC
    POP
    ADD #0x30
    CALL $OUT_CHAR
    LD $TEMP3
    DEC
    ST $TEMP3
    JUMP OUTPUT_DIGITS

DONE_DEC:
    POP
    RET

; ==========================================
; ВЫВОД СИМВОЛА
; ==========================================
OUT_CHAR:
    ST $CHAR_BUF
WAIT_PRN:
    IN 0xD
    AND #0x40
    BEQ WAIT_PRN
    LD $CHAR_BUF
    OUT 0xC
    RET