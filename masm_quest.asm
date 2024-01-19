TITLE masm_quest (masm_quest.asm)
; Author(s): Maxwell Cole, Audrey Au, Julia Yang
; Course / Project ID CS 271_001 / Final Exam		Date: 6/12/2023
; Description: Final assembly program in which we created a game that uses every concept we learned in the class at least once. The game involves the user, a wizard, battling three skeletons using magic.

INCLUDE Irvine32.inc

; MACROS
;----------------------------------------
; printSkeleton Macro
; macro to print the skeleton ascii art
;----------------------------------------
printSkeleton MACRO skeletonName
        mov edx, OFFSET skeletonName
        call WriteString
        mov edx, OFFSET largeSpacer
        call WriteString
ENDM

;----------------------------------------
; printWizard Macro
; macro to print the wizard ascii art
;----------------------------------------
printWizard MACRO wizardName
		mov edx, OFFSET largeSpacer
        call WriteString
        call WriteString
        mov edx, OFFSET smallSpacer
        call WriteString
        mov edx, OFFSET wizardName
        call WriteString
        call Crlf
ENDM

.data                          ; data declaration
    ; CONSTANTS
    SKELETON_HI = 20
    SKELETON_LO = 10
    
    ICE_SHARD_COST = 10
    FIREBALL_COST = 30
    LIGHTNING_COST = 20
    MATH_COST = 10
    HEALING_COST = 20
    
    HEALING_AMOUNT = 40
    MAGIC_REFRESH = 40
  
    ; VARIABLES
    ; Wizard
    avatar1 BYTE "     __/\__    ", 0
    avatar2 BYTE ". _  \\''//    ", 0
    avatar3 BYTE "-( )-/_||_\    ", 0
    avatar4 BYTE " .'. \_()_/    ", 0
    avatar5 BYTE "  |   | . \    ", 0
    avatar6 BYTE "  |   | .  \   ", 0
    avatar7 BYTE " .'. ,\_____'. ", 0
  	
    ; Skeleton
	skeleton1 BYTE "      .-.     ", 0
    skeleton2 BYTE "     (o.o)    ", 0
    skeleton3 BYTE "      |=|/    ", 0
    skeleton4 BYTE "     __|__    ", 0
    skeleton5 BYTE "   //.=|=.\\  ", 0
    skeleton6 BYTE "  // .=|=. \\ ", 0
    skeleton7 BYTE "  \\ .=|=. // ", 0
    skeleton8 BYTE "   \\(_=_)//  ", 0
    skeleton9 BYTE "    (:| |:)   ", 0
    skeleton10 BYTE "     || ||    ", 0
    skeleton11 BYTE "     || ||    ", 0
    skeleton12 BYTE "    ==' '==   ", 0
  
	; introduction statements
    intro1  BYTE    "			~Welcome to MASM Quest!~", 0
    intro2  BYTE    "=========== Created by Maxwell Cole, Audrey Au, Julia Yang ============", 0
    intro3  BYTE    "This program simulates a battle between a wizard and its enemies. ", 0 
    intro4  BYTE    "Your wizard tower has fallen on hard times. Successfully defeat all enemies to win! ", 0
    
    ; instruction statements
    instruction1    BYTE    "Rules: ", 0
    instruction2    BYTE    "Defeat all enemies to win. ", 0
    instruction3    BYTE    "Each round, a player can choose one spell. Each spell has a different effect and cost. ", 0
    instruction4    BYTE    "Enemies will be given a turn to attack after you. If your health reaches zero, you lose. ", 0
    
    ; turn identifiers
    newTurn         BYTE    "============================ NEW TURN ============================ ", 0
    playerTurnMsg   BYTE    "~YOUR TURN~", 0
    enemyTurnMsg    BYTE    "~ENEMY'S TURN~", 0
    
    ; display spells
    displayOption   BYTE    "*============* List of Spells *============*", 0
    display1        BYTE    "1. Ice Shards [20 dmg] - 10 Magic", 0
    display2        BYTE    "2. Fireball [40 dmg] - 30 Magic", 0
    display3        BYTE    "3. Lightning bolt [30 dmg] x 3 - 20 Magic (60 total)", 0
    display4        BYTE    "4. Math spell [skip enemy turn] - 10 Magic", 0
    display5        BYTE    "5. Healing spell [+40 health] - 20 Magic", 0

    ; choose spell
    getOption           BYTE    "Choose a Spell to Use: ", 0
    displayUserOption   BYTE    "You have chosen ", 0
    errorMsg            BYTE    "That is not a spell option! Choose again.", 0
    
    ; display lightning
    insufficientMagicMsg    BYTE    "You don't have enough magic for this! You must spend a turn to regenerate 40 magic.", 0
    lightningMsg            BYTE    "ZAP! Choose Another to hit. ", 0
    lightningDoneMsg        BYTE    "You do not have enough magic to strike again.", 0

    ; display regained health
    healingMsg1             BYTE    "You regain 20 Health!", 0
    healingMsg2             BYTE    "You now have ", 0
    healingMsg3             BYTE    " health.", 0

    ; display math
    mathMsg         BYTE    "You use the power of math to confuse your enemies!", 0
    getRadius       BYTE    "Enter an integer from 1 to 10: ", 0
    getRadiusError  BYTE    "That is not a valid option! Choose again.", 0

    areaMsg1    BYTE    "You calculate the areas of ", 0
    areaMsg2    BYTE    " circles!", 0
    areaMsg3    BYTE    "The enemy is baffled! What are these numbers? They miss their chance to attack.", 0
    printArea   BYTE    "Area: ", 0
    
    enemySkip   DWORD   0
    radius      DWORD   ?
    area        REAL8   ?
    
    ; enemy display option
    enemyDisplay1   BYTE    "Your enemy attacks you and deals ", 0
    enemyDisplay2   BYTE    " damage", 0

    ; target selection option
    selectTargetMsg         BYTE    "Select a target to hit (left-right): ", 0
    selectTargetConfirm     BYTE    "You chose to hit ", 0
    selectTargetErrorMsg    BYTE    "That is not a valid target!", 0
    
    ; ending print statements
    end1    BYTE    "============================ GAME OVER ============================", 0
    end2    BYTE    "You have successfully defeated all the enemies!", 0
    end3    BYTE    "You have been defeated :(", 0

	; user inputs for game 
    userOption          DWORD   ?
    targetEnemyIndex    DWORD   ?
   
    enemyCount  DWORD   3
    
    ; enemy Info
	skeletonName    BYTE    "Skeleton ", 0
    slashSymbol     BYTE    "|", 0
    
    ; health bar square symbol
    square db 219
                            
    enemyHealth DWORD 100, 100, 100             ; ARRAY
    enemyHealthSize = ($ - enemyHealth) / 4
    enemyDamage DWORD 15, 20, 15                ; ARRAY

    enemyCheckIterator DWORD ?
    
    playerName      BYTE    "Wizard ", 0
    magicMsg        BYTE    "Magic  ", 0
    playerHealth    DWORD   100
    playerMagic     DWORD   100
     
    smallSpacer     BYTE    "	", 0
   	largeSpacer     BYTE    "         ", 0

	; spell damage values
   	iceShardDamage      DWORD   20
    fireballDamage      DWORD   40
    lightningBoltDamage DWORD   30
  
