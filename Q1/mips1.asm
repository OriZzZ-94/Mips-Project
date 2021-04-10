.data  
fileName1: .asciiz "D:\\desktop\\Studies\\part1 - mars\\mat1.txt"
fileName2: .asciiz "D:\\desktop\\Studies\\part1 - mars\\mat2.txt"
fileName3: .asciiz "D:\\desktop\\Studies\\part1 - mars\\Answer.txt"
str_data_end:
n1: .asciiz "\n"
n2: .ascii " "
buffer1: .space 1024
buffer2: .space 1024
buffer3: .space 1024
MATRIX1: .word 400
MATRIX2: .word 400
MATRIX3: .word 400



.text

# Open fileName1 file for reading
li   $v0, 13          # system call for open file
la   $a0, fileName1      # input file name
li   $a1, 0           # flag for reading
li   $a2, 0           # mode is ignored
syscall               # open a file 
move $s0, $v0         # save the file descriptor  
# Open fileName2 file for reading

li   $v0, 13          # system call for open file
la   $a0, fileName2      # input file name
li   $a1, 0           # flag for reading
li   $a2, 0           # mode is ignored
syscall               # open a file 
move $s1, $v0         # save the file descriptor  

# reading from fileName1 just opened
li   $v0, 14        # system call for reading from file
move $a0, $s0       # file descriptor 
la   $a1, buffer1    # address of buffer from which to read
li   $a2, 1024   # hardcoded buffer length
syscall             # read from file
la $t1,buffer1
# reading from fileName2 just opened
li   $v0, 14        # system call for reading from file
move $a0, $s1       # file descriptor 
la   $a1, buffer2    # address of buffer from which to read
li   $a2, 1024    # hardcoded buffer length
syscall # read from file 
la $t2,buffer2   


# Close the file1 
li   $v0, 16       # system call for close file
move $a0, $s0      # file descriptor to close
syscall  # close file

# Close the file2 
li   $v0, 16       # system call for close file
move $a0, $s1      # file descriptor to close
syscall            # close file
            
#Matrix 1 allocate
li $v0, 9
lw $a0, MATRIX1
syscall                 
sw $v0, MATRIX1
move $s0, $v0 


#Matrix 2 allocate
 li $v0, 9
lw $a0, MATRIX2
syscall                 
sw $v0, MATRIX2
move $s1, $v0 

#Matrix 3 allocate
 li $v0, 9
lw $a0, MATRIX3
syscall                 
sw $v0, MATRIX3
move $s2, $v0 

# insert to array 1
#Vals
li $t7,' '
li $t4,'\n'
li $t0,0
li $t9,10
li $t5,0
la $t8,($s0)
# Array 1
Loop1:
jal Space_checker
lb $s4,-1($t1)
beq $t4,$s4,skip1
jal Insert_Int_to_Matrix
bne $t9,$t0,Loop1
skip1:
addi $t0,$t0,1
beq $t9,$t0,Arr2
bne $t9,$t0,Loop1


#insert to array 2
# Array 2
Arr2:
li $t0,0
li $t5,0
move $t1,$t2
la $t8,($s1)
Loop2:
jal Space_checker
lb $s4,-1($t1)
beq $t4,$s4,skip2
jal Insert_Int_to_Matrix
bne $t9,$t0,Loop2
skip2:
addi $t0,$t0,1
bne $t9,$t0,Loop2


## mul Arrays and insert to Array 3
la $t1 ($s0) # load adress of array 1
la $t2 ($s1) # load adress of array 2
la $t3 ($s2) # load adress of array 3
li $t8 0 # Counter out loop
li $t7 0 # Counter in loop
li $t4 0 # sum
li $t5 100 
li $t9 10
li $t6 0
Line:
jal Mul
sw $t4,0($t3)
li $t4,0
addi $t3,$t3,4
li $t7 0 # Initializing inner loop counter
addi $t2,$t2,4 # Next Column
addi $t1,$t1,-40 #  back to begin Row
addi $t8,$t8,1 # counter for the loop 
addi $t6,$t6,1 # counter for the loop 
bne $t9,$t8,Line
li $t8 0 # Counter out loop
addi $t2,$t2,-40 #back to begin Column
addi $t1,$t1,40 # Next Row
bne $t5,$t6,Line

#Answer buffer allocate
li $v0, 9
li $a0,1024
syscall                                 
la $s0,($v0)

#file 3 opening for write
    li $v0, 13
    la $a0, fileName3
    li $a1, 1
    li $a2, 0
    syscall  # File descriptor gets returned in $v0
    
