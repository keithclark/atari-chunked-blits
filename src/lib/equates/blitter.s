; ------------------------------------------------------------------------------
; Blitter
; ------------------------------------------------------------------------------

BLITTER                               equ $ffff8A00
BLITTER_SOURCE_X_BYTE_INC             equ $ffff8A20
BLITTER_SOURCE_Y_BYTE_INC             equ $ffff8A22
BLITTER_SOURCE_ADDRESS                equ $ffff8A24
BLITTER_LEFT_MASK                     equ $ffff8A28
BLITTER_MIDDLE_MASK                   equ $ffff8A2A
BLITTER_RIGHT_MASK                    equ $ffff8A2C
BLITTER_DESTINATION_X_BYTE_INC        equ $ffff8A2E
BLITTER_DESTINATION_Y_BYTE_INC        equ $ffff8A30
BLITTER_DESTINATION_ADDRESS           equ $ffff8A32
BLITTER_X_COUNT                       equ $ffff8A36
BLITTER_Y_COUNT                       equ $ffff8A38
BLITTER_HOP                           equ $ffff8A3A
BLITTER_LOP                           equ $ffff8A3B
BLITTER_CONTROL                       equ $ffff8A3C
BLITTER_SKEW                          equ $ffff8A3D
    
    
    
SOURCE_X_BYTE_INC                     equ $20
SOURCE_Y_BYTE_INC                     equ $22
SOURCE_ADDRESS                        equ $24
LEFT_MASK                             equ $28
MIDDLE_MASK                           equ $2A
RIGHT_MASK                            equ $2C
DESTINATION_X_BYTE_INC                equ $2E
DESTINATION_Y_BYTE_INC                equ $30
DESTINATION_ADDRESS                   equ $32
X_COUNT                               equ $36
Y_COUNT                               equ $38
HOP                                   equ $3A
LOP                                   equ $3B
CONTROL                               equ $3C
SKEW                                  equ $3D



LOP_ALL_ZEROS                         equ $0
LOP_SOURCE_AND_DESTINATION            equ $1
LOP_SOURCE_AND_NOT_DESTINATION        equ $2
LOP_SOURCE                            equ $3
LOP_NOT_SOURCE_AND_DESTINATION        equ $4
LOP_DESTINATION                       equ $5
LOP_SOURCE_XOR_DESTINATION            equ $6
LOP_SOURCE_OR_DESTINATION             equ $7
LOP_NOT_SOURCE_AND_NOT_DESTINATION    equ $8
LOP_NOT_SOURCE_XOR_DESTINATION        equ $9
LOP_NOT_DESTINATION                   equ $a
LOP_SOURCE_OR_NOT_DESTINATION         equ $b
LOP_NOT_SOURCE                        equ $c
LOP_NOT_SOURCE_OR_DESTINATION         equ $d
LOP_NOT_SOURCE_OR_NOT_DESTINATION     equ $e
LOP_ALL_ONES                          equ $f