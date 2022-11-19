; ------------------------------------------------------------------------------
; blit_raster (MACRO)
; ------------------------------------------------------------------------------
; Toggle the debugging raster on/off
; ------------------------------------------------------------------------------
blit_raster MACRO
    IF ENABLE_BLIT_RASTERS=1
    eor.w     #$400,VIDEO_PALETTE.w
    ENDIF
    ENDM


; ------------------------------------------------------------------------------
; blit
; ------------------------------------------------------------------------------
; Starts the blitter using the currently configured mode
; ------------------------------------------------------------------------------
blit:
    cmp.b     #1,blit_mode
    beq       blit_shared
    cmp.b     #2,blit_mode
    beq       blit_chunked
    bra       blit_hog


; ------------------------------------------------------------------------------
; blit_hog
; ------------------------------------------------------------------------------
; Starts the blitter in HOG mode
; ------------------------------------------------------------------------------
blit_hog:
    blit_raster
    move.b    #$C0,BLITTER_CONTROL.w    ; HOG mode
    blit_raster
    rts


; ------------------------------------------------------------------------------
; blit_shared
; ------------------------------------------------------------------------------
; Starts the blitter in SHARED mode, polling the busy bit for speed.
; ------------------------------------------------------------------------------
blit_shared:
    blit_raster
    move.b    #$80,BLITTER_CONTROL.w    ; SHARED mode
.restart:
    bset.b    #7,BLITTER_CONTROL.w      ; Restart BLiTTER and test the BUSY
    nop                                 ; flag state.  The "nop" is executed
    bne       .restart                  ; prior to the BLiTTER restarting.
    blit_raster
   rts


; ------------------------------------------------------------------------------
; chunked_blit
; ------------------------------------------------------------------------------
; Starts the blitter in HOG mode ensuring that blits don't block timer B.
; 
; NOTE: This is a proof of concept. It won't work outside this demo in its 
; current state.
;
; -[TODO]-----------------------------------------------------------------------
; * Account for timer B being configured in the VBL vector but not counting down
;   because we're not at scanline 1 yet. This causes the routine to break blits
;   into chunks when it's not needed.
; ------------------------------------------------------------------------------
blit_chunked:
    movem.l   d0-d2/a0-a1,-(sp)
    moveq     #0,d0

    ; Read the number of scanlines until timer B hits zero and the next ISR is
    ; executed.
    lea       MFP_TIMER_B_DATA.w,a0
    lea       BLITTER_Y_COUNT.w,a1

    ; Grab the configured blitter Y_COUNT value so we can keep track of how many
    ; Y copies remain once we start breaking blits into chunks.
    move.w    (a1),d1

.next:
    ; Is there one scanline until the next interrupt? If so we need to stop and
    ; wait for the interrupt to be handled before starting the blit. Waiting for
    ; zero won't work because the ISR will have kicked-in already and the new 
    ; timer B data value will have been set.
    cmp.b     #1,(a0)
    bgt.s     .no_wait
    stop      #$2100                    ; wait for HBL to finish

    ; Figure out how many Y counts we can blit in the remaining time. Lots of
    ; variations to consider here. X_COUNT, NFSR, FXSR, LOP/HOP all result in a
    ; different number of cycles. Might be best to make the caller responsible
    ; for passing this in via a register?
.no_wait:
    move.w    d1,d2                     ; keep a copy of d1 for the last blit
    move.b    (a0),d0                   ; d0 = number of lines until next interrupt

    ; This isn't inacurate but, for testing, assume we can safely copy 4 Y_COUNT
    ; steps per scanline.
    add.w     d0,d0
    add.w     d0,d0

    sub.w     d0,d1                     ; decrease remaining Y count
    ble.s     .blit_end                 ; if <= 0 remain, blit last chunk and exit
    move.w    d0,(a1)                   ; add our chunk size to Y_COUNT
    blit_raster
    move.b    #$C0,BLITTER_CONTROL.w      ; HOG mode
    blit_raster

    bra       .next                     ; next chunk


.blit_end
    move.w    d2,(a1)
    blit_raster
    move.b    #$C0,BLITTER_CONTROL.w      ; HOG mode
    blit_raster
    movem.l   (sp)+,d0-d2/a0-a1
    rts
