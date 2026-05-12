; ==========================================
; ПЕРЕМЕННЫЕ
; ==========================================
ORG 0x012
CURR:       WORD ?
TEMP:       WORD ?
TEMP_ADDR:  WORD ?
TEMP2:      WORD ?
TEMP3:      WORD ?
CHAR_BUF:   WORD ?
ADDR_N1:    WORD $NODE1

; ==========================================
; ТЕСТОВЫЙ УЗЕЛ
; Структура: [Значение, АдресСледующего]
; ==========================================
ORG 0x200
NODE1: WORD 10
       WORD $NODE2
NODE2: WORD 20
       WORD $NODE1

; ==========================================
; ОСНОВНАЯ ПРОГРАММА
; ==========================================
ORG 0x020
START:
    LD ADDR_N1
    ST CURR
    CALL PRINT_NODE
    HLT

; ==========================================
; ПОДПРОГРАММА: Вывод одного узла
; Формат: [CURR_исх, ЗНАЧЕНИЕ_ПО_CURR, CURR_после_+] ->
; ==========================================
PRINT_NODE:
    PUSH
     ; '['
    LD #0x5B
    CALL $OUT_CHAR
    ; 1. Вывод исходного значения CURR
    LD CURR
    CALL PRINT_HEX4
    
    ; Вывод ', '
    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    
    ; 2. Значение по адресу CURR (с автоинкрементом)
    LD CURR
    ST TEMP_ADDR
    LD (TEMP_ADDR)+
    CALL PRINT_DEC
    
    ; Вывод ', '
    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    
    ; 3. Обновляем CURR и выводим его (после автоинкремента)
    LD TEMP_ADDR
    ST CURR
    ld (CURR)
    CALL PRINT_HEX4
    
    ; Вывод '] -> ' и перенос строки
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
; ПОДПРОГРАММА: Вывод 16-бит числа в HEX (4 цифры)
; ==========================================
PRINT_HEX4:
    PUSH
    ST TEMP2
    
    ; Ниббл 3 (биты 15-12)
    LD TEMP2
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
    
    ; Ниббл 2 (биты 11-8)
    LD TEMP2
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
    
    ; Ниббл 1 (биты 7-4)
    LD TEMP2
    ASR
    ASR
    ASR
    ASR
    AND #0x0F
    CALL HEX_DIGIT
    
    ; Ниббл 0 (биты 3-0)
    LD TEMP2
    AND #0x0F
    CALL HEX_DIGIT
    
    POP
    RET

; ==========================================
; ПОДПРОГРАММА: Вывод одной HEX цифры (0-F)
; ==========================================
HEX_DIGIT:
    PUSH
    ADD #0x30
    CMP #0x3A
    BCS IS_LETTER
    JUMP PRINT_IT
IS_LETTER:
    ADD #7
PRINT_IT:
    CALL OUT_CHAR
    POP
    RET

; ==========================================
; ПОДПРОГРАММА: Вывод знакового числа в DEC
; ==========================================
PRINT_DEC:
    PUSH
    ST TEMP2
    
    LD TEMP2
    BPL POSITIVE
    NEG
    ST TEMP2
    LD #0x2D
    CALL OUT_CHAR
POSITIVE:
    LD TEMP2
    BEQ PRINT_ZERO
    
    CLA
    ST TEMP3
DIVIDE_LOOP:
    LD TEMP2
    BEQ OUTPUT_DIGITS
    
    CLA
    ST TEMP
DIV_BY_10:
    LD TEMP2
    CMP #10
    BCC DIV_END
    LD TEMP2
    SUB #10
    ST $TEMP2
    LD $TEMP
    INC
    ST $TEMP
    JUMP DIV_BY_10
DIV_END:
    LD $TEMP2
    PUSH
    LD $TEMP
    ST $TEMP2
    LD $TEMP3
    INC
    ST $TEMP3
    JUMP DIVIDE_LOOP

PRINT_ZERO:
    LD #0x30
    CALL OUT_CHAR
    JUMP DONE_DEC

OUTPUT_DIGITS:
    LD $TEMP3
    BEQ DONE_DEC
    POP
    ADD #0x30
    CALL OUT_CHAR
    LD $TEMP3
    DEC
    ST $TEMP3
    JUMP OUTPUT_DIGITS

DONE_DEC:
    POP
    RET

; ==========================================
; ПОДПРОГРАММА: Вывод символа на принтер (ВУ-5)
; DR=#C, SR=#D, Ready=бит 6 (0x40)
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