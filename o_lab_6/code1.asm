ORG 0x0
V0: WORD $default, 0X180
V1: WORD $default, 0x180
V2: WORD $int2, 0X180
V3: WORD $int3, 0X180
V4: WORD $default, 0X180
V5: WORD $default, 0X180
V6: WORD $default, 0X180
V7: WORD $default, 0X180
ORG 0x028
X: WORD ?
max: WORD 0x0018 
min: WORD 0xFFE6 
temp:  WORD ?     
xb: word ?
resx: word ?
default: IRET
START: 
DI
CLA
OUT 0x1 
OUT 0x3

OUT 0xB
OUT 0xD
OUT 0x11
OUT 0x15
OUT 0x19
OUT 0x1D
LD #0xA 
OUT 5   
LD #0xB  
OUT 7    
main: 
DI 
LD X
INC
INC
CALL check
ST X
EI
JUMP main
int3: 
DI 
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
IN 4         
SXTB         
ST temp      
ASL          
ADD temp     
NEG          
ADD X        
ST X
CALL check   
EI
IRET
check: 
check_min: CMP min 
BPL check_max
JUMP ld_min 
check_max: CMP max 
BMI return 
ld_min: LD min 
return: RET 