.code                          ; code declaration
  
main PROC                      ; main method starts
	FINIT
	call Randomize
    call introduction
    ;call bankInfo
    call gameLoop
    call endGame
	exit
main ENDP

; PROCEDURES
;----------------------------------------
; gameLoop Procedure 
; procedure to keep creating game rounds until either the enemies or user is defeated
;----------------------------------------
gameLoop PROC   
    loop_start: ; POST CHECK LOOP --> plays at least once, and will continue to play if no one has won yet
        mov esi, 0 
   	    call displayEnemyInfo
        call Crlf
        call printSkeletonArt
        call Crlf
        call displayPlayerInfo
        call Crlf
        call printWizardArt
        call Crlf
        call attack
        call enemyTurn
            
        mov ecx, 0                                  
        mov ebx, OFFSET enemyHealth                 ; Point EBX to the start of the array

        checkEnemyHealth:   ; COUNTED LOOP -> loops according to number of enemies (to check that all are dead)
            cmp DWORD PTR [ebx + ecx * 4], 0  
            jne checkPlayerHealth                   ; If at least one enemy is alive, check player health

            inc ecx                                 
            cmp ecx, enemyCount                     ; Compare the loop counter with the array size
            jl checkEnemyHealth                      
    
        ; If reach this point, all enemies are dead, so end game
        jmp loop_break 
        
        checkPlayerHealth:
            cmp playerHealth, 0
            je loop_break   
    
        newTurnMessage:
            call Crlf
            mov edx, OFFSET newTurn
            call WriteString
            call Crlf
            call Crlf

        jmp loop_start

    loop_break:
        ret
