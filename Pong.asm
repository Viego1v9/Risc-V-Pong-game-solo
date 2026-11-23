.global Main
.eqv DIS_BASE_ADRESS  0x10010000
.eqv WHITE 0xFFFFFF
.eqv ROW_OFFSET 256
.eqv NEXT_PIXEL 4
.eqv TOTAL_BYTES 2048
.eqv BLACK 0x000000
.eqv KB_CONTROL 0xFFFF0000
.eqv KB_DATA 0xFFFF0004
.eqv DIS_UPPER_BOUND 28
.eqv DIS_LOWER_BOUND 0
Main:
	li s0 , 14 #Y-coordinate of player 1
	li s1 , 14 #Y-coordinate of player 2(AI)
	li s2 , 32 #X-coordinate of the ball
	li s3 , 16 #Y-coordinate of the ball
	li s4 , -1 #X-ball velocity
	li s5 , 1  #Y-ball velocity
	li s6 , 60 #Instead of updating the velocity we update how fast the frames change

	call countdown_start
	
	call draw_ball
	li a3 , BLACK
game_start:
	
	#Erase old positions
	call remove_ball
	call remove_paddle
	
	#Read and update the state
	call keyboard_movement
	call updating_player_paddle
	call p2_update_movement
	call move_ball
	call ball_collision
	
	#Drawing the new positions
	call paddles
	call draw_ball
	
	
	
	add a0 , s6 , zero          
	li a7 , 32
	ecall
	
j game_start
	
	

	li a7 , 10
	li a0 , 0
	ecall
	

draw_horizontal_line:
	li t0 , DIS_BASE_ADRESS
	#Turn the Y and X coordinates into a memory offset
	slli t1 , a1 , 8
	slli t2 , a0 , 2
	#Adding the offsets to the base adress
	add t0 , t0 , t2
	add t0 , t0 , t1
	li t1 , 1 #Loop counter
	
horizontal_line_loop:
	bgt t1 , a2 , horizontal_done
	sw a3 , 0(t0)
	addi t0 , t0 , NEXT_PIXEL
	addi t1 , t1 ,1
	j horizontal_line_loop
	
horizontal_done:
	ret

draw_vertical_line:
	li t0 , DIS_BASE_ADRESS
	#Turn the Y and X coordinates into a memory offset
	slli t1 , a1 , 8
	slli t2 , a0 , 2
	add t0 , t0 , t2 #Adding the memory offsets X axis
	add t0 , t0 , t1 #Adding the memory offsets Y axis
	li t1 , 1 #Loop counter

vertical_line_loop:
	bgt t1 , a2 , vertical_done
	sw a3 , 0(t0) #Turn the pixel white
	addi t0 , t0 ,  ROW_OFFSET  #Move to the new Y pixel
	addi t1 , t1 , 1
	j vertical_line_loop
	
vertical_done:
	ret
	
wipe_screen:
	li t0 , DIS_BASE_ADRESS
	li t1 , 1 #Loop counter
	li t2 , TOTAL_BYTES
	#Loop through all pixels once and turn them black
wipe_screen_loop:
	bgt t1 , t2 , wipe_screen_done
	sw a3 , 0(t0)
	addi t0 , t0 , NEXT_PIXEL
	addi t1 , t1 , 1
	j wipe_screen_loop
	
wipe_screen_done:
	ret
	

paddles:
	addi sp , sp , -4
	sw ra , 0(sp)
	li a0 , 0 #Passing the X coordinate
	add a1 , zero , s0 #Passing the Y coordiante
	li a2 , 4 #Passing the length of the line
	li a3 , WHITE #Passing the color of the pixel
	call draw_vertical_line
	
	li a0 , 63
	add a1 , zero , s1
	call draw_vertical_line
	
	lw ra, 0(sp)
	addi sp , sp , 4
paddles_done:
	ret
	
