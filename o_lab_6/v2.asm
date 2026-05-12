; ==========================================
; ВЕКТОРЫ ПРЕРЫВАНИЙ (0x000 - 0x00F)
; ==========================================
ORG 0x0
V0: WORD $def, 0x180
V1: WORD $def, 0x180
V2: WORD $int2, 0x180   ; Вектор 2 указывает на обработчик int2
V3: WORD $int3, 0x180   ; ИЗМЕНЕНО: Вектор 3 указывает на новый обработчик int3
V4: WORD $def, 0x180
V5: WORD $def, 0x180
V6: WORD $def, 0x180
V7: WORD $def, 0x180
def: IRET               ; Пустой обработчик для остальных

; ==========================================
; ПЕРЕМЕННЫЕ
; ==========================================
ORG 0x012
CURR:       WORD ?          ; Текущий адрес узла
TEMP_ADDR:  WORD ?          ; Временный указатель (для поиска в списке)
TEMP2:      WORD ?          ; Временное хранение для PRINT_HEX4
TEMP3:      WORD ?          ; Счетчик цифр для PRINT_DEC
CHAR_BUF:   WORD ?          ; Буфер для OUT_CHAR
TEMP_VAL:   WORD ?          ; Временная переменная для значения из ВУ-2 (и целевого узла)
adr: word 0x200
val_adr: word ?

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
    DI                  ; Запрет прерываний на время настройки
    CLA
    
    ; 1. Запрет прерываний на всех неиспользуемых КВУ
    OUT 0x1
    OUT 0x3
    OUT 0x7             ; Сначала отключаем ВУ-3 (как в твоем коде)
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

    ; 2. Настройка MR ВУ-2 (Адрес 5): Разрешить прерывания, Вектор 2
    ; 0xA = 1000b (Разрешить) | 010b (Вектор 2)
    LD #0xA
    OUT 5
    
    ; 3. Настройка MR ВУ-3 (Адрес 7): Разрешить прерывания, Вектор 3
    ; 0xB = 1000b (Разрешить) | 011b (Вектор 3)
    LD #0xB
    OUT 7
    
    EI                  ; Глобальное разрешение прерываний
    
    ; 4. Инициализация указателя списка
    LD adr           ; Загружаем АДРЕС NODE1 (0x200)
    ST CURR           ; Сохраняем в CURR

MAIN_LOOP:
    EI
    CALL $PRINT_NODE    ; Выводим информацию о текущем узле
    JUMP $MAIN_LOOP     ; Бесконечный переход на начало

; ==========================================
; ОБРАБОТЧИК ПРЕРЫВАНИЯ ВУ-2
; Задача: Изменить значение в текущем узле
; ==========================================
int2:
    DI                  ; Запрет прерываний на время обработки
    
    IN 4                ; Читаем из DR ВУ-2 (аппаратно сбрасывает Ready)
    SXTB                ; Расширяем знак (8 бит -> 16 бит)
    ST $TEMP_VAL        ; Сохраняем считанное значение
    
    ; Записываем значение в память по адресу, сохраненному в val_adr
    st (val_adr)
    
    EI                  ; Разрешаем прерывания
    IRET                ; Возврат из прерывания

; ==========================================
; ОБРАБОТЧИК ПРЕРЫВАНИЯ ВУ-3
; Задача: Удалить текущий узел из списка
; ==========================================
int3:
    DI                  ; Запрет прерываний
    IN 6                ; Читаем DR ВУ-3 (сбрасывает флаг готовности)
    
    LD CURR             ; Загружаем адрес текущего узла (который надо удалить)
    BEQ EXIT_INT3       ; Если список пуст (0), выходим
    
    ST TEMP_VAL         ; Сохраняем адрес удаляемого узла в TEMP_VAL
    
    ; Проверка: является ли этот узел последним в цикле? (Next == Self)
    ADD #1              ; Смещаемся к полю Next
    ST TEMP2
    LD (TEMP2)          ; Загружаем адрес следующего узла
    SUB TEMP_VAL        ; Сравниваем Next с Self (адресом текущего узла)
    BEQ LAST_NODE       ; Если равны, это последний узел -> обнуляем список
    
    ; Ищем предыдущий узел (Predecessor), у которого Next == TEMP_VAL
    LD TEMP_VAL         ; Начинаем поиск с текущего узла
    ST TEMP_ADDR        ; TEMP_ADDR будет указателем поиска
    
SEARCH_LOOP:
    LD TEMP_ADDR        ; Берем адрес узла поиска
    ADD #1              ; Смещаемся к его полю Next
    ST TEMP2
    LD (TEMP2)          ; Загружаем Next этого узла
    SUB TEMP_VAL        ; Сравниваем с адресом удаляемого узла
    BEQ FOUND_PREV      ; Если равны, значит TEMP_ADDR - это предыдущий узел
    
    ; Иначе переходим к следующему узлу для поиска
    LD TEMP_ADDR
    ADD #1
    ST TEMP2
    LD (TEMP2)          ; Загружаем Next
    ST TEMP_ADDR        ; Обновляем указатель поиска
    JUMP SEARCH_LOOP

FOUND_PREV:
    ; TEMP_ADDR теперь содержит адрес ПРЕДЫДУЩЕГО узла
    ; TEMP_VAL содержит адрес УДАЛЯЕМОГО узла
    
    ; 1. Узнаем адрес узла, который идет ПОСЛЕ удаляемого (NextNode)
    LD TEMP_VAL
    ADD #1
    ST TEMP2
    LD (TEMP2)
    ST TEMP3            ; Сохраняем NextNode в TEMP3
    
    ; 2. Обновляем ссылку в ПРЕДЫДУЩЕМ узле: Prev->Next = NextNode
    LD TEMP_ADDR
    ADD #1
    ST TEMP2
    LD TEMP3
    ST (TEMP2)
    
    ; 3. Обновляем глобальный указатель CURR на NextNode
    LD TEMP3
    ST CURR
    JUMP EXIT_INT3

LAST_NODE:
    ; Если остался только один узел, обнуляем список
    CLA
    ST CURR

EXIT_INT3:
    EI
    IRET

; ==========================================
; ПОДПРОГРАММА: Вывод одного узла
; ==========================================
PRINT_NODE:
    PUSH
    
    ; 1. Вывод '['
    LD #0x5B
    CALL $OUT_CHAR
    
    ; 2. Вывод адреса текущего узла (CURR) в HEX
    LD CURR
    st val_adr
    CALL $PRINT_HEX4
    
    ; Вывод ', '
    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    
    ; 3. Чтение значения по адресу CURR (с автоинкрементом)
    LD (CURR)+
    CALL $PRINT_DEC     ; Выводим значение в DEC
    
    ; Вывод ', '
    LD #0x2C
    CALL $OUT_CHAR
    LD #0x20
    CALL $OUT_CHAR
    
    ; 4. Чтение адреса следующего узла (лежит по адресу CURR + 1)
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