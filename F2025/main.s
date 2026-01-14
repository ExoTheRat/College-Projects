/* 
ARM Development Programming Assignment - EE306H
Student Name: Matthias Christensen
Student UTEID: mc79777
Task1:	Convert a given fully-parenthesized Infix expression 
	    to Postfix
Task2:	Evaluate the expression for specific values of the variables
Assume:	The infix expression is a string with variables that 
        are single lower-case alphabets [a-z]. operators allowed 
		are +,-,* and / 
		Variable values are stored in a value table - VTab
			an array of records where each record has two 
			attributes: symbol and value symbol is:
			one Character (8-bit) and Value
							          a signed 32-bit number. 
*/
	.syntax unified
	.data
// These are the outcomes of your two tasks
Result:		.space 4  // This is the final evaluated result
PostFix:	.space 20 // Here goes the postfix expression
	.text
	.global main
// These are the inputs to your two tasks
InFix:	.string "(x+x)" // The InFix expression
					// PostFix: abcd-f/ *+ for this case
                    //                 ^no blank
	.align 2
// A Value Table of values for the variables
VTab:	.byte 'x'
		.align 2  
		.long 0x08000000
		.byte 0		// Expression result is 5 for this case 
	.align 2
main:	
    push {lr}
	bl Task1	// Should check R0 after Task1 is done 
				// to see if it was a success or failure
	bl Task2
	pop {pc}

/* ++++++++++++++++++Task 1 subroutine ++++++++++ */
/*
		Algorithm: Convert Infix to Postfix

		(1) Read next character cc from Infix
    		a. If cc is \0, goto Step 3
    		b. If cc is '(' (left-brace), push cc on Stack
    		c. If cc is an operator, push cc on Stack
    		d. If cc is a variable, write it to Postfix
    		e. If cc is a ')' (right-brace)
       			- Pop from Stack write to Postfix
         		  until a left brace (Note: do not print brace)

		(2) Goto Step 1

		(3) Write NULL (\0) to Postfix — Done

	Output: R0 has 1 for success; 0 for failure
*/

Task1:
	push {r4-r6, lr}
	// Solution goes here
	mov r6, sp // copy of stack pointer
	ldr r4, =InFix // r4 = pointer to infix
	ldr r5, =PostFix // r5 = pointer to postfix
	Task1_Loop:
		ldrb r2, [r4] // load byte and increment
		adds r4, #1
		cmp r2, #0
		beq Task1_Done // if null then done
		cmp r2, #'('
		beq Task1_Push // if ( then push to stack
		cmp r2, #')'
		beq Task1_ClosedParenthesis // if ) then pop from stack write to Postfix
		// now check for operators
		cmp r2, #'+'
		beq Task1_Push
		cmp r2, #'-'
        beq Task1_Push
		cmp r2, #'*'
        beq Task1_Push
		cmp r2, #'/'
        beq Task1_Push
		// if none then it is a variable so write to Postfix
		strb r2, [r5] // store to Postfix and increment
		adds r5, #1
		b Task1_Loop

	Task1_Push:
		push {r2}
		b Task1_Loop

	Task1_ClosedParenthesis:
		Pop_Loop:
			cmp sp, r6
			beq Task1_Fail // if there is nothing left to pop then fail
			pop {r3}
			cmp r3, #'(' // pop from stack and check if (
			beq Task1_Loop // if equal then done
			strb r3, [r5] // if not then store to Postfix and increment
			adds r5, #1
			b Pop_Loop

	Task1_Done:
		cmp sp, r6
		bne Task1_Fail // if there is things left on stack then fail
		movs r2, #0
		strb r2, [r5] // null terminates the string
		movs r0, #1 // r0 = 1 for pass
		pop {r4-r6, pc}
	
	Task1_Fail:
		movs r0, #0 // set r0 to 0 for fail
		mov sp, r6 // clean up stack
		pop {r4-r6, pc}

/*--------------End of Task1 subroutine -----------*/    

