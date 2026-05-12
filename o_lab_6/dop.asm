; ==========================================
; ВЕКТОРЫ ПРЕРЫВАНИЙ
; ==========================================
ORG 0x0
V0: WORD $default, 0x180
V1: WORD $default, 0x180
V2: WORD $int2, 0x180
V3: WORD $int3, 0x180
V4: WORD $default, 0x180
V5: WORD $default, 0x180
V6: WORD $default, 0x180
V7: WORD $default, 0x180

; ==========================================
; ПЕРЕМЕННЫЕ
; ==========================================
ORG 0x012
CURR:      WORD ?
TEMP_PTR:  WORD ?
TEMP_VAL:  WORD ?
NEXT_NODE: WORD ?
PREV:      WORD ?
default:   IRET

; ==========================================
; СПИСОК (Циклический, узел: [Значение, АдресСлед])
; ==========================================
ORG 0x200
N1: WORD 10
    WORD $N2
N2: WORD 20
    WORD $N3
N3: WORD 30
    WORD $N4
N4: WORD 40
    WORD $N1

; ==========================================
; ОСНОВНАЯ ПРОГРАММА
; ==========================================
ORG 0x020
START:
    DI
    CLA
    OUT 0x1
    OUT 0x3
    OUT 0x5
    OUT 0x7
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
    LD $N1
    ST $CURR

MAIN:
    DI
    LD $CURR
    CALL $PRINT_NODE
    ADD #1
    ST $TEMP_PTR
    LD (TEMP_PTR)
    ST $CURR
    EI
    JUMP $MAIN

; ==========================================
; ОБРАБОТЧИК ВУ-2: Изменение значения
; ==========================================
int2:
    DI
    IN 4
    SXTB
    ST $TEMP_VAL
    LD $CURR
    ST $TEMP_PTR
    LD $TEMP_VAL
    ST (TEMP_PTR)
    EI
    IRET

; ==========================================
; ОБРАБОТЧИК ВУ-3: Удаление узла
; ==========================================
int3:
    DI
    IN 7                ; Сброс флага готовности ВУ-3
    LD $CURR
    ST $PREV
FIND_LOOP:
    LD $PREV
    ADD #1
    ST $TEMP_PTR
    LD (TEMP_PTR)
    SUB $CURR
    BEQ FOUND_PREV
    ST $PREV
    JUMP $FIND_LOOP
FOUND_PREV:
    LD $CURR
    ADD #1
    ST $TEMP_PTR
    LD (TEMP_PTR)
    ST $NEXT_NODE
    LD $PREV
    ADD #1
    ST $TEMP_PTR
    LD $NEXT_NODE
    ST (TEMP_PTR)
    LD $NEXT_NODE
    ST $CURR
    EI
    IRET

; ==========================================
; ПОДПРОГРАММА: Вывод узла на принтер
; Формат: [адр, знач, адр] -> \r\n
; ==========================================
PRINT_NODE:
    PUSH
    LD #0x5B; CALL $OUT_CHAR
    LD $CURR
    CALL $PRINT_HEX4
    LD #0x2C; CALL $OUT_CHAR
    LD #0x20; CALL $OUT_CHAR
    ; Значение (DEC)
    LD $CURR
    ST $TEMP_PTR
    LD (TEMP_PTR)
    CALL $PRINT_DEC
    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    ; Следующий адрес (HEX)
    LD $CURR
    ADD #1
    ST $TEMP_PTR
    LD (TEMP_PTR)
    CALL $PRINT_HEX4
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
; ПОДПРОГРАММА: Вывод 16-бит числа в HEX
; ==========================================
PRINT_HEX4:
    PUSH
    ST $TEMP_PTR
    ; Ниббл 3
    LD $TEMP_PTR
    AND #0xF000
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    CALL $HEX_DIG
    ; Ниббл 2
    LD $TEMP_PTR
    AND #0x0F00
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    ASR
    CALL $HEX_DIG
    ; Ниббл 1
    LD $TEMP_PTR
    AND #0x00F0
    ASR
    ASR
    ASR
    ASR
    CALL $HEX_DIG
    ; Ниббл 0
    LD $TEMP_PTR
    AND #0x000F
    CALL $HEX_DIG
    POP
    RET

HEX_DIG:
    PUSH
    ADD #0x30
    CMP #0x3A
    BCS IS_LETTER
    JUMP $PRINT_IT
IS_LETTER:
    ADD #7
PRINT_IT:
    CALL $OUT_CHAR
    POP
    RET

; ==========================================
; ПОДПРОГРАММА: Вывод знакового числа в DEC
; ==========================================
PRINT_DEC:
    PUSH
    ST $TEMP_PTR
    CLA
    ST $TEMP_VAL    
    ; Счётчик цифр
    LD $TEMP_PTR
    BEQ PRINT_ZERO
    LD $TEMP_PTR
    BPL POS_NUM
    NEG
    ST $TEMP_PTR
    LD #0x2D
    CALL $OUT_CHAR
    JUMP $EXTRACT_DIGITS
POS_NUM:
    JUMP $EXTRACT_DIGITS
PRINT_ZERO:
    LD #0x30
    CALL $OUT_CHAR
    JUMP $DONE_PRINT
EXTRACT_DIGITS:
    LD $TEMP_PTR
    BEQ DO_PRINT_DIGS
    CLA
    ST $NEXT_NODE   ; Частное
DIV_LOOP:
    LD $TEMP_PTR
    CMP #10
    BCC DIV_END
    LD $TEMP_PTR
    SUB #10
    ST $TEMP_PTR
    LD $NEXT_NODE
    INC
    ST $NEXT_NODE
    JUMP $DIV_LOOP
DIV_END:
    PUSH                 ; Сохраняем остаток в стек
    LD $TEMP_VAL
    INC
    ST $TEMP_VAL
    JUMP $EXTRACT_DIGITS
DO_PRINT_DIGS:
    LD $TEMP_VAL
    BEQ DONE_PRINT
    POP
    ADD #0x30
    CALL $OUT_CHAR
    LD $TEMP_VAL
    DEC
    ST $TEMP_VAL
    JUMP $DO_PRINT_DIGS
DONE_PRINT:
    POP
    RET

; ==========================================
; ПОДПРОГРАММА: Вывод символа на принтер (ВУ-5)
; DR=#C, SR=#D, Ready=бит 6 (0x40)
; ==========================================
OUT_CHAR:
    PUSH
    ST $TEMP_PTR
WAIT_PRN:
    IN 0xD
    AND #0x40
    BEQ WAIT_PRN
    LD $TEMP_PTR
    OUT 0xC
    POP
    RET