;##################################################################################
;		Create a Doubly Linked List and Preform Insertion Sort on the List.       #
;##################################################################################
				
data_to_sort		dcd		34, 23, 22, 8, 50, 74, 2, 1, 17, 40
list_elements		dcd		10
				
main				  ldr		r3, =data_to_sort   ; Load the starting address of the first of element of the array of numbers into r3
              ldr		r4, =list_elements  ; address of number of elements in the list
              ldr		r4, [r4]            ; number of elements in the list
              mov		r12, r4
              
              add		r5, r3, #400	 ; location of first element of linked list - "head pointer"
              ;		(note that I assume it is at a "random" location
              ;		beyond the end of the array.)
              
              ;#################################################################################
              ;		Include any setup code here prior to loop that loads data elements in array
              mov		r10, #900 		; the start and ending items in the list will have -1 , and 200 placeholder values. Referenceing it to be NULL
              mov		r11, #-1
              mov		r1, #0 			; loop counter
              add		r2, r5, #4 		; previous element data address of struct
              mov		r6, r5 			; first element
              lsl		r4, r4, #2	 	; r4 * 4 to handle array indexing
				;#################################################################################
				
				;#################################################################################
				;		Start a loop here to load elements in the array and add them to a linked list
loop				  cmp		r1, r4 			; compare loop counter with total elements in list
              bge		sort
              bl		insert
              mov		r2, r6 			; set previous element to data address of struct just created
              sub		r6, r6, #4 		; move r6 pointer back to head / previous section of struct
              add		r1, r1, #4 		; increase loop counter by 1 index in this case is 4? why not 8? or can I just use 1?
              ;#################################################################################
              add		r6, r6, #32		; every time you create a new struct, add 32 to
              ;		starting address of last struct to mimic
              ;		non-contiguous memory locations
              ;		I assume address of last struct is in r6
              ;		you DO NOT need to make this assumption
              b		loop
				
				
				;#################################################################################
				;		Add insert, swap, delete functions
insert			  ldr		r7, [r3, r1] 	; load data value of data_to_sort[i]
              cmp		r1, #0 			; check if on first element
              beq		first_elm
              str		r2, [r6] 		; store previous data address
              str		r7, [r6, #4] 	; store data into struct data section
              add		r6, r6, #4 		; r6 = data address of struct
              str		r6, [r2, #4]	; store r6 address into next section of previous struct
              str		r10, [r6, #4] 	; store placeholder into next of current struct
              mov		r15, r14 		; go back to call location
				
first_elm			str		r11, [r6, #0] 	; previous of first elm is null or -1 in this case
              str		r7, [r6, #4] 	; data being stored
              str		r10, [r6, #8] 	; next pointer set to 0
              add		r6, r6, #4 		; point to data section of struct
              mov		r15, r14 		; go back to call location
				
sort		      mov		r10, #1 		; loop counter j = 0
              add		r0, r5, #4 		; address of previous of key
              ldr		r6, [r0, #4] 	; key address
              ldr		r9, [r6, #4] 	; load address after key
for_loop			cmp		r10, r4
				      bge		done_sort
while_loop		ldr		r1, [r0] 		; value of previous of key
              ldr		r7, [r6] 		; key value
              cmp		r7, r1
              bgt		go_next
              beq		same_value
              bl		swap
              ldr		r8, [r6, #-4] 	; load prev
              cmp		r8, r11
              beq		go_next
              ldr		r0, [r6, #-4]
              b		while_loop
				
same_value		bl		delete
				
go_next	      add		r10, r10, #1 	; j = j+1
              cmp		r10, r12
              beq		done_sort
              ldr		r0, [r9, #-4] 	; get previous list address
              mov		r6, r9 			; key = next item in list
              ldr		r9, [r9, #4] 	; get next item address
              b		for_loop
				
swap		      ldr		r8, [r0, #-4] 	; loading previous address of previous
              cmp		r8, r11
              beq		beginning_of_list ; check if previous address = -1 means this is head of list
              ldr		r8, [r6, #4] 	; laod next
              cmp		r8, #900
              beq		no_next
              str		r0, [r8, #-4] 	; store previous of item after key
no_next	      str		r8, [r0, #4] 	; store next
              ldr		r8, [r0, #-4]
              cmp		r8, #-1
              beq		no_prev
              str		r6, [r8, #4] 	; store next
no_prev	      str		r0, [r6, #4] 	; store next
              ldr		r8, [r0, #-4] 	; load prev
              str		r8, [r6, #-4] 	; store prev
              str		r6, [r0, #-4] 	; store prev
              mov		r15, r14 		; go back to call location
				
beginning_of_list
				      ldr		r8, [r6, #4] 	; address of next of key
				      cmp		r8,#900
				      beq		DNE
				      str		r0, [r8, #-4] 	; store previous of item after key
DNE			      str		r8, [r0, #4] 	; store next of key into previous next
              str		r0, [r6, #4] 	; store address of previous into next of key
              str		r6, [r0, #-4] 	; store address of key into previuos of previous item
              str		r11, [r6, #-4] 	; store null value into previous of r6
              mov		r5, r6 			; making new head pointer
              mov		r15, r14 		; go back to call location
				
delete	      ldr		r8, [r6, #4] 	; get next value of key
              str		r8, [r0, #4] 	; store in next value of previous
              str		r11, [r6, #-4] 	; set previous to null or -1
              str		r11, [r6, #4] 	; set next to null or -1
              mov		r15, r14 		; go back to function call location
				
				
done_sort			b		print 			; I print after sorting the linked list ;
				
before_print	add		r5, r5, #4      ; use this if printing after the list is created but sorting hasnt occured
print									; use this if printing after sorting has occured already.
              ldr		r8, [r5]		; Loading value of node to r8 ; check history of R8 to see if linked list is correct.
              ldr		r5, [r5, #4]	; Loading value of next to curr
              cmp		r5, #900
              beq		stop
              cmp		r5, r10			; Cheking if next is sentinel
              beq		stop			; If it is finish loop
              b		print			; Else continue looping
              
stop
				end
