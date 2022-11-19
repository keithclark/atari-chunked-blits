; ------------------------------------------------------------------------------
; This demo does a lot of blitting. `MIN_TIMER_VALUE` is set to a value that 
; prevents crashes because there are too many timer B ISRs run to fit into a VBL
; ------------------------------------------------------------------------------

DEFAULT_TIMER_VALUE     equ 8   ; Number of scanlines between timer events 
DEFAULT_BLIT_MODE       equ 2   ; Toggle chunked blits (for debugging/perf tests)
                                ; (0=hog, 1=shared, 2=chunked)
ENABLE_BLIT_RASTERS     equ 0   ; Show rasters when the blitter is active
ENABLE_TIMER_RASTERS    equ 1   ; The timer B raster style (ISR always runs)
                                ; (0=off, 1=solid, 2=markers)
MIN_TIMER_VALUE         equ 1   ; Minimum value for TIMER_B_DATA (raster spacing)
SPRITE_COUNT            equ 2   ; Number of sprites to show

; ------------------------------------------------------------------------------

    include   "lib/equates/blitter.s";
    include   "lib/equates/interrupts.s";
    include   "lib/equates/video.s";
    include   "lib/equates/acia.s";
    
    pea       startup                   ; Run in supervisor
    move.w    #$26,-(sp)                ; supexec()
    trap      #14
    addq.l    #6,sp


; ------------------------------------------------------------------------------
; loop
; ------------------------------------------------------------------------------
; The main loop.
; ------------------------------------------------------------------------------
startup:
    move.w    #$2700,sr
    clr.b     MFP_INTERRUPT_ENABLE_A.w
    clr.b     MFP_INTERRUPT_ENABLE_B.w
    ori.b     #1,MFP_INTERRUPT_ENABLE_A.w ; enable timer B
    ori.b     #1,MFP_INTERRUPT_MASK_A.w
    bclr      #3,MFP_VECTOR_BASE.w      ; auto end of interupt
    move.l    #vbl,MFP_VBL_VECTOR.w
    move.w    #$2300,sr



; ------------------------------------------------------------------------------
; loop
; ------------------------------------------------------------------------------
; The main loop.
; ------------------------------------------------------------------------------
loop:
    bsr       swap_buffers
    bsr       wait_vbl
    bsr       check_input

    move.l    back_buffer_addr,a0
    lea       sintab,a1

    ; clear the screen using the blitter
    move.l    #sprite,BLITTER_SOURCE_ADDRESS.w
    move.l    a0,BLITTER_DESTINATION_ADDRESS.w
    move.w    #0,BLITTER_SOURCE_X_BYTE_INC.w
    move.w    #0,BLITTER_SOURCE_Y_BYTE_INC.w
    move.w    #2,BLITTER_DESTINATION_X_BYTE_INC.w
    move.w    #0,BLITTER_DESTINATION_Y_BYTE_INC.w
    move.w    #(80/8)+1,BLITTER_X_COUNT.w
    move.w    #200*8,BLITTER_Y_COUNT.w
    move.b    #2,BLITTER_HOP.w
    move.b    #0,BLITTER_LOP.w
    move.b    #0,BLITTER_SKEW.w
    bsr       blit

    ; configure the blitter for the sprite
    move.w    #2,BLITTER_SOURCE_X_BYTE_INC.w
    move.w    #0,BLITTER_SOURCE_Y_BYTE_INC.w
    move.w    #8,BLITTER_DESTINATION_X_BYTE_INC.w
    move.w    #80+16,BLITTER_DESTINATION_Y_BYTE_INC.w
    move.w    #(128/16)+1,BLITTER_X_COUNT.w
    move.b    #3,BLITTER_LOP.w

    ; Blit some test sprites
sin_offset SET 0
    REPT SPRITE_COUNT
sin_offset SET sin_offset+8
    move.w    vbl_tick,d2               ; use vbl counter
    add.w     #sin_offset,d2            ; offset sin wave
    and.w     #63,d2                    ; clamp to 0-63
    add.w     d2,d2                     ; double to get word offset
    move.w    0(a1,d2.w),d2             ; look up value
    mulu      #160,d2                   ; convert to screen offset

    ; blit plane 1
    move.l    #sprite,BLITTER_SOURCE_ADDRESS.w
    move.l    a0,BLITTER_DESTINATION_ADDRESS.w
    add.l     d2,BLITTER_DESTINATION_ADDRESS.w
    move.w    #103,BLITTER_Y_COUNT.w
    bsr       blit

    ; blit plane 2
    addq.l    #2,a0
    move.l    #sprite+(16*104),BLITTER_SOURCE_ADDRESS.w
    move.l    a0,BLITTER_DESTINATION_ADDRESS.w
    add.l     d2,BLITTER_DESTINATION_ADDRESS.w
    move.w    #103,BLITTER_Y_COUNT.w
    bsr       blit

    add.l      #42,a0                   ; move for next tree

    ENDR


    move.w    VIDEO_PALETTE.w,d0
    move.w    #$fff,VIDEO_PALETTE.w
    REPT      80
    nop
    ENDR
    move.w    d0,VIDEO_PALETTE.w

    bra       loop