keyboard_movement:
	li t0 , KB_CONTROL
	lw t1 , 0(t0)
	beq t1 , zero , no_input
	li t0 , KB_DATA
	lw a0 , 0(t0)
	ret
no_input:
	li a0 , 0
	ret
	
updating_player_paddle:
	li t0 , 97 #ASCII value of A(up)
	beq a0 , t0 , move_p1_up
	beq a0 , zero , paddle_check_done
	li t0 , 100
	beq a0 , t0 , move_p1_down
	j paddle_check_done
	
move_p1_down:
	addi s0 , s0 , 2
	j paddle_check

move_p1_up:
	addi s0 , s0 , -2

paddle_check:
	li t0 , DIS_UPPER_BOUND
	bge s0 , t0 , hit_bottom_wall
	
	li t0 , DIS_LOWER_BOUND
	ble s0 , t0 , hit_top_wall
	j paddle_check_done
	
paddle_check_done:
	ret

hit_bottom_wall:
	li s0 , DIS_UPPER_BOUND
	ret

hit_top_wall:
	li s0 , DIS_LOWER_BOUND
	ret


remove_paddle:
	addi sp , sp , -4
	sw ra , 0(sp)
	#Drawing the old position of P1 black (erasing)
	li a0 , 0
	add a1 , zero , s0
	li a2 , 4
	li a3 , BLACK
	call draw_vertical_line
	
	#Sme for P2
	li a0 , 63
	add a1 , zero , s1
	li a2 , 4
	li a3 , BLACK
	call draw_vertical_line
	lw ra , 0(sp)
	addi sp , sp , 4
remove_paddle_done:
	ret
	
draw_ball:
	addi sp , sp , -4
	sw ra , 0(sp)
	add a0 , s2 , zero 
	add a1 , s3 , zero
	li a2 , 1
	li a3 , WHITE
	call draw_vertical_line
	lw ra , 0(sp)
	addi sp , sp , 4
draw_ball_done:
	ret
	
remove_ball:
	addi sp , sp , -4
	sw ra , 0(sp)
	add a0 , s2 , zero 
	add a1 , s3 , zero
	li a2 , 1
	li a3 , BLACK
	call draw_vertical_line
	lw ra , 0(sp)
	addi sp , sp , 4
remove_ball_done:
	ret

move_ball:
	add s2 , s2 , s4
	add s3 , s3 , s5
	ble s3 , zero , bounce_top
	li t0 , 31
	bge s3 , t0 , bounce_bottom
move_ball_done:
	ret

bounce_top:
	li s3 , 0
	li s5 , 1
	ret
bounce_bottom:
	li s3 , 31
	li s5 , -1
	ret

ball_collision:
	li t0 , 1
	bgt s2 , t0 , check_p2_collision #If the ball isnt near p1's paddle check p2's paddle
	bge s4 , zero , check_p2_collision #Same if its moving right and not left(ux < 0)
	
	blt s3 , s0 , p1_lost #Check if player 1 misses the ball
	addi t1 , s0 , 3
	bgt s3 , t1 , p1_lost
	li s2 , 1
	sub s4 , zero , s4
	sub t0 , s3 , s0
	j set_angle
check_p2_collision:
	li t0 , 62
	blt s2 , t0 , no_collision
	ble s4 , zero , no_collision
	
	blt s3 , s1 , p2_lost
	addi t1 , s1 , 3
	bgt s3 , t1 , p2_lost
	li s2 , 62
	sub s4 , zero , s4
	sub t0 , s3 , s1
	j set_angle
no_collision : ret #Nothing Ever Happens

set_angle:
	li t1 , 15
	ble s6 , t1 , skip_speedup
	addi s6 , s6 , -5
skip_speedup:
	beq t0 , zero , angle_up #If the ball hits the top of the paddle set the velocity to a positive number
	li t1 , 3
	beq t0 , t1 , angle_down #If the ball hits the bottom of the paddle set the velocitty to a negative number
	ret