gameLoop ENDP

;----------------------------------------
; endGame Procedure 
; procedure to end the game by outputting the correct end message.
;----------------------------------------
endGame PROC
    call Crlf
    call Crlf
    mov edx, OFFSET end1
    call WriteString
    call Crlf

    cmp playerHealth, 0
    je playerLose

    playerWin:
        mov edx, OFFSET end2
        call WriteString
        call Crlf
        ret

    playerLose:
        mov edx, OFFSET end3
        call WriteString
        call Crlf
        ret
    
endGame ENDP

;----------------------------------------
; selectTarget Procedure 
; procedure to select target for attack based on user's input
;----------------------------------------
selectTarget PROC
	call Crlf
	mov edx, OFFSET selectTargetMsg
    call WriteString
    call ReadInt
    
    cmp eax, 1  ; Compare user input with lower bound
    jl selectTargetError  ; Jump to selectTargetError if userOption < 1
    cmp eax, enemyCount  ; Compare user input with upper bound (ENEMY_COUNT)
    jg selectTargetError  ; Jump to selectTargetError if userOption > ENEMY_COUNT
 	
    mov edx, OFFSET selectTargetConfirm
    call WriteString
    mov targetEnemyIndex, eax
    call WriteDec
   	call Crlf
        
    ; Store the validated target enemy index
    mov eax, targetEnemyIndex
    ret
    
selectTargetError:
	mov edx, OFFSET selectTargetErrorMsg
    call WriteString
    call Crlf
   	jmp selectTarget

selectTarget ENDP

;----------------------------------------
; attack Procedure 
; procedure to commence player attack
;----------------------------------------
attack PROC
	mov edx, OFFSET playerTurnMsg
    call WriteString
    call Crlf
    call Crlf

	; Passing user choice as parameter to select attack
    call displayOptions
    mov eax, userOption
    
    cmp eax, 1
    je iceShard
    cmp eax, 2
    je fireball
    cmp eax, 3
    je lightningBolt
    cmp eax, 4
    je mathSpell
    cmp eax, 5
    je healingSpell
    
    ; 1. ICE SHARD SPELL
    iceShard:

	    cmp playerMagic, ICE_SHARD_COST
        jl insufficientMagic
    
 	    call selectTarget
        mov ebx, targetEnemyIndex
        
        mov edi, ebx
        dec edi
        imul edi, SIZEOF DWORD

        ; Load the iceShard damage for the attack option
        mov eax, OFFSET iceShardDamage
        mov edx, [eax]
    
        sub playerMagic, ICE_SHARD_COST

        jmp subtractDamage
    
    ; 2. FIREBALL SPELL
    fireball:

	    cmp playerMagic, FIREBALL_COST
        jl insufficientMagic
    	
        call selectTarget
        mov ebx, targetEnemyIndex
        
        mov edi, ebx
        dec edi
        imul edi, SIZEOF DWORD
    
	    ; Load the fireball damage for the attack option
        mov eax, OFFSET fireballDamage
        mov edx, [eax]

        sub playerMagic, FIREBALL_COST

        jmp subtractDamage

    ; 3. LIGHTNING SPELL
    lightningBolt:
        ; Initialize a counter for the number of lightning bolts cast
        mov ecx, 0
    
        preCheckLoop:   ; PRE-CHECK LOOP --> check to make sure player has enough magic before running
    	    cmp ecx, 3
            je exitPreCheckLoop
        
            ; Check if the player has enough magic points to cast another lightning bolt
            cmp playerMagic, LIGHTNING_COST
            jl insufficientMagic
        
            ; Subtract the magic cost from the player's magic
            sub playerMagic, LIGHTNING_COST
     	
            call selectTarget
            mov ebx, targetEnemyIndex
        
       	    mov edx, OFFSET lightningMsg
            call WriteString
    
            mov edi, ebx
            dec edi
            imul edi, SIZEOF DWORD

            ; Load the lightning damage for the attack option
            mov eax, OFFSET lightningBoltDamage
            mov edx, [eax]
        
            cmp edx, [enemyHealth + edi]
    	    jge zeroTheDamage1
        
            sub DWORD PTR [enemyHealth + edi], edx
        
            inc ecx
            jmp preCheckLoop
        
    exitPreCheckLoop:
	        call Crlf
	        mov edx, OFFSET lightningDoneMsg
            call WriteString
	        ret
    
    ; 4. MATH SPELL    
    mathSpell:
        cmp playerMagic, MATH_COST
        jl insufficientMagic

        call Crlf
        mov edx, OFFSET mathMsg
        call WriteString
        call Crlf

        validateInput:
            mov edx, OFFSET getRadius
            call WriteString
            call ReadInt

            cmp eax, 1
            jl errorHandle
            cmp eax, 10
            jg errorHandle

            mov radius, eax  
        
            call Crlf
            mov edx, OFFSET areaMsg1
            call WriteString
            call WriteDec
            mov edx, OFFSET areaMsg2
            call WriteString
            call Crlf

            call mathematics

            call Crlf
            mov edx, OFFSET areaMsg3
            call WriteString
            call Crlf

            mov enemySkip, 1
	        ret

        errorHandle:
            mov edx, OFFSET getRadiusError
            call WriteString
            call Crlf

            jmp validateInput

    ; 5. HEAL SPELL
    healingSpell:
	    ; Check if the player has enough magic points to cast the spell
	    cmp playerMagic, HEALING_COST
        jl insufficientMagic
    
        ; Subtract the magic cost from the player's magic
        sub playerMagic, HEALING_COST
    
        ; Add the healing amount to the player's health
        add playerHealth, HEALING_AMOUNT

        ; Display a message indicating successful healing
        call Crlf
        mov edx, OFFSET healingMsg1
        call WriteString 
        call Crlf

        mov edx, OFFSET healingMsg2
        call WriteString
        mov eax, playerHealth
        call WriteDec
        mov edx, OFFSET healingMsg3
        call WriteString

        jmp success1
    
    insufficientMagic:
        ; Display a message indicating insufficient magic points
        mov edx, OFFSET insufficientMagicMsg
        call WriteString
    
        add playerMagic, MAGIC_REFRESH
        jmp success1

    subtractDamage:
        ; Subtract the damage from the target enemy's health
        cmp edx, [enemyHealth + edi]
        jge zeroTheDamage1
    
        sub DWORD PTR [enemyHealth + edi], edx
        jmp success1

        zeroTheDamage1:
            mov DWORD PTR [enemyHealth + edi], 0
    
	    success1:
		    ret

