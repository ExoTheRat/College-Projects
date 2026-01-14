;;***********************************************************
; Programming Assignment 3
; Student Name: Matthias Christensen
; UT Eid: mc79777
; Simba in the Jungle
; This is the starter code. You are given the main program
; and some declarations. The subroutines you are responsible for
; are given as empty stubs at the bottom. Follow the contract. 
; You are free to rearrange your subroutines if the need were to 
; arise.
; Note: Remember "Callee-Saves" (Cleans its own mess)

;***********************************************************

.ORIG x4000

;***********************************************************
; Main Program
;***********************************************************
    JSR   DISPLAY_JUNGLE
    LEA   R0, JUNGLE_INITIAL
    TRAP  x22 
    LDI   R0,BLOCKS
    JSR   LOAD_JUNGLE
    JSR   DISPLAY_JUNGLE
    LEA   R0, JUNGLE_LOADED
    TRAP  x22                        ; output end message
    TRAP  x25                        ; halt
JUNGLE_LOADED       .STRINGZ "\nJungle Loaded\n"
JUNGLE_INITIAL      .STRINGZ "\nJungle Initial\n"
BLOCKS          .FILL x5500

;***********************************************************
; Global constants used in program
;***********************************************************
;***********************************************************
; This is the data structure for the Jungle grid
;***********************************************************
GRID .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
                   

;***********************************************************
; this data stores the state of current position of Simba and his Home
;***********************************************************
CURRENT_ROW        .BLKW   #1       ; row position of Simba
CURRENT_COL        .BLKW   #1       ; col position of Simba 
HOME_ROW           .BLKW   #1       ; Home coordinates (row and col)
HOME_COL           .BLKW   #1

;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
; The code above is provided for you. 
; DO NOT MODIFY THE CODE ABOVE THIS LINE.
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************

;***********************************************************
; DISPLAY_JUNGLE
;   Displays the current state of the Jungle Grid 
;   This can be called initially to display the un-populated jungle
;   OR after populating it, to indicate where Simba is (*), any 
;   Hyena's(#) are, and Simba's Home (H).
; Input: None
; Output: None
; Notes: The displayed grid must have the row and column numbers
;***********************************************************
DISPLAY_JUNGLE
    ST R0, DJ_R0
    ST R1, DJ_R1
    ST R2, DJ_R2
    ST R3, DJ_R3
    ST R4, DJ_R4
    ST R5, DJ_R5
    ST R6, DJ_R6
    ST R7, DJ_R7
    
    LD R6, GRID_LENGTH
    LD R3, GRIDADDR
    LEA R5, ROWNUMS
    LEA R0, COLNUMS
    PUTS
    LD R0, NEWLINE
    PUTC
    LD R1, TOTALCOLS ; colsleft
    DJ_LOOP
        ADD R4, R1, #0
        AND R4, R4, #1
        BRnp DJ_ODD
            ADD R0, R5, #0
            PUTS
            ADD R5, R5, #3
            BR DJ_PRINTROW
        DJ_ODD
            LEA R0, INDENT
            PUTS
        DJ_PRINTROW
            ADD R0, R3, #0
            PUTS
            LD R0, NEWLINE
            PUTC
            ADD R3, R3, R6
            ADD R1, R1, #-1
            BRp DJ_LOOP
    
    LD R0, DJ_R0
    LD R1, DJ_R1
    LD R2, DJ_R2
    LD R3, DJ_R3
    LD R4, DJ_R4
    LD R5, DJ_R5
    LD R6, DJ_R6
    LD R7, DJ_R7
    JMP R7
    
TOTALCOLS .FILL #17
GRID_LENGTH .FILL #18
COLNUMS .STRINGZ "   0 1 2 3 4 5 6 7 "
INDENT      .STRINGZ "  "
NEWLINE .FILL x0A
GRIDADDR .FILL x402B
ROWNUMS .STRINGZ "0 "
        .STRINGZ "1 "       
        .STRINGZ "2 "
        .STRINGZ "3 "
        .STRINGZ "4 "
        .STRINGZ "5 "
        .STRINGZ "6 "
        .STRINGZ "7 "
