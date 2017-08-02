#Creators: Gabriella Quattrone
#Date: Monday July 13, 9:28 PM
#Purpose: to calculate the edit distance between 2 strings.

.global _start
.equ ws, 4

.data
  string1:
     .space 100
  string2:
     .space 100
  strlen1:
     .long 0
  strlen2:
     .long 0
  curDist:
     .space 116
  oldDist:
     .space 116
  i:
     .long 0

  j:
     .long 1
  dist:
     .long 0
  temp:
     .space 116
  strlen_result:
     .long 1
  strl_start:
     .long 0
.text
 strlen: 
    movl strl_start, %ecx #get argument
    movl $0, %edx # i = 0
   for_strlen:
    cmpb $0, (%ecx, %edx) 
    jz end_for
    incl %edx #++i
    jmp for_strlen
   end_for: 
     movl %edx, strlen_result
     ret   
editDist:
   movl $string1, %ecx
   movl %ecx, strl_start
   call strlen
   movl strlen_result, %ecx
   movl %ecx, strlen1

   movl $string2, %ecx
   movl %ecx, strl_start
   call strlen
   movl strlen_result, %ecx
   movl %ecx, strlen2
 
#for(i = 0; i < word2_len + 1; i++)#
        movl $0, %edx #i = 0 
	addl $1, strlen2 #strlen2 = strlen2 + 1        
	init_for: 
            cmpl strlen2, %edx #i - strlen2 + 1 < 0
	    jge end_init_for #jump if greater than 0
	    addl %edx, curDist(, %edx, ws) #curDist[i] = i;
	    addl %edx, oldDist(, %edx, ws) #oldDist[i] = i;
	    incl %edx #i++
	    jmp init_for
	end_init_for:
# initiate i = 1 and j = 1 #
	movl $1, %edx #i = 1
	movl $1, %eax #j = 1
	addl $1, strlen1
#for(i = 1; i < word1_len + 1; i++)
	outside_for: 
	   cmpl strlen1, %edx #i - strlen1 < 0
	   jge end_outside
	   movl %edx, curDist #curDist[0] = i
#for(j = 1; j < word2_len + 1; j++)
	inside_for:
	   cmpl strlen2, %eax # j - (strlen2 + 1) < 0
	   jge swapcall  #if greater than 0
#if(word1[i-1] == word2[j-1])
	if_condition:
	   movb string1-1(,%edx,), %ch #word1[i-1]
	   movb string2-1(,%eax,), %cl #word2[j-1]
	   cmpb %cl, %ch
	   jne else_condition

	   movl oldDist-1*4(,%eax,ws), %ebx #EBX = oldDist[j-1]
	   movl %ebx, curDist(,%eax,ws) #curDist[j] = oldDist[j-1];
           incl %eax #j++
           jmp inside_for
	else_condition:
	   #MIN FUNCTION#
	   # EBX = A
           # ECX = B
	   movl oldDist(,%eax,ws), %ebx #(a) oldDist[j]
	   movl curDist-1*4(,%eax,ws), %ecx #(B) curDist[j-1] 
           cmpl %ecx, %ebx
	   jl returnA #SAVE A 
    	   jge returnB
         returnA:
           movl oldDist-1*4(,%eax,ws), %ecx 
	   #min(oldDist[j],oldDist[j-1])
	   cmpl %ecx, %ebx
           jl retA #save (a)
	   jge retB #save (b)
         returnB:
	    movl %ecx, %ebx #min(curDist[j-1], oldDist[j-1])
	    movl oldDist-1*4(,%eax,ws), %ecx #(b) oldDist[j-1]
	    cmpl %ecx, %ebx 
	    jl retA 
	    jge retB
	 retA:
            addl $1, %ebx #(a)oldDist[j]+1  or curDist[j-1]+1
	    movl %ebx, curDist(,%eax,ws) #curDist[j]
            incl %eax #j++
	    jmp inside_for
	 retB:
	    addl $1, %ecx #(b) oldDist[j-1]
	    movl %ecx, curDist(,%eax,ws) #curDist[j] = oldDist[j-1]
            incl %eax #j++
	    jmp inside_for     
	end_outside:
	    subl $1, strlen2 #return strlen2 back to normal
	    movl strlen2, %ebx     
	    movl oldDist(,%ebx,ws), %eax #putting dist in eax
	    ret
	swapcall:
	  #SWAP#
	 movl $0, %edi #swap itr
         str_swap:
	     movl curDist(,%edi, ws), %ebx
	     movl %ebx, oldDist(,%edi,ws)
	     cmpl strlen2, %edi #edi = edi-strlen+1 < 0
	     jge end_swap
	     incl %edi
	     jmp str_swap
	 end_swap:
             incl %edx #i++
	     movl $1, %eax #set j back to 1
	     jmp outside_for
_start:
    call editDist
done:
 	movl %eax, %eax

		
