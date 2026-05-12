org 0x20
adr: word 0x100
n: word 5
res: word 0x200
tmp_adr: word ?
tmp_res: word ?
tmp: word ?
tresh_mask: word 0xfff
max_pos: word 0x800
neg_mask: word  0xf000
f: word 0xffff
addition: word 500
start:
    ld adr
    st tmp_adr
    ld res
    st tmp_res
loop_process:
    ld (tmp_adr)+
    and tresh_mask
    cmp max_pos
    bmi function
    or neg_mask
function:
    st tmp
    asl
    asl
    asl
    add tmp
    add tmp
    add addition
    st (tmp_res)+
    bmi negative
    cla
    jump saving
negative:
    ld f
saving:
    st (tmp_res)+
    loop n 
    jump loop_process
    hlt