#vals 
la $s3,buffer3
la $t8,($s2)
li $s7,100
li $t3,0
li $v1,0
L1:
lw $t1,($t8)
addi $t8,$t8,4
jal Change_int_to_string
addi $t3,$t3,1
addi $v1,$v1,1
beq $v1,10,pspace
bne $s7,$t3,L1
pspace:
li $v1,0
#write the \n
la $a0,n1  
sb $a0,($s3)
addi $s3,$s3,1
li $v0, 4
syscall
bne $t3,100,L1
#la $a1, n1
#sb $a1,0($t7)



#write the line
la $a0,fileName3  # Syscall 15 requieres file descriptor in $a0
li $v0, 15
move  $s0,$a1
li $a2,1024
syscall

file_close:
 li $v0, 16  # $a0 already has the file descriptor
   syscall

li $v0, 10      # Finish the Program
syscall






#######################################################################Functions#########################################################################################
#function change to int
# t3 - the char to int.
# t6 - char to transform.
# t5 - mult in 10 evrey digit.
Change_to_int:
mul $t5,$t5,10
addi $t3,$t6,-48
add $t5,$t5,$t3
jr $ra


#function counts chars until space
# t1- the string you run
# t7- space for condition
# t4-run on the buffer
# s6- return
Space_checker:
addi $sp,$sp,-4
sw $ra,0($sp)
la $ra,Space_checker
la $ra,36($ra)
loop1:
lb $t6,0($t1)
beq $t4,$t6,exit # if its end line
bne $t7,$t6,Change_to_int #if its a space
addi $t1,$t1,1 #next char
bne $t7,$t6,loop1  #is the char at the position we entered?
lw $ra,0($sp)
addi $sp,$sp,4
jr $ra
exit:
addi $t1,$t1,1 #next char
lw $ra,0($sp)
addi $sp,$sp,4
jr $ra



#function insert int to matrix
# t8- Matrix int adress
# t5- The int from Change_to_int func
# s6- return
Insert_Int_to_Matrix:
addi $sp,$sp,-4
sw $s6,0($sp)
sw $t5,0($t8)
addi $t8,$t8,4
li $t5,0
lw $s6,0($sp)
addi $sp,$sp,4
jr $ra

#function Mux int to matrix 3
# s5- Mul answer
# t9- 10 rounds
# t7 -index
# t4 - sum register
# t1 -Runs on the Row
# t2 - Runs on the Column
# t0- argument
# s7- argument
# s6- return

Mul:
lw $t0,0($t1)
lw $s7,0($t2)
addi $sp,$sp,-4
sw $s6,0($sp)
mul $s5,$s7,$t0  #Mult between 2 arguments from 2 arrays.
add $t4,$t4,$s5 # sum
addi $t1,$t1,4 # Runs on the Row
addi $t2,$t2,40 # Runs on the Column
addi $t7,$t7,1 # counter for the loop 
bne $t9,$t7,Mul
addi $t2,$t2,-400
jr $ra

#function Mux int to matrix 3
#t0 - counter
#t1- number
#s5-div number for insert back
#t2-static 10
#t4-Remainder
#t7-string allocate

Change_int_to_string:
la $s5,0($t1)
la $t7,0($s0)
li $t0,1
li $t2,10
Div:
#count the number digits
div $t1,$t1,$t2  #Div number
mfhi $t4 #Reminder
addi $t0,$t0,1 #count number digits
bne $t1,$zero,Div
add $t1,$zero,$t0
mul $t0,$t0,4
#mover the stack and insert space
sub $sp,$sp,$t0 #move stack to number
lb $s6,n2 
sb  $s6,0($sp)
addi $t0,$t0,-4
addi $sp,$sp,4
return:
#transer the digit to char
div $s5,$s5,$t2  #Div number
mfhi $t4 #Reminder
addi $s6,$t4,48
sw  $s6,0($sp) #insert to stack digit digit the num
#inset the digits to stack
addi $t0,$t0,-4
addi $sp,$sp,4
bne $t0,0,return
li $s6,0
string: # insert the num to string with space
addi $sp,$sp,-4
lw $s4,0($sp)
sw $zero,0($sp)
sb $s4,0($t7)
addi $t7,$t7,1
addi $t1,$t1,-1
addi $s6,$s6,1
bne $t0,$t1,string
mul $s6,$s6,4
sub $sp,$sp,$s6
sb $t7,0($s3)
addi $s3,$s3,1
#write the line to the file
la $a0,($v0)  # Syscall 15 requieres file descriptor in $a0
li $v0, 15
la $a1,0($s3)
lb $a2,($s3)
syscall
#print
la $a0,0($s0)  
li $v0, 4
syscall
jr $ra
