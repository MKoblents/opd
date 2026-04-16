 
ORG 0x200
NUMBER:     WORD 12     ; ← Ваше число


START:
    LD NUMBER
    CALL OUT_DECIMAL_VU7
    HLT

; ========================================
; ВЫВОД ЧИСЛА В ДЕСЯТИЧНОМ ФОРМАТЕ
; ========================================

OUT_DECIMAL_VU7:
    ST TEMP_NUM
    LD #7                   ; Начинаем с позиции 7 (СЛЕВА)
    ST POS
    
    ; Проверка на 0
    LD TEMP_NUM
    BEQ SHOW_ZERO
    
    ; Сначала считаем количество цифр
    LD TEMP_NUM
    CALL COUNT_DIGITS
    ST DIGIT_COUNT
    
    ; Вычисляем стартовую позицию
    LD #7
    SUB DIGIT_COUNT
    INC
    ST POS
    
CONVERT_LOOP:
    LD TEMP_NUM
    BEQ DONE_CONVERT
    
    ; Деление на 10
    CLA
    ST TEMP_DIV
    
DIV_LOOP:
    LD TEMP_NUM
    CMP #10
    BLT DIV_END
    
    LD TEMP_NUM
    SUB #10
    ST TEMP_NUM
    
    LD TEMP_DIV
    INC
    ST TEMP_DIV
    JUMP DIV_LOOP
    
DIV_END:
    ; TEMP_NUM = цифра (0-9)
    ; Формируем код: (позиция << 4) | цифра
    LD POS
    ASL
    ASL
    ASL
    ASL
    OR TEMP_NUM
    CALL OUT_DIGIT_VU7
    
    LD POS
    INC
    ST POS
    
    LD TEMP_DIV
    ST TEMP_NUM
    JUMP CONVERT_LOOP
    
SHOW_ZERO:
    CLA
    ST TEMP_DIG
    LD #0x70                ; Позиция 7, цифра 0
    CALL OUT_DIGIT_VU7
    LD #0x60
    CALL OUT_DIGIT_VU7
    LD #0x50
    CALL OUT_DIGIT_VU7
    LD #0x40
    CALL OUT_DIGIT_VU7
    LD #0x30
    CALL OUT_DIGIT_VU7
    LD #0x20
    CALL OUT_DIGIT_VU7
    LD #0x10
    CALL OUT_DIGIT_VU7
    LD #0x00
    CALL OUT_DIGIT_VU7
    JUMP DONE_CONVERT
    
DONE_CONVERT:
    RET

; ========================================
; ПОДСЧЁТ КОЛИЧЕСТВА ЦИФР
; ========================================
COUNT_DIGITS:
    ST TEMP_COUNT
    CLA
    ST DIGIT_CNT
    
COUNT_LOOP:
    LD TEMP_COUNT
    BEQ COUNT_DONE
    
    LD TEMP_COUNT
    CMP #10
    BLT COUNT_INC
    
    LD TEMP_COUNT
    SUB #10
    ST TEMP_COUNT
    
    LD DIGIT_CNT
    INC
    ST DIGIT_CNT
    JUMP COUNT_LOOP
    
COUNT_INC:
    LD DIGIT_CNT
    INC
    ST DIGIT_CNT
    
COUNT_DONE:
    LD DIGIT_CNT
    RET

; ========================================
; ВЫВОД ОДНОЙ ЦИФРЫ
; ========================================
OUT_DIGIT_VU7:
    ST TEMP_DIG
WAIT_VU7:
    IN 0x15
    AND #0x40
    BEQ WAIT_VU7
    LD TEMP_DIG
    OUT 0x14
    RET

; Переменные
TEMP_NUM:   WORD ?
TEMP_DIV:   WORD ?
TEMP_DIG:   WORD ?
TEMP_COUNT: WORD ?
POS:        WORD ?
DIGIT_COUNT: WORD ?
DIGIT_CNT:  WORD ?
