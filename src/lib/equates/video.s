VIDEO_BASE_HIGH                                 equ $ffff8201
VIDEO_BASE_MIDDLE                               equ $ffff8203
VIDEO_BASE_LOW                                  equ $ffff820d ; STe

VIDEO_ADDRESS_COUNTER_HIGH                      equ $ffff8205
VIDEO_ADDRESS_COUNTER_MIDDLE                    equ $ffff8207
VIDEO_ADDRESS_COUNTER_LOW                       equ $ffff8209

VIDEO_SYNC_MODE                                 equ $ffff820a
VIDEO_LINE_WIDTH                                equ $ffff820f ; STe

VIDEO_PALETTE                                   equ $ffff8240

VIDEO_RESOLUTION                                equ $ffff8260
VIDEO_HARD_SCROLL                               equ $ffff8265 ; STe

VIDEO_RESOLUTION_LOW                            equ 0
VIDEO_RESOLUTION_MEDIUM                         equ 1
VIDEO_RESOLUTION_HIGH                           equ 2

VIDEO_SYNC_MODE_50HZ                            equ 2
VIDEO_SYNC_MODE_60HZ                            equ 0