; ------------------------------------------------------------------------------
; swap_buffers
; ------------------------------------------------------------------------------
; Switched the front/back buffer pointers
; ------------------------------------------------------------------------------
swap_buffers:
    move.l    front_buffer_addr,d0
    move.l    back_buffer_addr,front_buffer_addr
    move.l    d0,back_buffer_addr
    rts


; ------------------------------------------------------------------------------
; wait_vbl
; ------------------------------------------------------------------------------
; Syncs code to the vertical blanking signal
; ------------------------------------------------------------------------------
wait_vbl:
    tst.b     vbl_flag
    beq       wait_vbl
    sf        vbl_flag
    rts


; ------------------------------------------------------------------------------
; check_input
; ------------------------------------------------------------------------------
; Checks for user interaction from keyboard input
; ------------------------------------------------------------------------------
check_input:
    btst      #0,KEYBOARD_CONTROL.w
    beq       .done
    move.b    KEYBOARD_DATA.w,d0
    cmp.b     #SCANCODE_F1,d0
    beq       .timer_count_inc
    cmp.b     #SCANCODE_F2,d0
    beq       .timer_count_dec
    cmp.b     #SCANCODE_F3,d0
    beq       .set_blit_mode_hog
    cmp.b     #SCANCODE_F4,d0
    beq       .set_blit_mode_shared
    cmp.b     #SCANCODE_F5,d0
    beq       .set_blit_mode_chunked
 .done:
    rts

.timer_count_inc:
    cmp.b     #199,timer_count
    beq       .done
    add.b     #1,timer_count
    rts

.timer_count_dec:
    cmp.b     #MIN_TIMER_VALUE,timer_count
    beq       .done
    sub.b     #1,timer_count
    rts

.set_blit_mode_hog:
    move.b    #0,blit_mode
    rts

.set_blit_mode_shared:
    move.b    #1,blit_mode
    rts

.set_blit_mode_chunked:
    move.b    #2,blit_mode
    rts

; ------------------------------------------------------------------------------
; vbl
; ------------------------------------------------------------------------------
; The VBL vector for the demo. Resets the palette and schedules Timer B.
; ------------------------------------------------------------------------------
vbl:
    movem.l   a0/d0,-(sp)
    st        vbl_flag
    lea       VIDEO_ADDRESS_COUNTER_HIGH.w,a0
    move.l    front_buffer_addr,d0
    movep.l   d0,-2(a0)

    addq.w    #1,vbl_tick
    clr.w     VIDEO_PALETTE.w
    clr.b     MFP_TIMER_B_CONTROL.w
    clr.w     raster_color

    move.l    #timerb,MFP_TIMER_B_VECTOR.w
    move.b    timer_count,MFP_TIMER_B_DATA.w
    move.b    #8,MFP_TIMER_B_CONTROL.w
    movem.l   (sp)+,a0/d0
    rte


; ------------------------------------------------------------------------------
; timerb
; ------------------------------------------------------------------------------
; The timer B vector. Changes the palette.
; ------------------------------------------------------------------------------
timerb:
    IF ENABLE_TIMER_RASTERS=1
    move.w    raster_color,VIDEO_PALETTE.W
    add.w     #$012,raster_color
    ENDIF

    IF ENABLE_TIMER_RASTERS=2
    eor.w    #$fff,VIDEO_PALETTE.W
    REPT 20
    nop
    ENDR
    eor.w    #$fff,VIDEO_PALETTE.W
    ENDIF
    rte


    include   "chunked_blit.s"

    section data
vbl_flag:
    dc.b      0
timer_count:
    dc.b      DEFAULT_TIMER_VALUE
blit_mode:
    dc.b      DEFAULT_BLIT_MODE

    even
raster_color:
    dc.w      0
vbl_tick
    dc.w      0
front_buffer_addr:
    dc.l      front_buffer
back_buffer_addr:
    dc.l      back_buffer
sintab:
    dc.w      $0031,$0035,$003a,$003f,$0043,$0047,$004b,$004f
    dc.w      $0053,$0056,$0059,$005b,$005d,$005f,$0060,$0061
    dc.w      $0061,$0061,$0060,$005f,$005d,$005b,$0059,$0056
    dc.w      $0053,$004f,$004b,$0047,$0043,$003f,$003a,$0035
    dc.w      $0031,$002c,$0027,$0022,$001e,$001a,$0016,$0012
    dc.w      $000e,$000b,$0008,$0006,$0004,$0002,$0001,$0000
    dc.w      $0000,$0000,$0001,$0002,$0004,$0006,$0008,$000b
    dc.w      $000e,$0012,$0016,$001a,$001e,$0022,$0027,$002c
    even
sprite:
    incbin    "../gfx/tree.dat"


    section bss
back_buffer:
    ds.b      32000
front_buffer:
    ds.b      32000