/* ++++++++++++++++++Task 2 subroutine ++++++++++ */
/*
	Algorithm: Evaluate to a Postfix Expression

		(1) Read next char from Postfix into cc
    		If cc is '\0' then goto 5

		(2) If cc is a variable, push its value on the Stack

		(3) If cc is an. operator X
    		- Pop 2 elements off the Stack
    		- Perform operation X
    		- Push result on the Stack

		(4) Goto Step 1

		(5) Pop value from Stack and write to Result
*/
Task2:
	push {r4-r6, lr}
	// Task2 solution goes here
	ldr r4, =PostFix
	Task2_Loop:
		ldrb r0, [r4] // read and increment
		adds r4, #1
		cmp r0, #0 // check for sentinel
		beq Task2_Done
		movs r5, r0 // save copy of current char
		
		bl IsAlpha // check if char is variable
		cmp r1, #1
		beq Task2_IsVariable

		movs r0, r5 // check if char is operator
		bl IsOp
		cmp r1, #1
		beq Task2_IsOperator
		b Task2_Loop

	Task2_IsVariable:
		movs r0, r5
		bl Value
		push {r0} // Step 2
		b Task2_Loop

	Task2_IsOperator:
		//Step 3
		pop {r2}
		pop {r1}
		cmp r5, #'+'
    	beq Task2_Add
    	cmp r5, #'-'
    	beq Task2_Subtract
    	cmp r5, #'*'
    	beq Task2_Multiply
    	cmp r5, #'/'
    	beq Task2_Divide
    	b Task2_Loop	
	
	Task2_Add:
		adds r1, r1, r2
		b Task2_PushResult

	Task2_Subtract:
		subs r1, r1, r2
		b Task2_PushResult

	Task2_Multiply:
		muls r1, r2, r1
		b Task2_PushResult

	Task2_Divide:
		bl Divide
		b Task2_PushResult
	
	Task2_PushResult:
		push {r1}
		b Task2_Loop
	
	Task2_Done:
		ldr r4, =Result
		pop {r0}
		str r0, [r4]
		pop {r4-r6, pc}

/*--------------End of Task1 subroutine -----------*/    

/*  Subroutine IsAlpha: 
	Purpose: Checks if the given input is a variable
   	Input: R0 has character to check
   	Output: R1 has 1 if R0 is a variable: [a-z] 0 otherwise
*/

IsAlpha:
	movs r1, #0 // default to 0
	cmp r0, #'a'
	blt IsAlpha_Exit // if <'a'
	cmp r0, #'z'
	bgt IsAlpha_Exit // if <'z'
	movs r1, #1 // else input is variable
	IsAlpha_Exit:
		bx lr

/*  Subroutine IsOp: 
	Purpose: Checks if the given input is an operator
   	Input: R0 has character to check
   	Output: R1 has 1 if R0 is an operator (+,-,*,/) 0 otherwise
*/

IsOp:
	movs r1, #1 // default to 1
	cmp r0, #'+'
    beq IsOp_Exit
    cmp r0, #'-'
    beq IsOp_Exit
    cmp r0, #'*'
    beq IsOp_Exit
    cmp r0, #'/'
    beq IsOp_Exit
    movs r1, #0 // input is not an operator 
	IsOp_Exit:
		bx lr

/*  Subroutine Divide
        Purpose: Divide R1 by R1
        Inputs: R1 an R2
        Output: R1 has the quotient
*/
Divide:
        push {r4,r5,lr}
        movs r5, #0             // keep quotient here
        movs r4, #0             // to flip result or not
        cmp  r1, #0
        blt  NrNeg
        cmp  r2, #0
        bgt  DoDiv
        // here means NrPos and DrNeg
        subs r2, r5, r2  // flip Dr
        movs r4, #1
        b    DoDiv
NrNeg:
        cmp  r2, #0
        blt  NrDrNeg
        // Here means NrNeg and DrPos
        subs r1, r5, r1  // flip Nr
        movs r4, #1
        b    DoDiv
NrDrNeg:
        subs r1, r5, r1  // flip Nr
        subs r2, r5, r2  // flip Dr
DoDiv:
        subs r1, r2
        bmi  DivDone
        adds r5, #1
    b    DoDiv
DivDone:
        movs r1, r5
        cmp r4, #0
        beq DivDoneDone
        movs r4, #0
        subs r1, r4, r5
DivDoneDone:
        pop {r4,r5,pc}



/*  Subroutine Value: 
	Purpose: Finds the value of a variable
   	Input: R0 has the variable [a-z]
   	Output: R0 has the value or 1000 if not found
*/

Value:
	push {r4, lr}
	ldr r1, =VTab
	
	Value_Loop:
		ldrb r2, [r1] // load byte
		cmp r2, #0 // check for sentinel
		beq Value_NotFound
		cmp r0, r2 // compare input with table
		beq Value_Found
		adds r1, r1, #8 // move 5bytes up (1 byte char + padding  + 4 byte int)
		b Value_Loop
	Value_Found:
		ldr r0, [r1, #4] 
		pop {r4, pc}

	Value_NotFound:
		ldr r0, =1000
		pop {r4, pc}
.end