attack ENDP

;----------------------------------------
; mathematics Procedure 
; recursive procedure for calculating x number of circles while decrementing each time
;----------------------------------------
mathematics PROC    
    push ebp    ; USE OF THE STACK --> push and pop from stack  
    mov ebp, esp 
    sub esp, 4 

    ; Calculate Area = pi * radius * radius
    finit   ; USE OF THE FPU --> calculate area using pi 3.14
    fldpi	
    fild radius
    fild radius
    fmul	
    fmul
    fstp area		

    ; Print the area of the circle
    mov edx, OFFSET printArea
    call WriteString
    fld area
	call WriteFloat
    call Crlf

    ; Base case = 1
    cmp radius, 1   
    jle done

    dec radius
    call mathematics    ; RECURSIVE PROCEDURE --> keeps going from input "radius" and decrements until reach 1

    done:
        mov esp, ebp 
        pop ebp
        ret
    
mathematics ENDP


;----------------------------------------
; enemyTurn Procedure 
;----------------------------------------
enemyTurn PROC
    cmp enemySkip, 1
    je skip

    call Crlf
    call Crlf
    call Crlf

    mov edx, OFFSET enemyTurnMsg
    call WriteString
    call Crlf
    
    ; enemy randomly gives out damage from 10 to 20
    mov	eax, SKELETON_HI
	sub	eax, SKELETON_LO
   
    call RandomRange
    inc eax
    add	eax, SKELETON_LO	; add number to low
    
    cmp eax, playerHealth
    jg zeroTheDamage

    sub playerHealth, eax
    jmp success

    zeroTheDamage:
        mov playerHealth, 0

    success:
        call Crlf
        mov edx, OFFSET enemyDisplay1 
        call WriteString

        call WriteDec

        mov edx, OFFSET enemyDisplay2
        call WriteString
        call Crlf

        ret

    skip:
        mov enemySkip, 0
        ret

