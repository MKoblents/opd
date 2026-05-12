org 0x20
list_ardd: word 0x6ce
n: word 3
res: word 0x400
tmp_adr: word ?
tmp_curr: word ?
tmp_res_adr: word ?
addition: word 1485
cheak: word 0xfff
max: word 2048
mask: word 0xF000
full: word 0xffff


org 0x30
START: 
    ld list_ardd
    st tmp_adr
    ld res
    st tmp_res_adr
process_loop:
    ld (tmp_adr)+
    and cheak
    cmp max
    bmi function
    or mask
    
function:
    st tmp_curr
    asl
    asl
    asl
    asl
    sub tmp_curr
    add addition
    

saving:
    st (tmp_res_adr)+
    bmi f
    CLA
    JUMP s
f:  
    ld full
s:
    st (tmp_res_adr)+
    loop n
    JUMP process_loop
    hlt


org 0x6ce
word -1,2048,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1






; ---------------------------------------------------------
; ЗАДАНИЕ: Вычисление f(x) = 15x + 1485 для массива 12-бит знаковых чисел
; Вход:  массив по адресу 0x06E, 21 элемент, хранится по границе слов
; Выход: 32-битные результаты (little-endian) по адресу 0x400
; ---------------------------------------------------------

ORG 0x020               ; Область переменных
N:          WORD 21     ; Счётчик цикла
SRC:        WORD 0x06E  ; Начальный адрес входного массива
DST:        WORD 0x400  ; Начальный адрес выходного массива
SRC_PTR:    WORD 0      ; Рабочий указатель на вход
DST_PTR:    WORD 0      ; Рабочий указатель на выход
TEMP:       WORD 0      ; Временное хранение x
CONST_1485: WORD 1485   ; Константа для сложения
MASK_12:    WORD 0x0FFF ; Маска для выделения 12 бит
SIGN_BIT:   WORD 0x0800 ; Бит знака для 12-бит числа (11-й разряд)
SIGN_EXT:   WORD 0xF000 ; Маска знакового расширения до 16 бит
ONES:       WORD 0xFFFF ; -1 для заполнения старшего слова

START:
    ; Инициализация рабочих указателей
    LD SRC
    ST SRC_PTR
    LD DST
    ST DST_PTR

LOOP_START:
    ; 1. ЗАГРУЗКА И КОРРЕКТНАЯ ОБРАБОТКА 12-БИТ ЗНАКА
    LD (SRC_PTR)+       ; Загрузить элемент, SRC_PTR ← SRC_PTR + 1
    AND MASK_12         ; Отбросить «мусорные» биты 12..15
    CMP SIGN_BIT        ; Сравнить с 0x0800 (проверка 11-го бита)
    BMI SIGNED_OK       ; Если AC < 0x0800, число положительное → пропустить
    OR SIGN_EXT         ; Если AC >= 0x0800, знаковое расширение: биты 12..15 ← 1
SIGNED_OK:
    ; AC теперь содержит корректно знаково-расширенное 16-бит x

    ; 2. ВЫЧИСЛЕНИЕ f(x) = 15x + 1485
    ; 15x = 16x - x = (x << 4) - x
    ST TEMP             ; Сохранить исходное x
    ASL                 ; x * 2
    ASL                 ; x * 4
    ASL                 ; x * 8
    ASL                 ; x * 16
    SUB TEMP            ; 16x - x = 15x (флаги NZVC обновляются)
    ADD CONST_1485      ; f(x) = 15x + 1485 (флаг N уже отражает знак результата)

    ; 3. СОХРАНЕНИЕ 32-БИТ РЕЗУЛЬТАТА (LITTLE-ENDIAN)
    ST (DST_PTR)+       ; Записать младшее слово, DST_PTR ← DST_PTR + 1
    
    ; Определение старшего слова по знаку результата (флаг N установлен ADD)
    BMI NEG_HIGH        ; Если результат < 0, старшее слово = 0xFFFF
    CLA                 ; Если результат >= 0, старшее слово = 0x0000
    JUMP STORE_HIGH
NEG_HIGH:
    LD ONES             ; AC ← 0xFFFF
STORE_HIGH:
    ST (DST_PTR)+       ; Записать старшее слово, DST_PTR ← DST_PTR + 1

NEXT_ITER:
    LOOP N              ; N ← N - 1; если N > 0 → выполнить следующую инструкцию
    JUMP LOOP_START     ; Если N > 0, переход в начало цикла
                        ; Если N ≤ 0, LOOP пропускает JUMP, выполнение идёт дальше
    HLT

; ---------------------------------------------------------
; ТЕСТОВЫЕ ДАННЫЕ (21 элемент)
; Размещаются по адресу 0x06E. В эмуляторе можно не вносить вручную,
; если используется директива ORG.
; ---------------------------------------------------------
ORG 0x06E
WORD 10, -20, 100, -150, 500, -800, 2047, -2048, 0, 1234, -1234
WORD 50, -50, 777, -777, 333, -333, 1, -1, 15, -15, 200