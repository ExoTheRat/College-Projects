;***********************************************************
; Programming Assignment 4
; Student Name: Matthias Christensen
; UT Eid: mc79777
; -------------------Save Simba (Part II)---------------------
; This is the starter code. You are given the main program
; and some declarations. The subroutines you are responsible for
; are given as empty stubs at the bottom. Follow the contract. 
; You are free to rearrange your subroutines if the need were to 
; arise.

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
HOMEBOUND
        LEA   R0, LC_OUT_STRING
        TRAP  x22
        LDI   R0,LC_LOC
        LD    R4,ASCII_OFFSET_POS
        ADD   R0, R0, R4
        TRAP  x21
        LEA   R0,PROMPT
        TRAP  x22
        TRAP  x20                        ; get a character from keyboard into R0
        TRAP  x21                        ; echo character entered
        LD    R3, ASCII_Q_COMPLEMENT     ; load the 2's complement of ASCII 'Q'
        ADD   R3, R0, R3                 ; compare the first character with 'Q'
        BRz   EXIT                       ; if input was 'Q', exit
;; call a converter to convert i,j,k,l to up(0) left(1),down(2),right(3) respectively
        JSR   IS_INPUT_VALID      
        ADD   R2, R2, #0                 ; R2 will be zero if the move was valid
        BRz   VALID_INPUT
        LEA   R0, INVALID_MOVE_STRING    ; if the input was invalid, output corresponding
        TRAP  x22                        ; message and go back to prompt
        BRnzp    HOMEBOUND
VALID_INPUT                 
        JSR   APPLY_MOVE                 ; apply the move (Input in R0)
        JSR   DISPLAY_JUNGLE
        JSR   SIMBA_STATUS      
        ADD   R2, R2, #0                 ; R2 will be zero if reached Home or -1 if Dead
        BRp  HOMEBOUND                     ; otherwise, loop back
EXIT   
        LEA   R0, GOODBYE_STRING
        TRAP  x22                        ; output a goodbye message
        TRAP  x25                        ; halt