enemyTurn ENDP

;----------------------------------------
; introduction Procedure 
; procedure to print introductive statements
;----------------------------------------  
introduction PROC
	mov EDX, OFFSET intro1
    call WriteString
    call Crlf

    mov EDX, OFFSET intro2
    call WriteString
    call Crlf

    mov EDX, OFFSET intro3
    call WriteString
    call Crlf
    mov EDX, OFFSET intro4
    call WriteString
    call Crlf
    call crlf

    mov EDX, OFFSET instruction1
    call WriteString
    call Crlf

    mov EDX, OFFSET instruction2
    call WriteString
    mov EDX, OFFSET instruction3
    call WriteString
    mov EDX, OFFSET instruction4
    call WriteString
    call Crlf
    call Crlf
    
    ret

introduction ENDP

;----------------------------------------
; displayOptions Procedure 
; procedure to display possible attacks and get user attack
;----------------------------------------
displayOptions PROC
    mov EDX, OFFSET displayOption
    call WriteString
    call Crlf
    
    mov EDX, OFFSET display1
    call WriteString
    call Crlf

    mov EDX, OFFSET display2
    call WriteString
    call Crlf

    mov EDX, OFFSET display3
    call WriteString
    call Crlf

    mov EDX, OFFSET display4
    call WriteString
    call Crlf

    mov EDX, OFFSET display5
    call WriteString
    call Crlf
    call Crlf

	validateInput:
        mov EDX, OFFSET getOption
        call WriteString
        call ReadInt

        cmp EAX, 1      ; Compare user input with lower bound
        jl displayError        ; Jump to displayError if userOption < 1
        cmp EAX, 5      ; Compare user input with upper bound
        jg displayError        ; Jump to displayError if userOption > 5

        mov EDX, OFFSET displayUserOption
        call WriteString
        mov userOption, EAX
        call WriteDec
        call Crlf
        
        mov EAX, userOption
        ret
        
	displayError:
		mov EDX, OFFSET errorMsg
		call WriteString
		call Crlf
		jmp validateInput
        
displayOptions ENDP


;----------------------------------------
; displayEnemyInfo Procedure 
; procedure to display the name, health statistics, and a scalable health bar for each enemy still in play.
;----------------------------------------
displayEnemyInfo PROC
	
   	mov edx, OFFSET skeletonName ; Calculate the address of the current name
   	call WriteString

    ; Display enemy health
   	mov eax, [enemyHealth + esi * 4]
    call WriteDec
    
    mov edx, OFFSET slashSymbol
    call WriteString
    
    mov ebx, 0
    mov ecx, eax ; Maximum length of the health bar
    
	call checkStatus

    cmp ecx, 0  ; check to see if enemy has health
    jle noHealthBar

    printHealthTick:
    	mov ebx, 0
        mov al, [square]; ASCII character for health bar
    	call WriteChar
            
   	healthBarLoop:
     	cmp ebx, 10
        je printHealthTick
        
        inc ebx
        loop healthBarLoop

    reset: 
	    call resetColor
        mov edx, OFFSET smallSpacer
        call WriteString

        inc esi
        cmp esi, enemyCount
        jl displayEnemyInfo
 	
        ret

    noHealthBar:
        ; skip the code that creates a bar (otherwise, endless loop)
        mov edx, OFFSET smallSpacer ; fix alignment
        call WriteString
        jmp reset
    
displayEnemyInfo ENDP

;----------------------------------------
; displayPlayerInfo Procedure 
; procedure to display the player name, health statistics, and a scalable health and mana bar.
;----------------------------------------
displayPlayerInfo PROC

	call printSpacer

    mov edx, OFFSET playerName
    call WriteString
    
    mov eax, playerHealth
    call WriteDec
    
    mov edx, OFFSET slashSymbol
    call WriteString
    
    mov ebx, 0
    mov ecx, eax ; Maximum length of the health bar
    
	call checkStatus

    ; no need to fix endless print cycle for player with 0 health cuz it will automatically ned game and never display the loop
    
    printHealthTick:
    	mov ebx, 0
        mov al, [square]; ASCII character for health bar
    	call WriteChar
            
   	healthBarLoop:
     	cmp ebx, 10
        je printHealthTick
        
        inc ebx
        loop healthBarLoop

	call resetColor
    call Crlf
    call printSpacer
    
	mov edx, OFFSET magicMsg
    call WriteString
    
    mov eax, playerMagic
    call WriteDec
    
    mov edx, OFFSET slashSymbol
    call WriteString
    
    mov ebx, 0
    mov ecx, eax ; Maximum length of the magic bar

    cmp ecx, 0  ; check to see if enemy has health
    jle noMagicBar
    
    mov  eax, cyan(black)
    call SetTextColor
    
    printMagicTick:
    	mov ebx, 0
        mov al, [square]; ASCII character for magic bar
    	call WriteChar
            
   	magicBarLoop:
     	cmp ebx, 10
        je printMagicTick
        
        inc ebx
        loop magicBarLoop
   
	reset:
        call resetColor
        call Crlf
        ret

    noMagicBar:
        ; skip the code that creates a bar (otherwise, endless loop)
        mov edx, OFFSET smallSpacer ; fix alignment
        call WriteString
        jmp reset

