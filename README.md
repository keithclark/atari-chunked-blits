# Chunked Blits

This is a _test_ project to investigate the feasibility of automatically breaking HOG blits into smaller chunks, allowing large objects to be drawn without interfering with timer B ISRs.

The main use-case for this is games, where an arbitrary number of sprites need to be blitted to a buffer without blocking interrupt driven effects, such as rasters or setting the video counter mid-frame.

The target machine is an 8MHz STe, but the technique should also work on 16MHz processors.

## The problem

The fastest way to use the blitter in the STe is to run it in hog mod. hog mode gives the blitter full control of the bus, blocking the CPU from executing any instructions while data is being copied. The downside to this is, system interrupt service routines won't be processed while the blitter is working. This causes code in these handlers to be delayed until the blit is complete which, if the blit is large enough, can be many scanlines later.

The blitter can also be run in shared mode. This allows the blitter to split the load with the CPU by blitting small chunks. The problem with this mode is the number of cycles required to complete the blit is larger and interrupt handlers are still delayed (not by as much as with hog).

There are other variants of these techniques which do maintain timer stability, (blitting in ISRs, starting the interrupt a few lines early and waiting, or performing micro blits in a loop) but these all give away cycles.

This prototype attempts to mix hog and shared mode. It uses the more performant hog blits but, prior to starting the blit, the routine checks to see if an interrupt is scheduled to occur before the blit ends. If the blit won't complete, it's split into chunks to fit around the interrupt.


## The demo

You can find the demo in the `/build` folder. It doesn't check for machine type and doesn't exit cleanly because it's designed to auto-run when using my dev toolchain.

You can control the demo using the keyboard:

* <kbd>F1</kbd> / <kbd>F2</kbd> to change the raster spacing. (_Note: more rasters === more CPU time, which can cause the demo to take >1 VBL._)
* <kbd>F3</kbd> To set blitter in HOG mode
* <kbd>F4</kbd> To set blitter in SHARED mode
* <kbd>F5</kbd> To set blitter in CHUNKED mode

## Building

Source is written for VASM. Compile using:

```
vasmm68k_mot -Ftos -o "build/TEST.TOS" -x "src/main.s"
```

## Theory

1. Just before starting the blitter, we check the byte value at `FFFFFA1F` (TIMER_B_DATA) to see how many more scanlines there are until next interrupt is due. 
2. Using this value we can compute how much data we can safely blit without impacting the IRQ.
3. If we can complete the entire blit before the IRQ is due, just start the blitter in HOG mode and exit. Otherwise...
4. Set `FFFF8A38` (BLITTER_Y_COUNT) to our computed value
5. Start the blitter in HOG mode. If calculation was correct it should complete before the interrupt.
6. Wait for the interrupt to be handled
7. Repeat the process until all chunks are complete.


## Issues

1. This doesn't work properly until the first scanline. This means; if you schedule timer B for scanline 2 in your VBL, the routine will assume it only has 2 lines to work with in the top border. 
  * Could open top border? (seems like overkill though)
  * Use the video counter to figure out how far away from the target scanline we are?
2. Flickering when raster gaps are close (between 2 and 4 lines) which causes sync. (enable `ENABLE_BLIT_RASTERS equ 1` and `ENABLE_TIMER_RASTERS equ 2` to see.)
