; ==========================================
; ПЕРЕМЕННЫЕ
; ==========================================
ORG 0x012
CURR:       WORD ?          ; Текущий адрес узла
TEMP_ADDR:  WORD ?          ; Временный указатель для работы с адресами
TEMP2:      WORD ?          ; Временное хранение для PRINT_HEX4
TEMP3:      WORD ?          ; Счетчик цифр для PRINT_DEC
CHAR_BUF:   WORD ?          ; Буфер для OUT_CHAR
ADDR_N1:    WORD 0x200     ; Константа с адресом начала списка (0x200)

; ==========================================
; ТЕСТОВЫЙ УЗЕЛ (Циклический список)
; Структура: [Значение, АдресСледующего]
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
    LD $ADDR_N1          ; Загружаем адрес первого узла (0x200)
    ST $CURR            ; Сохраняем в CURR

MAIN_LOOP:
    CALL $PRINT_NODE    ; Выводим информацию о текущем узле
    JUMP $MAIN_LOOP     ; Бесконечный переход на начало

; ==========================================
; ПОДПРОГРАММА: Вывод одного узла
; Формат: [АДРЕС_ТЕКУЩЕГО, ЗНАЧЕНИЕ, АДРЕС_СЛЕДУЮЩЕГО] ->
; ==========================================
PRINT_NODE:
    PUSH
    
    ; 1. Вывод '['
    LD #0x5B
    CALL $OUT_CHAR
    
    ; 2. Вывод адреса текущего узла (CURR) в HEX
    LD CURR
    CALL $PRINT_HEX4
    
    ; Вывод ', '
    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    
    ; 3. Чтение значения по адресу CURR (с автоинкрементом)
    LD (CURR)+
    ; ST $TEMP_ADDR       ; Копируем адрес в рабочий указатель
    ; LD (TEMP_ADDR)+    ; Читаем значение, TEMP_ADDR становится CURR + 1
    CALL $PRINT_DEC     ; Выводим значение в DEC
    
    ; Вывод ', '
    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    
    ; 4. Чтение адреса следующего узла (лежит по адресу CURR + 1)
    ; TEMP_ADDR сейчас указывает на CURR + 1
    ; LD (TEMP_ADDR)     ; Загружаем адрес следующего узла
    ; ST $CURR            ; ОБНОВЛЯЕМ глобальный CURR для следующей итерации!
    ld (CURR)+
    ST CURR
    CALL $PRINT_HEX4    ; Выводим этот адрес в HEX
    
    ; 5. Вывод '] -> ' и перенос строки
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
    ST $TEMP2           ; Сохраняем число, т.к. CALL может изменить AC
    
    ; Ниббл 3 (биты 15-12)
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
    CALL $HEX_DIGIT
    
    ; Ниббл 2 (биты 11-8)
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
    CALL $HEX_DIGIT
    
    ; Ниббл 1 (биты 7-4)
    LD $TEMP2
    ASR
    ASR
    ASR
    ASR
    AND #0x0F
    CALL $HEX_DIGIT
    
    ; Ниббл 0 (биты 3-0)
    LD $TEMP2
    AND #0x0F
    CALL $HEX_DIGIT
    
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
    ST $TEMP_ADDR       ; Используем TEMP_ADDR как частное
    
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
    JUMP $DIV_BY_10
DIV_END:
    LD $TEMP2           ; Остаток
    PUSH
    LD $TEMP_ADDR
    ST $TEMP2           ; Частное -> новое число
    LD $TEMP3
    INC
    ST $TEMP3
    JUMP $DIVIDE_LOOP

PRINT_ZERO:
    LD #0x30
    CALL $OUT_CHAR
    JUMP $DONE_DEC

OUTPUT_DIGITS:
    LD $TEMP3
    BEQ DONE_DEC
    POP
    ADD #0x30
    CALL $OUT_CHAR
    LD $TEMP3
    DEC
    ST $TEMP3
    JUMP $OUTPUT_DIGITS

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