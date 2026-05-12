; org 0x20
; adr: word 0x6dd
; n: word 13
; tmp_adr: word 0

org 0x400
sum1: word 0
sum2: word 0
adr: word 0x6dd
n: word 13
tmp_adr: word 0
tresh_mask: word 0x0007
sigm_mask: word 0xfff8
maks: word 0x4
tmp: word ?
sign_bit: WORD 0x0004
START:
    ld adr
    add #2 ;изначально номер 3, прибавив два, я получила бладшее слово 4ого элемента
    st tmp_adr
    ld n
    dec
    st n
loop_pr:
    ld (tmp_adr)+
    add sum1
    st sum1
    ld (tmp_adr)+
    and tresh_mask
    st tmp
    ld tmp
    and sign_bit
    beq is_pos
    ld tmp
    or sigm_mask
    JUMP addd
is_pos:
    ld tmp
addd:
    adc sum2
    st sum2
    ld tmp_adr
    add #6 ;получили адресс следующего элемента массива, который делится на 4
    st tmp_adr
    ld n
    sub #3 ;вычли те три, которые пропустили ручками
    st n
    loop n
    JUMP loop_pr
    hlt


org 0x6dd
word 0xffff, 0x1
word 0xffff, 0xffff
word 0xffff, 0x2
word 0xffff, 0x3
word 0xffff, 0x4
word 0xffff, 0xffff
word 0xffff, 0x1
word 0xffff, 0x2
word 0xffff, 0x3
word 0xffff, 0xffff
word 0xffff, 0x1
word 0xffff, 0x1
word 0xffff, 0x1

