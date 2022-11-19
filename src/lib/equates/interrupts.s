; ------------------------------------------------------------------------------
; MFP
; ------------------------------------------------------------------------------
MFP_HBL_VECTOR                          equ $68
MFP_VBL_VECTOR                          equ $70
MFP_ACIA_VECTOR                         equ $118
MFP_TIMER_B_VECTOR                      equ $120

MFP_ACTIVE_EDGE                         equ $FFFFFA03

; IRQ A (Timer A/B, Mono & RS-232)
MFP_INTERRUPT_ENABLE_A                  equ $FFFFFA07
MFP_INTERRUPT_PENDING_A                 equ $FFFFFA0B
MFP_INTERRUPT_IN_SERVICE_A              equ $FFFFFA0F
MFP_INTERRUPT_MASK_A                    equ $FFFFFA13

; IRQ B (Timer C/D, FDC, ACIA, Centronics, Blitter & RS-232)
MFP_INTERRUPT_ENABLE_B                  equ $FFFFFA09
MFP_INTERRUPT_PENDING_B                 equ $FFFFFA0D
MFP_INTERRUPT_IN_SERVICE_B              equ $FFFFFA11
MFP_INTERRUPT_MASK_B                    equ $FFFFFA15

MFP_VECTOR_BASE                         equ $FFFFFA17

; Timers
MFP_TIMER_A_CONTROL                     equ $FFFFFA19
MFP_TIMER_B_CONTROL                     equ $FFFFFA1B
MFP_TIMER_CD_CONTROL                    equ $FFFFFA1D
MFP_TIMER_A_DATA                        equ $FFFFFA1F
MFP_TIMER_B_DATA                        equ $FFFFFA21
MFP_TIMER_C_DATA                        equ $FFFFFA23
MFP_TIMER_D_DATA                        equ $FFFFFA25
MFP_SYNC_CHAR                           equ $FFFFFA27