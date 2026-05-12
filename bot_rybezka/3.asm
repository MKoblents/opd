ORG 0x20
adr: word 0x100
n: word 4
res: word 0x200
tmp_adr: word ?
tmp_res: word ?
max_pos: word 0x200
tresh_mask: word 0x3ff
neg_mask: word 0xfc00
tmp: word ?
second: word ?
addition: word 250
negat: word 0xffff
START:
    ld adr
    st tmp_adr
    ld res
    st tmp_res
loop_pr:
    ld (tmp_adr)+
    and tresh_mask
    cmp max_pos
    bge negativim
    jump function
negativim:
    or neg_mask

function:
    st tmp
    asl
    ASL
    asl
    sub tmp
    add addition
    st (tmp_res)+
    bmi otr
    cla 
    jump s
otr: 
    ld negat
s:
    st (tmp_res)+
    loop n
    jump loop_pr
    hlt

org 0x100
word 1,-1,250,0x200