DJ_R0 .BLKW #1
DJ_R1 .BLKW #1
DJ_R2 .BLKW #1
DJ_R3 .BLKW #1
DJ_R4 .BLKW #1
DJ_R5 .BLKW #1
DJ_R6 .BLKW #1
DJ_R7 .BLKW #1
;***********************************************************
; LOAD_JUNGLE
; Input:  R0  has the address of the head of a linked list of
;         gridblock records. Each record has four fields:
;       0. Address of the next gridblock in the list
;       1. row # (0-7)
;       2. col # (0-7)
;       3. Symbol (can be I->Initial,H->Home or #->Hyena)
;    The list is guaranteed to: 
;               * have only one Inital and one Home gridblock
;               * have zero or more gridboxes with Hyenas
;               * be terminated by a gridblock whose next address 
;                 field is a zero
; Output: None
;   This function loads the JUNGLE from a linked list by inserting 
;   the appropriate characters in boxes (I(*),#,H)
;   You must also change the contents of these
;   locations: 
;        1.  (CURRENT_ROW, CURRENT_COL) to hold the (row, col) 
;            numbers of Simba's Initial gridblock
;        2.  (HOME_ROW, HOME_COL) to hold the (row, col) 
;            numbers of the Home gridblock
;       
;***********************************************************
LOAD_JUNGLE 
    ST R0, LJ_R0
    ST R1, LJ_R1
    ST R2, LJ_R2
    ST R3, LJ_R3
    ST R4, LJ_R4
    ST R5, LJ_R5
    ST R6, LJ_R6
    ST R7, LJ_R7
    
    LJ_LOOP
        ADD R1, R0, #0
        BRz LJ_DONE
        
        LDR R0, R1, #0 ; next in list
        LDR R2, R1, #1 ; row
        LDR R3, R1, #2 ; col
        LDR R4, R1, #3 ; symbol
        
        ; checks if symbol is I
        LD R5, ASCII_I
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R4, R5      
        BRz IS_I
        
        ; checks if symbol is H
        LD R5, ASCII_H
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R4, R5
        BRz IS_H

        ; checks if symbol is F
        LD R5, ASCII_F
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R4, R5
        BRz LJ_UPDATE

        ; checks if symbol if #
        LD R5, ASCII_#
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R4, R5
        BRz LJ_UPDATE
        
        ; if the symbol is something random get the next one
        BR LJ_LOOP
    
    IS_I
        ST R2, CURRENT_ROW  
        ST R3, CURRENT_COL  
        LD R4, ASCII_*
        BR LJ_UPDATE
        
    IS_H
        ST R2, HOME_ROW
        ST R3, HOME_COL
        BR LJ_UPDATE

    LJ_UPDATE
        ST R0, LJ_UPDATE_R0
        ADD R1, R2, #0 ; R1 <- row
        ADD R2, R3, #0 ; R2 <- col
        JSR GRID_ADDRESS
        STR R4, R0, #0
        LD R0, LJ_UPDATE_R0
        BR LJ_LOOP

    LJ_DONE
        LD R0, LJ_R0
        LD R1, LJ_R1
        LD R2, LJ_R2
        LD R3, LJ_R3
        LD R4, LJ_R4
        LD R5, LJ_R5
        LD R6, LJ_R6
        LD R7, LJ_R7
        JMP  R7

    ASCII_I .FILL x49
    ASCII_H .FILL x48
    ASCII_F .FILL x46
    ASCII_# .FILL x23
    ASCII_* .FILL x2A
    LJ_R0 .BLKW #1
    LJ_R1 .BLKW #1
    LJ_R2 .BLKW #1
    LJ_R3 .BLKW #1
    LJ_R4 .BLKW #1
    LJ_R5 .BLKW #1
    LJ_R6 .BLKW #1
    LJ_R7 .BLKW #1
    LJ_UPDATE_R0 .BLKW #1
;***********************************************************
; GRID_ADDRESS
; Input:  R1 has the row number (0-7)
;         R2 has the column number (0-7)
; Output: R0 has the corresponding address of the space in the GRID
; Notes: This is a key routine.  It translates the (row, col) logical 
;        GRID coordinates of a gridblock to the physical address in 
;        the GRID memory.
;***********************************************************
GRID_ADDRESS     
    ST R1, GA_R1
    ST R2, GA_R2
    ST R3, GA_R3
    ST R4, GA_R4
    ST R5, GA_R5
    ST R6, GA_R6
    ST R7, GA_R7
    
    ; row memory address offset is GRIDADDR + (row * 36) + 18
    ADD R3, R1, R1  
    ADD R3, R3, R3
    ADD R4, R3, #0
    ADD R3, R3, R3
    ADD R3, R3, R3
    ADD R3, R3, R3
    ADD R3, R3, R4 
    LD R4, GRID_LENGTH
    ADD R3, R3, R4 ; R3 <- row memory address offset
    
    ; col memory address offset is row memory address + (col * 2) + 1
    ADD R4, R2, R2
    ADD R4, R4, #1 ; R4 <- col memory address offset
    
    ; final memory address is GRIDADDR + col offset + row offset
    LD R5, GRIDADDR
    ADD R0, R5, R3
    ADD R0, R0, R4 ; R0 <- final memory address
    
    LD R1, GA_R1
    LD R2, GA_R2
    LD R3, GA_R3
    LD R4, GA_R4
    LD R5, GA_R5
    LD R6, GA_R6
    LD R7, GA_R7
    JMP R7
    
    GA_R1 .BLKW #1
    GA_R2 .BLKW #1
    GA_R3 .BLKW #1
    GA_R4 .BLKW #1
    GA_R5 .BLKW #1
    GA_R6 .BLKW #1
    GA_R7 .BLKW #1
    
.END

; This section has the linked list for the
; Jungle's layout: #(0,1)->H(4,7)->I(2,1)->#(1,1)->#(6,3)->F(3,5)->F(4,4)->#(5,6)
	.ORIG	x5500
	.FILL	Head   ; Holds the address of the first record in the linked-list (Head)
blk2
	.FILL   blk4
	.FILL   #1
    .FILL   #1
	.FILL   x23

Head
	.FILL	blk1
    .FILL   #0
	.FILL   #1
	.FILL   x23

blk1
	.FILL   blk3
	.FILL   #4
	.FILL   #7
	.FILL   x48

blk3
	.FILL   blk2
	.FILL   #2
	.FILL   #1
	.FILL   x49

blk4
	.FILL   blk5
	.FILL   #6
	.FILL   #3
	.FILL   x23

blk7
	.FILL   #0
	.FILL   #5
	.FILL   #6
	.FILL   x23
blk6
	.FILL   blk7
	.FILL   #4
	.FILL   #4
	.FILL   x46
blk5
	.FILL   blk6
	.FILL   #3
	.FILL   #5
	.FILL   x46
	.END	