displayPlayerInfo ENDP

;----------------------------------------
; printSpacer Procedure
; procedure to print space
;----------------------------------------
printSpacer PROC
		mov edx, OFFSET largeSpacer
        call WriteString
        call WriteString
        
        ret
printSpacer ENDP

;----------------------------------------
; resetColor Procedure
; procedure to reset the color of the terminal
;----------------------------------------
resetColor PROC
    mov  eax, white(black)
    call SetTextColor
    ret
resetColor ENDP


;----------------------------------------
; checkStatus Procedure
; procedure to dynamically adjust the text color based on the respective health being displayed.
;----------------------------------------
checkStatus PROC
    cmp eax, 33
    jle lowHealth
    cmp eax, 66
    jle mediumHealth
    cmp eax, 100
    jle highHealth

    lowHealth:
        mov  eax, red(black)
        call SetTextColor
        jmp finish

    mediumHealth:
        mov  eax, yellow(black)
        call SetTextColor
        jmp finish

    highHealth:
        mov  eax, lightGreen(black)
        call SetTextColor
        jmp finish
        
 	finish:
        ret
        
checkStatus ENDP


;----------------------------------------
; printSkeletonArt Procedure
; procedure to print skeleton ascii art
;----------------------------------------
printSkeletonArt PROC
	mov ecx, enemyCount
    skeletonOne:
    	printSkeleton skeleton1
        loop skeletonOne  
   	call Crlf	 
     
    mov ecx, enemyCount
    skeletonTwo:
    	printSkeleton skeleton2
        loop skeletonTwo
   	call Crlf
    
    mov ecx, enemyCount
    skeletonThree:
    	printSkeleton skeleton3
        loop skeletonThree
   	call Crlf
    
    mov ecx, enemyCount
    skeletonFour:
    	printSkeleton skeleton4
        loop skeletonFour
   	call Crlf
    
    mov ecx, enemyCount
    skeletonFive:
    	printSkeleton skeleton5
        loop skeletonFive
   	call Crlf	
    
    mov ecx, enemyCount
    skeletonSix:
    	printSkeleton skeleton6
        loop skeletonSix
   	call Crlf	 
    
    mov ecx, enemyCount
    skeletonSeven:
    	printSkeleton skeleton7
        loop skeletonSeven
   	call Crlf
    
    mov ecx, enemyCount
    skeletonEight:
    	printSkeleton skeleton8
        loop skeletonEight
   	call Crlf	
    
    mov ecx, enemyCount
    skeletonNine:
    	printSkeleton skeleton9
        loop skeletonNine
   	call Crlf	 
    
    mov ecx, enemyCount
    skeletonTen:
    	printSkeleton skeleton10
        loop skeletonTen
   	call Crlf
    
    mov ecx, enemyCount
    skeletonTwelve:
    	printSkeleton skeleton11
        loop skeletonTwelve
   	call Crlf	 
    
    mov ecx, enemyCount
    skeletonThirteen:
    	printSkeleton skeleton12
        loop skeletonThirteen
   	call Crlf	    
    ret
    
printSkeletonArt ENDP

;----------------------------------------
; printWizardArt Procedure
; procedure to print wizard ascii art
;----------------------------------------
printWizardArt PROC

    printWizard avatar1
    printWizard avatar2
    printWizard avatar3
    printWizard avatar4
    printWizard avatar5
    printWizard avatar6
    printWizard avatar7
    ret
    
printWizardArt ENDP

  END main 