JUNGLE_LOADED       .STRINGZ "\nJungle Loaded\n"
JUNGLE_INITIAL      .STRINGZ "\nJungle Initial\n"
ASCII_Q_COMPLEMENT  .FILL    x-71    ; two's complement of ASCII code for 'q'
ASCII_OFFSET_POS        .FILL    x30
LC_OUT_STRING    .STRINGZ "\n LIFE_COUNT is "
LC_LOC  .FILL LIFE_COUNT
PROMPT .STRINGZ "\nEnter Move up(i) \n left(j),down(k),right(l): "
INVALID_MOVE_STRING .STRINGZ "\nInvalid Input (ijkl)\n"
GOODBYE_STRING      .STRINGZ "\n!Goodbye!\n"
BLOCKS               .FILL x5500

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
LIFE_COUNT         .FILL   #1       ; Initial Life Count is One
                                    ; Count increases when Simba
                                    ; meets a Friend; decreases
                                    ; when Simba meets a Hyena
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
;   Friends (F) and Hyenas(#) are, and Simba's Home (H).
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
GRIDADDR .FILL GRID
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
;       3. Symbol (can be I->Initial,H->Home, F->Friend or #->Hyena)
;    The list is guaranteed to: 
;               * have only one Inital and one Home gridblock
;               * have zero or more gridboxes with Hyenas/Friends
;               * be terminated by a gridblock whose next address 
;                 field is a zero
; Output: None
;   This function loads the JUNGLE from a linked list by inserting 
;   the appropriate characters in boxes (I(*),#,F,H)
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

;***********************************************************
; IS_INPUT_VALID
; Input: R0 has the move (character i,j,k,l)
; Output:  R2  zero if valid; -1 if invalid
; Notes: Validates move to make sure it is one of i,j,k,l
;        Only checks if a valid character is entered
;***********************************************************

IS_INPUT_VALID
    ST R0, IIV_R0
    ST R1, IIV_R1
    ST R7, IIV_R7
    
    AND R2, R2, #0
    ADD R2, R2, #-1 ; default invalid
    
    LD R1, CHECK_I
    ADD R1, R0, R1
    BRz IIV_VALID
    LD R1, CHECK_J
    ADD R1, R0, R1
    BRz IIV_VALID
    LD R1, CHECK_K
    ADD R1, R0, R1
    BRz IIV_VALID
    LD R1, CHECK_L
    ADD R1, R0, R1
    BRz IIV_VALID
    BR IIV_DONE
    
IIV_VALID
    AND R2, R2, #0
    
IIV_DONE
    LD R0, IIV_R0
    LD R1, IIV_R1
    LD R7, IIV_R7
    JMP R7
    
    CHECK_I .FILL x-69
    CHECK_J .FILL x-6A
    CHECK_K .FILL x-6B
    CHECK_L .FILL x-6C
    IIV_R0 .BLKW #1
    IIV_R1 .BLKW #1
    IIV_R7 .BLKW #1

;***********************************************************
; CAN_MOVE
; This subroutine checks if a move can be made and returns 
; the new position where Simba would go to if the move is made. 
; To be able to make a move is to ensure that movement 
; does not take Simba off the grid; this can happen in any direction.
; In coding this routine you will need to translate a move to 
; coordinates (row and column). 
; Your APPLY_MOVE subroutine calls this subroutine to check 
; whether a move can be made before applying it to the GRID.
; Inputs: R0 - a move represented by 'i', 'j', 'k', or 'l'
; Outputs: R1, R2 - the new row and new col, respectively 
;              if the move is possible; 
;          if the move cannot be made (outside the GRID), 
;              R1 = -1 and R2 is untouched.
; Note: This subroutine does not check if the input (R0) is valid. 
;       You will implement this functionality in IS_INPUT_VALID. 
;       Also, this routine does not make any updates to the GRID 
;       or Simba's position, as that is the job of the APPLY_MOVE function.
;***********************************************************

CAN_MOVE      
    ST R0, CM_R0
    ST R2, CM_R2
    ST R3, CM_R3
    ST R4, CM_R4
    ST R7, CM_R7
    
    LDI R1, CURRENT_ROW_ADDR
    LDI R2, CURRENT_COL_ADDR
    
    LD R3, CHECK_I2
    ADD R3, R0, R3
    BRz CM_MOVE_UP
    
    LD R3, CHECK_J2
    ADD R3, R0, R3
    BRz CM_MOVE_LEFT
    
    LD R3, CHECK_K2
    ADD R3, R0, R3
    BRz CM_MOVE_DOWN
    
    LD R3, CHECK_L2
    ADD R3, R0, R3
    BRz CM_MOVE_RIGHT
    
    BR CM_DONE 
    
CM_MOVE_UP
    ADD R1, R1, #-1
    BR CM_CHECK_BOUNDS
CM_MOVE_LEFT
    ADD R2, R2, #-1
    BR CM_CHECK_BOUNDS
CM_MOVE_DOWN
    ADD R1, R1, #1
    BR CM_CHECK_BOUNDS
CM_MOVE_RIGHT
    ADD R2, R2, #1
    BR CM_CHECK_BOUNDS
    
CM_CHECK_BOUNDS
    ADD R3, R1, #0
    BRn CM_INVALID ; row > 0
    LD R4, BOUNDS_CHECK
    ADD R3, R1, R4
    BRzp CM_INVALID ; row <= 8
    
    ADD R3, R2, #0
    BRn CM_INVALID ; col > 0
    LD R4, BOUNDS_CHECK
    ADD R3, R2, R4
    BRzp CM_INVALID ; col <= 8
    BR CM_DONE
    
CM_INVALID
    AND R1, R1, #0
    ADD R1, R1, #-1
    LD R2, CM_R2
    
CM_DONE
    LD R0, CM_R0
    LD R3, CM_R3
    LD R4, CM_R4
    LD R7, CM_R7
    JMP R7
    
    CURRENT_ROW_ADDR .FILL CURRENT_ROW
    CURRENT_COL_ADDR .FILL CURRENT_COL
    BOUNDS_CHECK .FILL #-8
    CM_R0 .BLKW #1
    CM_R2 .BLKW #1
    CM_R3 .BLKW #1
    CM_R4 .BLKW #1
    CM_R7 .BLKW #1
    CHECK_I2 .FILL x-69
    CHECK_J2 .FILL x-6A
    CHECK_K2 .FILL x-6B
    CHECK_L2 .FILL x-6C

;***********************************************************
; APPLY_MOVE
; This subroutine makes the move if it can be completed. 
; It checks to see if the movement is possible by calling 
; CAN_MOVE which returns the coordinates of where the move 
; takes Simba (or -1 if movement is not possible as detailed above). 
; If the move is possible then this routine moves Simba
; symbol (*) to the new coordinates and clears any walls (|'s and -'s) 
; as necessary for the movement to take place. 
; In addition,
;   If the movement is off the grid - Output "Cannot Move" to Console
;   If the move is to a Friend's location then you increment the
;     LIFE_COUNT variable; 
;   If the move is to a Hyena's location then you decrement the
;     LIFE_COUNT variable; IF this decrement causes LIFE_COUNT
;     to become Zero then Simba's Symbol changes to X (dead)
; Input:  
;         R0 has move (i or j or k or l)
; Output: None; However yous must update the GRID and 
;               change CURRENT_ROW and CURRENT_COL 
;               if move can be successfully applied.
;               appropriate messages are output to the console 
; Notes:  Calls CAN_MOVE and GRID_ADDRESS
;***********************************************************

APPLY_MOVE   
    ST R0, AM_R0
    ST R1, AM_R1
    ST R2, AM_R2
    ST R3, AM_R3
    ST R4, AM_R4
    ST R5, AM_R5
    ST R6, AM_R6
    ST R7, AM_R7
    
    JSR CAN_MOVE
    ADD R1, R1, #0
    BRn AM_INVALID_MOVE
    
    ST R1, AM_NEW_ROW
    ST R2, AM_NEW_COL
    LD R0, AM_R0
    ST R0, AM_MOVE
    LDI R1, CURRENT_ROW_ADDR
    LDI R2, CURRENT_COL_ADDR
    ST R1, AM_OLD_ROW
    ST R2, AM_OLD_COL
    
    JSR GRID_ADDRESS
    LD R3, EMPTY_CHAR
    STR R3, R0, #0
    
    LD R0, AM_MOVE
    LD R3, CHECK_I3
    ADD R3, R0, R3
    BRz AM_CLEAR_WALL_I ; check i
    LD R3, CHECK_J3
    ADD R3, R0, R3
    BRz AM_CLEAR_WALL_J ; check j
    LD R3, CHECK_K3
    ADD R3, R0, R3
    BRz AM_CLEAR_WALL_K ; check k
    
    
    LD R1, AM_OLD_ROW ; else l
    LD R2, AM_NEW_COL
    JSR GET_VERTICAL_WALL
    LD R3, EMPTY_CHAR
    STR R3, R0, #0
    BR AM_CHECK_SQUARE
    
AM_CLEAR_WALL_I
    LD R1, AM_OLD_ROW
    LD R2, AM_OLD_COL
    JSR GET_HORIZONTAL_WALL
    LD R3, EMPTY_CHAR
    STR R3, R0, #0
    BR AM_CHECK_SQUARE
    
AM_CLEAR_WALL_J
    LD R1, AM_OLD_ROW
    LD R2, AM_OLD_COL
    JSR GET_VERTICAL_WALL
    LD R3, EMPTY_CHAR
    STR R3, R0, #0
    BR AM_CHECK_SQUARE
    
AM_CLEAR_WALL_K
    LD R1, AM_NEW_ROW
    LD R2, AM_NEW_COL
    JSR GET_HORIZONTAL_WALL
    LD R3, EMPTY_CHAR
    STR R3, R0, #0

AM_CHECK_SQUARE
    LD R1, AM_NEW_ROW
    LD R2, AM_NEW_COL
    JSR GRID_ADDRESS
    LDR R3, R0, #0
    
    LD R4, CHECK_F
    ADD R4, R3, R4
    BRz AM_IS_FRIEND
    LD R4, CHECK_#
    ADD R4, R3, R4
    BRz AM_IS_HYENA
    
    BR AM_UPDATE_SIMBA
    
    AM_IS_FRIEND
    LDI R4, LIFE_COUNT_ADDR
    ADD R4, R4, #1
    STI R4, LIFE_COUNT_ADDR
    BR AM_UPDATE_SIMBA
    
AM_IS_HYENA
    LDI R4, LIFE_COUNT_ADDR
    ADD R4, R4, #-1
    STI R4, LIFE_COUNT_ADDR
    
AM_UPDATE_SIMBA
    LD R1, AM_NEW_ROW
    STI R1, CURRENT_ROW_ADDR
    LD R1, AM_NEW_COL
    STI R1, CURRENT_COL_ADDR
    
    LD R3, ASCII_SIMBA
    LDI R4, LIFE_COUNT_ADDR
    ADD R4, R4, #0
    BRp AM_PLACE_SYMBOL
    LD R3, ASCII_X
    
AM_PLACE_SYMBOL
    LD R1, AM_NEW_ROW
    LD R2, AM_NEW_COL
    JSR GRID_ADDRESS
    STR R3, R0, #0
    BR AM_DONE
    
AM_INVALID_MOVE
    LEA R0, CANNOT_MOVE_MSG
    PUTS
    
AM_DONE
    LD R0, AM_R0
    LD R1, AM_R1
    LD R2, AM_R2
    LD R3, AM_R3
    LD R4, AM_R4
    LD R5, AM_R5
    LD R6, AM_R6
    LD R7, AM_R7
    JMP R7
    
    CHECK_I3 .FILL x-69
    CHECK_J3 .FILL x-6A
    CHECK_K3 .FILL x-6B
    CHECK_L3 .FILL x-6C
    AM_R0 .BLKW #1
    AM_R1 .BLKW #1
    AM_R2 .BLKW #1
    AM_R3 .BLKW #1
    AM_R4 .BLKW #1
    AM_R5 .BLKW #1
    AM_R6 .BLKW #1
    AM_R7 .BLKW #1
    AM_MOVE .BLKW #1
    AM_NEW_ROW .BLKW #1
    AM_NEW_COL .BLKW #1
    AM_OLD_ROW .BLKW #1
    AM_OLD_COL .BLKW #1
    CANNOT_MOVE_MSG .STRINGZ "\nCannot Move\n"
    EMPTY_CHAR .FILL x20
    ASCII_SIMBA .FILL x2A
    ASCII_X .FILL x58
    CHECK_F .FILL x-46 
    CHECK_# .FILL x-23
    
GET_HORIZONTAL_WALL
    ST R1, GHW_R1
    ST R2, GHW_R2
    ST R3, GHW_R3
    ST R4, GHW_R4
    
    ADD R3, R1, R1 
    ADD R3, R3, R3
    ADD R4, R3, #0
    ADD R3, R3, R3
    ADD R3, R3, R3
    ADD R3, R3, R3
    ADD R3, R3, R4
    ADD R4, R2, R2
    ADD R4, R4, #1
    
    LD R0, GRID_ADDR
    ADD R0, R0, R3
    ADD R0, R0, R4
    
    LD R1, GHW_R1
    LD R2, GHW_R2
    LD R3, GHW_R3
    LD R4, GHW_R4
    JMP R7
    
    GHW_R1 .BLKW #1
    GHW_R2 .BLKW #1
    GHW_R3 .BLKW #1
    GHW_R4 .BLKW #1
    
    GET_VERTICAL_WALL
    ST R1, GVM_R1
    ST R2, GVM_R2
    ST R3, GVM_R3
    ST R4, GVM_R4
    
    ADD R3, R1, R1
    ADD R3, R3, R3
    ADD R4, R3, #0
    ADD R3, R3, R3
    ADD R3, R3, R3 
    ADD R3, R3, R3
    ADD R3, R3, R4 
    ADD R4, R2, R2 
    
    LD R0, GRID_ADDR
    ADD R0, R0, R3
    LD R3, GRIDLENGTH
    ADD R0, R0, R3
    ADD R0, R0, R4
    
    LD R1, GVM_R1
    LD R2, GVM_R2
    LD R3, GVM_R3
    LD R4, GVM_R4
    JMP R7
    
    GVM_R1 .BLKW #1
    GVM_R2 .BLKW #1
    GVM_R3 .BLKW #1
    GVM_R4 .BLKW #1
    GRID_ADDR .FILL GRID
    GRIDLENGTH .FILL #18

;***********************************************************
; SIMBA_STATUS
; Checks to see if the Simba has reached Home; Dead or still
; Alive
; Input:  None
; Output: R2 is ZERO if Simba is Home; Also Output "Simba is Home"
;         R2 is +1 if Simba is Alive but not home yet
;         R2 is -1 if Simba is Dead (i.e., LIFE_COUNT =0); Also Output"Simba is Dead"
; 
;***********************************************************

SIMBA_STATUS    
    ST R0, SS_R0
    ST R1, SS_R1
    ST R7, SS_R7
    
    LDI R0, LIFE_COUNT_ADDR ; check if alive
    ADD R0, R0, #0
    BRp SS_ALIVE
    
    LEA R0, DEAD_MSG ; else dead
    PUTS
    AND R2, R2, #0
    ADD R2, R2, #-1     ; R2 = -1
    BR SS_DONE
    
SS_ALIVE
    LDI R0, CURRENT_ROW_ADDR ; check if current row = home row
    LDI R1, HOME_ROW_ADDR
    NOT R1, R1
    ADD R1, R1, #1
    ADD R0, R0, R1
    BRnp SS_NOT_HOME
    
    LDI R0, CURRENT_COL_ADDR ; check if current col = home col
    LDI R1, HOME_COL_ADDR
    NOT R1, R1
    ADD R1, R1, #1
    ADD R0, R0, R1
    BRnp SS_NOT_HOME

    LEA R0, HOME_MSG ; Home
    PUTS
    AND R2, R2, #0
    BR SS_DONE
    
SS_NOT_HOME
    AND R2, R2, #0
    ADD R2, R2, #1
    
SS_DONE
    LD R0, SS_R0
    LD R1, SS_R1
    LD R7, SS_R7
    JMP R7
    
    HOME_ROW_ADDR .FILL HOME_ROW
    HOME_COL_ADDR .FILL HOME_COL
    LIFE_COUNT_ADDR .FILL LIFE_COUNT
    DEAD_MSG .STRINGZ "\nSimba is Dead\n"
    HOME_MSG .STRINGZ "\nSimba is Home\n"
    SS_R0 .BLKW #1
    SS_R1 .BLKW #1
    SS_R7 .BLKW #1
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
