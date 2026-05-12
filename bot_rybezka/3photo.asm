org 0x20
list_adr: word 0x6d0
n: word 19
max: word 0xff
mask_tresh: word 0x1ff
mask_neg: word 0xfe00
res: word 0x400
tmp_adr: word ?
tmp_res: word ?
curr: word ?
addition: word 166
negative: word 0xffff

org 0x30
START:
    ld list_adr
    st tmp_adr
    ld res
    st tmp_res
loop_pr:
    ld (tmp_adr)+
    and mask_tresh
    cmp max
    bmi function
    or mask_neg
function:
    asl
    asl
    asl
    add addition
    st (tmp_res)+
    bmi min
    CLA
    JUMP s
min:
    ld negative
s:
    st (tmp_res)+
    loop n 
    JUMP loop_pr
    hlt

org 0x6d0
word -1,0x100, 5, -23, 1, 560, -250