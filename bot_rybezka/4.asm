org 0x20
adr: word 0x100
n: word 5
res: word 0x200
tmp_adr: word ?
tmp_res: word ?
tmp: word ?
addition: word 400
sign_bit: word 0x0400
tresh_mask: word 0x7ff
neg_mask: word 0xf800
min: word 0xffff

START:
    ld adr
    st tmp_adr
    ld res
    st tmp_res
loop_pr:
    ld (tmp_adr)+
    and tresh_mask
    cmp sign_bit
    bmi function
    or neg_mask
function:
    st tmp
    asl
    asl
    asl
    add tmp
    sub addition
    st (tmp_res)+
    bmi sn
    cla
    jump s
sn:
    ld min
s:
    st (tmp_res)+
    loop n
    jump loop_pr
    hlt

org 0x100
word 0x07ff, 0x3ff, 1,-1,5