ORG 0x0
V0: WORD $default, 0X180
V1: WORD $default, 0x180
V2: WORD $int2, 0X180
V3: WORD $int3, 0X180
V4: WORD $default, 0X180
V5: WORD $default, 0X180
V6: WORD $default, 0X180
V7: WORD $default, 0X180
ORG 0x012
X: WORD ?
max: WORD 0x0018 ; 24, максимальное значение Х
min: WORD 0xFFE6 ; -26, минимальное значение Х
temp:  WORD ?     ; Временная ячейка для умножения
xb: word ?
resx: word ?
default: IRET ; Обработка прерывания по умолчанию
START: 
DI
CLA
OUT 0x1 ; Запрет прерываний для неиспользуемых ВУ
OUT 0x3

OUT 0xB
OUT 0xD
OUT 0x11
OUT 0x15
OUT 0x19
OUT 0x1D
LD #0xA  ; Загрузка в аккумулятор MR (1000|0010=1010)
OUT 5    ; Разрешение прерываний для 2 ВУ
LD #0xB  ; Загрузка в аккумулятор MR (1000|0011=1011)
OUT 7    ; Разрешение прерываний для 3 ВУ
EI
main: 
DI ; Запрет прерываний чтобы обеспечить атом. операции
LD X
INC
INC
CALL check
ST X
EI
JUMP main
int3: 
DI ; Обработка прерывания на ВУ-3
LD X
ST xb
NOP
ASL
ASL
ADD X
NEG
SUB #5
NOP
OUT 6
ST resx
EI
IRET
int2: 
DI 
IN 4         ; Чтение DR ВУ-2 (АППАРАТНО сбрасывает флаг готовности!)
SXTB         ; Расширение знака 8->16 бит
ST temp      ; Сохраняем DR
ASL          ; AC = 2*DR
ADD temp     ; AC = 3*DR
NEG          ; AC = -3*DR
ADD X        ; AC = X - 3*DR
ST X
CALL check   ; Проверка ОДЗ
EI
IRET
check: ; Проверка принадлежности X к ОДЗ
check_min: CMP min ; Если x > min переход на проверку верхней границы
BPL check_max
JUMP ld_min ; Иначе загрузка min в аккумулятор
check_max: CMP max ; Проверка пересечения верхней границы X
BMI return ; Если x < max переход
ld_min: LD min ; Загрузка минимального значения в X
return: RET ; Метка возврата из проверки на ОДЗ