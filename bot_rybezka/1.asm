;  Обойти массив 32-битных беззнаковых чисел, вычислить их сумму и сохранить результат как 40-битное значение (32-битная сумма + 8-битный счётчик переполнений).
ORG 0x20
res2: word 0
res1:word 0
c: word 0
adr: word 0x100
n: word 5
ad: word 0 
start:
ld adr
st ad
ad1:
ld (ad)+
add res2
st res2
ld (ad)+
adc res1
st res1
bcs hc
jump nl
hc:
ld c 
INC
st c
nl:
loop n 
JUMP ad1
hlt
org 0x100
word 0xffff, 1
word 1,1 
word 1,1 
word 1,1 
word 1,1 
word 1,1 
word 1,1 
word 1,1 
word 1,1 
word 1,1 