angle_up:
	li s5 , -1
	ret
angle_up_done:

angle_down:
	li s5 , 1
	ret
angle_down_done:
	
p1_lost:
	li a0 , 76                           # ASCII 'L'
	li a7 , 11                           # Print char to RARS Run I/O
	ecall
	j game_over

p2_lost:
	li a0 , 87                           # ASCII 'W'
	li a7 , 11                           # Print char to RARS Run I/O
	ecall

game_over:
	li a7 , 10                           # Exit program
	ecall

p2_update_movement:
	li t1 , 25 #P2 starts moving only if the ball is over the nth pixel
	bgt s2 , t1 , update_p2
	ret
update_p2:
	addi t1 , s1 , 2
	beq s3 , t1 , p2_stays
	blt s3 , t1 , p2_up
	bgt s3 , t1 , p2_down
p2_up:
	addi s1 , s1 , -1
	li t0 , DIS_LOWER_BOUND
	blt s1 , t0 , lower_bound
	ret
lower_bound:
	li s1 , DIS_LOWER_BOUND
	ret
p2_down:
	addi s1 , s1 , 1
	li t0 , DIS_UPPER_BOUND
	bgt s1 , t0 , upper_bound
	ret
upper_bound:
	li s1 , DIS_UPPER_BOUND
p2_stays:
	ret
p2_movement_done:


countdown_start:
	addi sp , sp , -4
	sw ra , 0(sp)
draw3:
	call wipe_screen
	li a0 , 38 #Passing the X coordianate 
	li a1 , 4  #Passing the Y coordinate
	li a2 , 25 # Length of the line
	li a3 , WHITE #Color of pixel
	call draw_vertical_line
	
	li a0 , 26 #Passing the X coordinate
	li a2 , 12 #Length of the line
	call draw_horizontal_line
	
	li a1 , 16 #Passing the Y coordinate
	li a2 , 12
	call draw_horizontal_line
	
	li a1 , 28
	li a2 , 12
	call draw_horizontal_line
done3:
	#Letting each number stay for 750ms before going to the next one
	li a0 , 750
	li a7 , 32
	ecall
	
	
	li a3 , BLACK
	call wipe_screen

draw2:
	li a0 , 32 #Passing the X coordinate
	li a1 , 28  #Passing the Y coordinate
	li a2 , 8 #Passing the length of the line
	li a3 , WHITE #Passing the color of the pixel
	
	call draw_horizontal_line
	
	li a1 , 25
	li a2 , 3
	call draw_vertical_line
	
	li a0 , 33
	li a1 , 22
	li a2 , 3
	call draw_vertical_line
	
	li a0 , 34
	li a1 , 19
	call draw_vertical_line
	
	li a0 , 35
	li a1 , 16
	call draw_vertical_line
	
	li a0 , 36
	li a1 , 13
	call draw_vertical_line
	
	li a0 , 37
	li a1 , 10
	call draw_vertical_line
	
	li a0 , 38
	li a1 , 8
	li a2 , 2
	call draw_vertical_line
	
	li a1 , 7
	li a0 , 32
	li a2 , 6
	call draw_horizontal_line
	
	li a1 , 8
	li a0 , 31
	li a2 , 5
	call draw_vertical_line
done2:

	#Letting each number stay for 750 before going to the next one
	li a0 , 750
	li a7 , 32
	ecall
	
	li a3 , BLACK
	call wipe_screen
	
draw1:
	li a0 , 32 #Passing the X coordianate 
	li a1 , 4  #Passing the Y coordinate
	li a2 , 25 # Length of the line
	li a3 , WHITE #Color of pixel
	call draw_vertical_line
done1:
	#Letting each number stay for 750ms before going to the next one
	li a0 , 750
	li a7 , 32
	ecall
	
	
	li a3 , BLACK
	call wipe_screen
	lw ra , 0(sp)
	addi sp , sp , 4
dountdown_done:
	ret



	
	
