; Program5.asm
; Name(s): Matthias Christensen
; UTEid(s): mc79777
; Continuously reads from x3500 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.
.ORIG x3000
; set up the keyboard interrupt vector table entry
;M[x0180] <- x2500
    LD R6, StackAddr
    JSR Setup
    MainLoop
        JSR GetInput
        JSR Process
        ADD R1, R1, #0
        BRp Done
        BR MainLoop
        
    Done
        HALT
    StackAddr .FILL x3000
; enable keyboard interrupts
; KBSR[14] <- 1 ==== M[xFE00] = x4000
Setup
    LD R0, KBISR
    LD R1, KBINTVec
    STR R0, R1, #0 ; store ISR address into M[KBINTVec]
    LDI R0, KBSR
    LD R1, KBINTEN
    NOT R0, R0 ; OR the two together to change the bits
    NOT R1, R1          
    AND R0, R0, R1      
    NOT R0, R0
    STI R0, KBSR ; store back to KBSR\
    RET


; This loop is the proper way to read an input
GetInput
    ST R7, GetInput_R7
    GetInputLoop
        LDI R0,GLOB
        BRz GetInputLoop    
        PUTC
        AND R1, R1, #0
        STI R1, GLOB
        LD R7, GetInput_R7
        RET
        
    GetInput_R7 .BLKW #1
; Process it
Process 
    ST R0, Process_R0
    ST R2, Process_R2
    ST R3, Process_R3
    ST R7, Process_R7
    LD R2, STATE
    
    AND R1, R1, #0 ; 0 is default
    ADD R3, R2, #-3 ; check if start has already been found
    BRzp CheckStop
    ADD R2, R2, #0 ; waiting for A
    BRz State0_Check
    ADD R2, R2, #-1 ; waiting for U (A seen)
    BRz State1_Check
    ADD R2, R2, #-1
    BRz State2_Check ; waiting for G (AU seen)
    BR EndProcess
    
    State0_Check
        LD R3, CHECK_A
        ADD R3, R0, R3
        BRnp ResetState ; if not A, reset
        AND R2, R2, #0
        ADD R2, R2, #1 ; go to state 1
        ST R2, STATE
        BR EndProcess
    
    State1_Check
        LD R3, CHECK_U
        ADD R3, R0, R3
        BRnp RecheckA ; if not U, might be A
        AND R2, R2, #0
        ADD R2, R2, #2 ; go to state 2
        ST R2, STATE
        BR EndProcess
        
        RecheckA
            LD R3, CHECK_A
            ADD R3, R0, R3
            BRz EndProcess ; stay in state 1
            BR ResetState
    
    State2_Check
        LD R3, CHECK_G
        ADD R3, R0, R3
        BRnp CheckAOrReset ; if not G, check if A or reset
        LD R0, PIPE ; found AUG
        PUTC
        AND R2, R2, #0
        ADD R2, R2, #3 ; go to state 3
        ST R2, STATE
        BR EndProcess
        
        CheckAOrReset
            LD R3, CHECK_A
            ADD R3, R0, R3
            BRz BackToState1
            BR ResetState

        BackToState1
            AND R2, R2, #0
            ADD R2, R2, #1
            ST R2, STATE
            BR EndProcess
        
    ResetState
        AND R2, R2, #0
        ST R2, STATE
        BR EndProcess
    
    CheckStop ; for states 3, 4, 5, 6
        ADD R3, R2, #-3
        BRz StopState3
        ADD R3, R2, #-4
        BRz StopState4
        ADD R3, R2, #-5
        BRz StopState5
        ADD R3, R2, #-6
        BRz StopState6
        BR EndProcess
        
    StopState3 ; waiting for U
        LD R3, CHECK_U
        ADD R3, R0, R3
        BRnp EndProcess ; stay in state 3
        ADD R2, R2, #1  ; go to state 4
        ST R2, STATE
        BR EndProcess
        
    StopState4 ; U seen, waiting for A or G
        LD R3, CHECK_A
        ADD R3, R0, R3
        BRz UAFound
        LD R3, CHECK_G
        ADD R3, R0, R3
        BRz UGFound
        LD R3, CHECK_U ; checking if U again to stay in state 4
        ADD R3, R0, R3
        BRz EndProcess 
        AND R2, R2, #0 ; otherwise return to state 3
        ADD R2, R2, #3
        ST R2, STATE
        BR EndProcess
        
        UAFound
            AND R2, R2, #0
            ADD R2, R2, #5 ; go to state 5
            ST R2, STATE
            BR EndProcess
        UGFound
            AND R2, R2, #0
            ADD R2, R2, #6 ; go to state 6
            ST R2, STATE
            BR EndProcess
            
    StopState5 ; UA seen, waiting for A or G
        LD R3, CHECK_A
        ADD R3, R0, R3
        BRz ProcessDone ; UAA seen 
        LD R3, CHECK_G
        ADD R3, R0, R3
        BRz ProcessDone ; UAG seen
        LD R3, CHECK_U ; if U return to state 4
        ADD R3, R0, R3
        BRz ReturnState4
        AND R2, R2, #0
        ADD R2, R2, #3 ; otherwise go to state 3
        ST R2, STATE
        BR EndProcess
        
        ReturnState4
            AND R2, R2, #0
            ADD R2, R2, #4
            ST R2, STATE
            BR EndProcess
            
    StopState6 ; UG seen, waiting for A
        LD R3, CHECK_A
        ADD R3, R0, R3
        BRz ProcessDone ; UGA seen
        LD R3, CHECK_U ; if U return to state 4
        ADD R3, R0, R3
        BRz ReturnState4
        AND R2, R2, #0
        ADD R2, R2, #3 ; otherwise go to state 3
        ST R2, STATE
        BR EndProcess
        
    ProcessDone
        ADD R1, R1, #1 ; main will halt
        BR EndProcess
    
    EndProcess
        LD R0, Process_R0
        LD R2, Process_R2
        LD R3, Process_R3
        LD R7, Process_R7
        RET
    

; Repeat until Stop Codon detected
    HALT
    STATE   .FILL #0
    CHECK_A  .FILL #-65
    CHECK_G  .FILL #-71
    CHECK_U  .FILL #-85
    PIPE    .FILL x7C
    Process_R0 .BLKW #1
    Process_R2 .BLKW #1
    Process_R3 .BLKW #1
    Process_R7 .BLKW #1
    KBINTVec    .FILL x0180
    KBSR        .FILL xFE00
    KBISR       .FILL x2500
    KBINTEN     .FILL x4000
    GLOB        .FILL x3500
.END

; Interrupt Service Routine
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x3500
.ORIG x2500
    ST R0, SaveR0
    ST R1, SaveR1
    LDI R0, KBDR
    
    LD R1, CheckA ; check if input is A
    ADD R1, R0, R1
    BRz ValidInput
    
    LD R1, CheckC ; check if input is C
    ADD R1, R0, R1
    BRz ValidInput

    LD R1, CheckG ; check if input is G
    ADD R1, R0, R1
    BRz ValidInput

    LD R1, CheckU ; check if input is U
    ADD R1, R0, R1
    BRz ValidInput
    BR DoneISR ; if not skip to end
    
    ValidInput
        STI R0, IGLOB ; store input to x3500
    
    DoneISR
        LD R0, SaveR0
        LD R1, SaveR1
        RTI
        
    KBDR        .FILL xFE02
    IGLOB       .FILL x3500
    SaveR0      .BLKW #1
    SaveR1      .BLKW #1
    CheckA      .FILL #-65
    CheckC      .FILL #-67
    CheckG      .FILL #-71
    CheckU      .FILL #-85
.END
