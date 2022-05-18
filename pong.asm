IDEAL
MODEL small
STACK 100h
DATASEG
    WINDOW_WIDTH dw 140h  ; 320 pixels
    WINDOW_HEIGHT dw 0c8h ; 200 pixels

;https://deskbright-media.s3.amazonaws.com/static/cms/images/articles/excel/rows-columns-and-cells/image1.jpg; --------------------------
    BALL_X dw 40h ; x position (column)
    BALL_Y dw 40h ; y position (row)
    BALL_SIZE dw 04h ;how many pixels the ball has in width and height
    BALL_VELOCITY_X dw 04h ; x axis ball speed
    BALL_VELOCITY_y dw 03h ; y axis ball speed

    BALL_ORIGINAL_X dw 0A1h ; the x center position
    BALL_ORIGINAL_Y dw 5Ah  ; the y center position

    PADDLE_X_1 dw 5h;the left paddle's x position
    PADDLE_Y_1 dw 5Ah;the left paddle's y position

    PADDLE_Y_ORIGINAL dw 5Ah;the original y position of the paddles

    PADDLE_X_2 dw 137h;the right paddle's x position
    PADDLE_Y_2 dw 5Ah;the right paddle's y position

    PADDLE_LEFT_POINTS db 0 ; the current amount of points that the left player has
    PADDLE_RIGHT_POINTS db 0 ; the current amount of points that the left player has
    POINTS_TO_WIN db 3 ;

    PADDLE_SIZE_X dw 4h;how many pixels the paddles have in width
    PADDLE_SIZE_Y dw 15h;how many pixels the paddles have in height
 
    PADDLES_VELOCITY dw 0ah ; the (vertical) speed of the paddles

    POINT_SIZE_X dw 02h;how many pixels the points have in width
    POINT_SIZE_Y dw 05h;how many pixels the points have in height

    GAME_ACTIVE dw 02h; the game mode, 00 = game over 01 = game 02 = main menu

    START_POINT_LEFT_X dw 10h;the starting left points' x position
    START_POINT_RIGHT_X dw 136h;the starting left points' x position
    POINT_Y dw 05h;the points' y position

    DISTANCE_BETWEEN_POINTS dw 10h;the amount of pixels between each point

    COUNTER dw, 0h;support variable

    STICK_SIZE_X dw 1h;how many sticks the points have in width
    STICK_SIZE_Y dw 8h;how many pixels the sticks have in height

    STICKS_AMOUNT db 0dh;the amount of sticks (13)
    DISTANCE_BETWEEN_STICKS dw 10h;the amount of pixels between each stick

    STICK_X dw 09fh;the sticks' x position
    STICK_Y_START dw 0;the starting sticks' y position

    WINNER_INDEX db 0;the winner, 01h = left 02h = right
    TEXT_GAME_OVER_TITLE db 'GAME OVER', '$' ;the game over title text

    ;the game over winners texts
    TEXT_GAME_OVER_WINNER_LEFT db 'LEFT player won', '$'
    TEXT_GAME_OVER_WINNER_RIGHT db 'RIGHT player won', '$'

    TEXT_GAME_OVER_PLAY_AGAIN db 'Press R to play again', '$';the game over play again text
    TEXT_GAME_OVER_MAIN_MENU db 'Press E to go to the menu', '$';the game over main menu text

    TEXT_MAIN_MENU_TITLE db 'PONG', '$';the main menu title text
    TEXT_MAIN_MENU_NAME db 'Aviv Ayalon', '$';the main menu name text

    ;the main menu controls texts
    TEXT_MAIN_MENU_LEFT_PLAYER db 'LEFT player   up: w', '$'
    TEXT_MAIN_MENU_LEFT_PLAYER_CONTINUE db 'LEFT player down: s', '$'
    TEXT_MAIN_MENU_RIGHT_PLAYER db 'RIGHT player   up: o', '$'
    TEXT_MAIN_MENU_RIGHT_PLAYER_CONTINUE db 'RIGHT player down: l', '$'



    TEXT_MAIN_MENU_QUIT_GAME db 'Press N to quit', '$';the main menu quit text

    TEXT_MAIN_MENU_PLAY db 'Press R to play', '$';the main menu play text

    NEEDED_RESTART dw 00h;checking if we need restatr 01h = yes

    RANDOM_PLACE dw 00h; the variable for the random starting y position of the ball

    TIME_AUX db 0 ; variable used when checking if time has changed

    
; --------------------------
CODESEG


;THE GAME OF PONG
;AVIV AYALON
start:
	mov ax, @data
	mov ds, ax

;opening the video
    mov ah, 00h ;video mode
    mov al, 13h ;video configuration 320x200
    int 10h


;coloring the background
    call CLEAR_BACKGROUND


    ;the game runs here
    CHECK_TIME:
        ;checking the game mode
        mov ax, [GAME_ACTIVE]
        cmp ax, 00h
        je SHOW_GAME_OVER
        cmp ax, 02h
        je SHOW_MENU

        mov ah, 2ch ; get the systen time
        int 21h ; ch = hour cl = minute dh = second dl = 1/100 seconds

        cmp dl, [TIME_AUX]
        je CHECK_TIME



        mov [TIME_AUX], dl; saving the time when we draw the ball



        ;getting here if there is a differnce in the time
        ;coloring the background and clearing it from the ball's former position
        call CLEAR_BACKGROUND

        call DRAW_STICKS
        ;changing the ball's position
        call MOVE_BALL
        ;drawing the ball
        call DRAW_BALL
        ;changing the paddles' positions 
        call MOVE_PADDLES
        ;drawing the paddles
        call DRAW_PADDLES
        ;drawing the points
        call DRAW_POINTS

        jmp CHECK_TIME


;drawing the points of each player
proc DRAW_POINTS
    call DRAW_LEFT_POINTS
    call DRAW_RIGHT_POINTS
    ret

;ordering the menu screen to be loaded
SHOW_MENU:
    call DRAW_GAME_MAIN_MENU
    jmp CHECK_TIME


;ordering the game over screen to be loaded
SHOW_GAME_OVER:
    call DRAW_GAME_OVER_MENU
    jmp CHECK_TIME


;draws the main menu
proc DRAW_GAME_MAIN_MENU
    ;draws the title PONG
    mov ah, 02h
    mov bh, 00h
    mov dh, 0ch;row
    mov dl, 12h;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_TITLE]
    int 21h
    
    ;draws my name Aviv Ayalon
    mov ah, 02h
    mov bh, 00h
    mov dh, 20h;row
    mov dl, 06h;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_NAME]
    int 21h

    ;draws the press n to quit text
    mov ah, 02h
    mov bh, 00h
    mov dh, 17h;row
    mov dl, 0ch;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_QUIT_GAME]
    int 21h
    ;draws the left player controls
    mov ah, 02h
    mov bh, 00h
    mov dh, 01h;row
    mov dl, 00h;column
    int 10h
    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_LEFT_PLAYER]
    int 21h

    mov ah, 02h
    mov bh, 00h
    mov dh, 03h;row
    mov dl, 00h;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_LEFT_PLAYER_CONTINUE]
    int 21h

    ;draws the right player controls
    mov ah, 02h
    mov bh, 00h
    mov dh, 01h;row
    mov dl, 14h;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_RIGHT_PLAYER]
    int 21h

    mov ah, 02h
    mov bh, 00h
    mov dh, 3h;row
    mov dl, 14h;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_RIGHT_PLAYER_CONTINUE]
    int 21h

    ;draws the press r to play text
    mov ah, 02h
    mov bh, 00h
    mov dh, 15h;row
    mov dl, 0ch;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_MAIN_MENU_PLAY]
    int 21h
    mov ah, 00h
    int 16h


    

    ;checking if r is being pressed
    cmp al, 72h ; 'r'
    je NEW_GAME
    cmp al, 52h ; 'R'
    je NEW_GAME
    ;checking if r is being pressed
    cmp al, 6eh ; 'n'
    je NEED_OUT
    cmp al, 4eh ; 'N'
    je NEED_OUT
    ret

NEED_OUT:
    call CLEAR_BACKGROUND
    call GO_OUT

    ;sets up a new game
proc NEW_GAME
        ;restarting the variables
        mov ax, [PADDLE_Y_ORIGINAL]
        mov [PADDLE_Y_1], ax
        mov [PADDLE_Y_2], ax
        mov [PADDLE_LEFT_POINTS], 0
        mov [PADDLE_RIGHT_POINTS], 0
        ;changing the game mode
        mov [GAME_ACTIVE],1

        call RESTART_BALL_POSITION
        call CLEAR_BACKGROUND

    
    
    ret



;draws the game over menu
proc DRAW_GAME_OVER_MENU
    ;draws the GAME OVER text
    mov ah, 02h
    mov bh, 00h
    mov dh, 04h;row
    mov dl, 04h;column
    int 10h
    mov ah, 09h
    lea dx, [TEXT_GAME_OVER_TITLE]
    int 21h

    ;draws the text of who won
    call DRAW_WINNER_TEXT

    ;draws the text of press r to play again
    mov ah, 02h
    mov bh, 00h
    mov dh, 08h;row
    mov dl, 04h;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_GAME_OVER_PLAY_AGAIN]
    int 21h

    ;draws the text of press e to go to the main menu
    mov ah, 02h
    mov bh, 00h
    mov dh, 0ah;row
    mov dl, 04h;column
    int 10h

    mov ah, 09h
    lea dx, [TEXT_GAME_OVER_MAIN_MENU]
    int 21h

    ;checks if r is being pressed
    mov ah, 00h
    int 16h
    
    cmp al, 72h ; 'r'
    je NEW_GAME
    cmp al, 52h ; 'R'
    je NEW_GAME

    ;check if e is being pressing
    cmp al, 65h ; 'e'
    je MAIN_MENU
    cmp al, 45h ; 'E'
    je MAIN_MENU



    ret

    ;goes to the main menu
    MAIN_MENU:
        ;restarting the variables
        mov ax, [PADDLE_Y_ORIGINAL]
        mov [PADDLE_Y_1], ax
        mov [PADDLE_Y_2], ax
        mov [PADDLE_LEFT_POINTS], 0
        mov [PADDLE_RIGHT_POINTS], 0
        ;changing the game mode
        mov [GAME_ACTIVE],2

        call RESTART_BALL_POSITION
        call CLEAR_BACKGROUND
    ret




;draws the text of the player that won
proc DRAW_WINNER_TEXT
    ;checks who won
    cmp [WINNER_INDEX], 01h
    jne Vouloir
    ;draws the text of the left player
    mov ah, 02h
    mov bh, 00h
    mov dh, 06h;row
    mov dl, 04h;column
    int 10h
    mov ah, 09h
    lea dx, [TEXT_GAME_OVER_WINNER_LEFT]
    int 21h
    ret
    ;draws the text of teh right player
    Vouloir:
        mov ah, 02h
        mov bh, 00h
        mov dh, 06h;row
        mov dl, 04h;column
        int 10h

        mov ah, 09h
        lea dx, [TEXT_GAME_OVER_WINNER_RIGHT]
        int 21h


    ret

;sets the game mode to game over
proc GAME_OVER
    call CLEAR_BACKGROUND
    mov [GAME_ACTIVE], 00h
    jmp CHECK_TIME



;restarts the ball's position
proc RESTART_BALL_POSITION
    mov [NEEDED_RESTART], 00h
    mov ax, [BALL_ORIGINAL_X]
    mov [BALL_X], ax

    ;generates a random y position
    call GENERATE_RANDOM_NUMBER_PLACE
    mov cx, [RANDOM_PLACE]
    mov [BALL_Y], cx

    ret



;giving a point to the right player and restarts the ball's position
proc POINT_TO_RIGHT_PLAYER
    mov [BALL_X], 0
    mov cx, [BALL_VELOCITY_Y]
    add [BALL_Y], cx

    inc [PADDLE_RIGHT_POINTS]
    mov al, [PADDLE_RIGHT_POINTS]
    cmp [POINTS_TO_WIN], al
    mov [WINNER_INDEX], 2

    je GAME_OVER
    neg [BALL_VELOCITY_X]
    mov [NEEDED_RESTART], 01h
    ret

;giving a point to the left player and restarts the ball's position
proc POINT_TO_LEFT_PLAYER
    mov ax, [WINDOW_WIDTH]
    sub ax, 1
    sub ax, [BALL_SIZE]
    
    mov [BALL_X], ax
    mov cx, [BALL_VELOCITY_Y]
    add [BALL_Y], cx

    inc [PADDLE_LEFT_POINTS]
    mov al, [PADDLE_LEFT_POINTS]
    cmp [POINTS_TO_WIN], al
    mov [WINNER_INDEX], 1
    je GAME_OVER
    neg [BALL_VELOCITY_X]
    mov [NEEDED_RESTART], 01h
    ret

;changing the ball's position
proc MOVE_BALL
        cmp [NEEDED_RESTART], 01h
        je RESTART_BALL_POSITION

        ;changing x position
        mov bx, [BALL_VELOCITY_X]
        add [BALL_X], bx
        ;changing x direction
        ;if the ball's x postion is 0
        cmp [BALL_X], 00h
        jl POINT_TO_RIGHT_PLAYER
        ;if the ball's x position is the window width
        mov bx, [WINDOW_WIDTH]
        sub bx, [BALL_SIZE]
        sub bx, 1

        cmp [BALL_X], bx
        jg POINT_TO_LEFT_PLAYER

        ;changing y direction
        ;if the ball's y postion is 0
        cmp [BALL_Y], 00h
        jl CHANGE_Y_DIRECTION
        ;if the ball's y position is the window height
        mov bx, [WINDOW_HEIGHT]
        sub bx, [BALL_SIZE]

        cmp [BALL_Y], bx
        jg CHANGE_Y_DIRECTION

        WHAR:
        ;changing y position
        mov cx, [BALL_VELOCITY_Y]
        add [BALL_Y], cx

        ;checking if the ball is touching the paddles
        call CHECK_PADDLES_BALL_COLISIONS

        RETURN_BALL:
            ret  ;returns to where to the place that called the procedure 

;changes the ball's y direction
proc CHANGE_Y_DIRECTION
    neg [BALL_VELOCITY_Y]
    jmp WHAR

;checks the colision of the paddles with the ball
proc CHECK_PADDLES_BALL_COLISIONS
    CHECK_LEFT_PADDLE_BALL_COLISION:
        ;checking the colision of the left paddle with the ball
        NEXT1:
            ;checkng the point x,y
            ;y
            mov ax, [PADDLE_Y_1]
            cmp [BALL_Y], ax
            jl NEXT2

            add ax, [PADDLE_SIZE_Y]
            cmp [BALL_Y], ax
            jg NEXT2
            ;x
            mov ax, [PADDLE_X_1]
            add ax, [PADDLE_SIZE_X]
            cmp [BALL_X], ax
            jg NEXT2

            sub ax, [PADDLE_SIZE_X]
            cmp [BALL_X], ax
            jl NEXT2

            cmp [BALL_VELOCITY_X], 0
            jg NEXT2
            neg [BALL_VELOCITY_X]
            ret
        NEXT2:
            ;checkng the point x,y + size
            ;y + size
            mov ax, [PADDLE_Y_1]
            sub ax, [BALL_SIZE];;;;
            cmp [BALL_Y], ax
            jl NEXT3
            add ax, [PADDLE_SIZE_Y]
            cmp [BALL_Y], ax
            jg NEXT3
            ;x
            mov ax, [PADDLE_X_1]
            add ax, [PADDLE_SIZE_X]
            cmp [BALL_X], ax
            jg NEXT3
            sub ax, [PADDLE_SIZE_X]
            cmp [BALL_X], ax

            jl NEXT3
            cmp [BALL_VELOCITY_X], 0
            jg NEXT3
            neg [BALL_VELOCITY_X]
            ret

;optional collision for the left paddle with the ball
        NEXT3:
            ;checkng the point checkng the point x + size,y
            ;y
            ;mov ax, [PADDLE_Y_1]
            ;cmp [BALL_Y], ax
            ;jl NEXT4
            ;add ax, [PADDLE_SIZE_Y]
            ;cmp [BALL_Y], ax
            ;jg NEXT4
            ;x + size
            ;mov ax, [PADDLE_X_1]
            ;sub ax, [BALL_SIZE];;;;
            ;add ax, [PADDLE_SIZE_X]
            ;cmp [BALL_X], ax
            ;jg NEXT4
            ;sub ax, [PADDLE_SIZE_X]
            ;cmp [BALL_X], ax
            ;jl NEXT4
            ;cmp [BALL_VELOCITY_X], 0
            ;jg NEXT4
            ;neg [BALL_VELOCITY_X]
            ;ret

        NEXT4:
            ;checkng the point x + size,y + size
            ;y + size
            ;mov ax, [PADDLE_Y_1]
            ;sub ax,  [BALL_SIZE];;;;
            ;cmp [BALL_Y], ax
            ;jl CHECK_RIGHT_PADDLE_BALL_COLISION
            ;add ax, [PADDLE_SIZE_Y]
            ;cmp [BALL_Y], ax
            ;jg CHECK_RIGHT_PADDLE_BALL_COLISION
            ;x + size
            ;mov ax, [PADDLE_X_1]
            ;sub ax, [BALL_SIZE];;;;
            ;add ax, [PADDLE_SIZE_X]
            ;cmp [BALL_X], ax
            ;jg CHECK_RIGHT_PADDLE_BALL_COLISION
            ;sub ax, [PADDLE_SIZE_X]
            ;cmp [BALL_X], ax
            ;jl CHECK_RIGHT_PADDLE_BALL_COLISION
            ;cmp [BALL_VELOCITY_X], 0
            ;jg CHECK_RIGHT_PADDLE_BALL_COLISION
            ;neg [BALL_VELOCITY_X]
            ;ret
    ;checking the colision of the right paddle with the ball
    CHECK_RIGHT_PADDLE_BALL_COLISION:
        NEXT5:
            ;checkng the point x,y
            ;y
            mov ax, [PADDLE_Y_2]
            cmp [BALL_Y], ax
            jl NEXT6

            add ax, [PADDLE_SIZE_Y]
            cmp [BALL_Y], ax
            jg NEXT6

            ;x
            mov ax, [BALL_X]
            add ax, [BALL_SIZE]
            cmp ax, [PADDLE_X_2]
            jl NEXT6

            sub ax, [PADDLE_SIZE_X]
            cmp [BALL_X], ax
            jg NEXT6

            cmp [BALL_VELOCITY_X], 0
            jl NEXT6
            neg [BALL_VELOCITY_X]
            ret
        NEXT6:
            ;checkng the point x,y + size
            ;y + size
            mov ax, [PADDLE_Y_2]
            sub ax,  [BALL_SIZE]; + size
            cmp [BALL_Y], ax
            jl NEXT7

            add ax, [PADDLE_SIZE_Y]
            cmp [BALL_Y], ax
            jg NEXT7

            ;x
            mov ax, [BALL_X]
            add ax, [BALL_SIZE]
            cmp ax, [PADDLE_X_2]
            jl NEXT7

            sub ax, [PADDLE_SIZE_X]
            cmp [BALL_X], ax
            jg NEXT7

            cmp [BALL_VELOCITY_X], 0
            jl NEXT7
            neg [BALL_VELOCITY_X]
            ret

;optional collision for the right paddle with the ball
        NEXT7:
            ;checkng the point checkng the point x + size,y
            ;y
            ;mov ax, [PADDLE_Y_2]
            ;cmp [BALL_Y], ax
            ;jl NEXT8
            ;add ax, [PADDLE_SIZE_Y]
            ;cmp [BALL_Y], ax
            ;jg NEXT8
            ;x + size
            ;mov ax, [BALL_X]
            ;sub ax, [BALL_SIZE]
            ;add ax, [BALL_SIZE]
            ;cmp ax, [PADDLE_X_2]
            ;jl NEXT8
            ;cmp [BALL_VELOCITY_X], 0
            ;jl NEXT8
            ;neg [BALL_VELOCITY_X]
            ;ret
        NEXT8:
            ;checkng the point checkng the point x + size,y + size
            ;y + size
            ;mov ax, [PADDLE_Y_2]
            ;sub ax, [BALL_SIZE]
            ;cmp [BALL_Y], ax
            ;jl RENT
            ;add ax, [PADDLE_SIZE_Y]
            ;cmp [BALL_Y], ax
            ;jg RENT
            ;x + size
            ;mov ax, [BALL_X]
            ;sub ax, [BALL_SIZE]
            ;add ax, [BALL_SIZE]
            ;cmp ax, [PADDLE_X_2]
            ;jl RENT
            ;cmp [BALL_VELOCITY_X], 0
            ;jl RENT
            ;neg [BALL_VELOCITY_X]
            ;ret

    RENT:
        ret


;clears the background
proc CLEAR_BACKGROUND
    mov ah, 06h    ; Scroll up function
    xor al, al     ; Clear entire screen
    xor cx, cx     ; Upper left corner CH=row, CL=column
    mov dh, 199    ; lower right corner DH=row, DL=column **
    mov dl, 39

    mov bh, 00h	 ; color black
    int 10h

    ret





;draws the ball
proc DRAW_BALL
    mov cx, [BALL_X] ; initial column (x)
    mov dx, [BALL_Y] ; initial row (y)
    DRAW_BALL_PIXELS:
        ; draws a pixel in a row
        mov ah, 0ch
        mov al, 0ah ;color white
        mov bh, 00h ;set the page number
        int 10h
        inc cx ; x = x + 1

        ;checking if we need to draw more pixels in the same row
        mov ax, cx
        sub ax, [BALL_X]

        cmp ax, [BALL_SIZE]
        jng DRAW_BALL_PIXELS


        ; if all the pixels in a row were drawn
        ; proceeds to the next row
        mov cx, [BALL_X]  ;sets x position to 0
        inc dx ; y = y + 1

        ;checking if we need to draw more rows
        mov ax, dx
        sub ax, [BALL_Y]

        cmp ax, [BALL_SIZE]
        jng DRAW_BALL_PIXELS


    
    ret  ;returns to where to the place that called the procedure 

;draws the points of the left player
proc DRAW_LEFT_POINTS

    mov cx, [START_POINT_LEFT_X] ; initial column (x)
    mov dx, [POINT_Y] ; initial row (y)
    mov [COUNTER], cx;saves the original starting point it's original value
    mov bl, 0 


    IFF:
        ;checks if we need to draw more points
        cmp bl, [PADDLE_LEFT_POINTS]
        je SYYNTA

        inc bl
        ;moving the position for the next point
        mov ax, [DISTANCE_BETWEEN_POINTS]
        add [START_POINT_LEFT_X], ax
        mov cx, [START_POINT_LEFT_X] ; initial column (x)
        mov dx, [POINT_Y] ; initial row (y)

        DRAW_POINT_PIXELS:
            ; draws a pixel in a row
            mov ah, 0ch
            mov al, 0eh ;color yellow
            mov bh, 00h ;set the page number
            int 10h
            inc cx ; x = x + 1

            ;checking if we need to draw more pixels in the same row
            mov ax, cx
            sub ax, [START_POINT_LEFT_X]

            cmp ax, [POINT_SIZE_X]
            jng DRAW_POINT_PIXELS


            ; if all the pixels in a row were drawn
            ; proceeds to the next row
            mov cx, [START_POINT_LEFT_X]  ;sets x position to 0
            inc dx ; y = y + 1

            ;checking if we need to draw more rows
            mov ax, dx
            sub ax, [POINT_Y]

            cmp ax, [POINT_SIZE_Y]
            jng DRAW_POINT_PIXELS

        jmp IFF

        SYYNTA:
            mov cx, [COUNTER]
            mov [START_POINT_LEFT_X], cx ;returns the original starting point it's original value
            ret

;draws the points of the right player
proc DRAW_RIGHT_POINTS

    mov cx, [START_POINT_RIGHT_X] ; initial column (x)
    mov dx, [POINT_Y] ; initial row (y)
    mov [COUNTER], cx;saves the original starting point it's original value
    mov bl, 0 


    IFFF:
        ;checks if we need to draw more points
        cmp bl, [PADDLE_RIGHT_POINTS]
        je SYYNTAA

        inc bl
        ;moving the position for the next point
        mov ax, [DISTANCE_BETWEEN_POINTS]
        sub [START_POINT_RIGHT_X], ax

        mov cx, [START_POINT_RIGHT_X] ; initial column (x)
        mov dx, [POINT_Y] ; initial row (y)

        DRAW_POINT_PIXELS2:
            ; draws a pixel in a row
            mov ah, 0ch
            mov al, 0eh ;color yellow
            mov bh, 00h ;set the page number
            int 10h
            inc cx ; x = x + 1

            ;checking if we need to draw more pixels in the same row
            mov ax, cx
            sub ax, [START_POINT_RIGHT_X]

            cmp ax, [POINT_SIZE_X]
            jng DRAW_POINT_PIXELS2


            ; if all the pixels in a row were drawn
            ; proceeds to the next row
            mov cx, [START_POINT_RIGHT_X]  ;sets x position to 0
            inc dx ; y = y + 1

            ;checking if we need to draw more rows
            mov ax, dx
            sub ax, [POINT_Y]

            cmp ax, [POINT_SIZE_Y]
            jng DRAW_POINT_PIXELS2

        jmp IFFF

        SYYNTAA:
            mov cx, [COUNTER];returns the original starting point it's original value
            mov [START_POINT_RIGHT_X], cx
            ret

;draws the sticks in the middle
proc DRAW_STICKS

    mov cx, [STICK_X] ; initial column (x)
    mov dx, [STICK_Y_START] ; initial row (y)
    mov [COUNTER], dx;saves the original starting stick it's original value
    mov bl, 0 
    mov ax, [DISTANCE_BETWEEN_STICKS]
    sub [STICK_Y_START], ax


    IFF3:
        ;checks if we need to draw more sticks
        cmp bl, [STICKS_AMOUNT]
        je SYYYNTA

        inc bl
        ;moving the position for the next stick
        mov ax, [DISTANCE_BETWEEN_STICKS]
        add [STICK_Y_START], ax
        mov dx, [STICK_Y_START]
        mov cx, [STICK_X]


        DRAW_POINT_PIXELS3:
            ; draws a pixel in a row
            mov ah, 0ch
            mov al, 0ch ;color red
            mov bh, 00h ;set the page number
            int 10h
            inc cx ; x = x + 1

            ;checking if we need to draw more pixels in the same row
            mov ax, cx
            sub ax, [STICK_X]
            cmp ax, [STICK_SIZE_X]
            jng DRAW_POINT_PIXELS3


            ; if all the pixels in a row were drawn
            ; proceeds to the next row
            mov cx, [STICK_X]  ;sets x position to 0
            inc dx ; y = y + 1

            ;checking if we need to draw more rows
            mov ax, dx
            sub ax, [STICK_Y_START]

            cmp ax, [STICK_SIZE_Y]
            jng DRAW_POINT_PIXELS3

        jmp IFF3

        SYYYNTA:
            mov dx, [COUNTER];returns the original starting stick it's original value
            mov [STICK_Y_START], dx
            ret


;draws the two paddles
proc DRAW_PADDLES
    call DRAW_PADDLE_1
    call DRAW_PADDLE_2

    ret

;draws the left paddle
proc DRAW_PADDLE_1
    mov cx, [PADDLE_X_1] ; initial column (x)
    mov dx, [PADDLE_Y_1] ; initial row (y)
    DRAW_PADDLE_PIXELS_1:
        ; draws a pixel in a row
        mov ah, 0ch
        mov al, 0fh ;color white
        mov bh, 00h ;set the page number
        int 10h
        inc cx ; x = x + 1

        ;checking if we need to draw more pixels in the same row
        mov ax, cx
        sub ax, [PADDLE_X_1]

        cmp ax, [PADDLE_SIZE_X]
        jng DRAW_PADDLE_PIXELS_1


        ; if all the pixels in a row were drawn
        ; proceeds to the next row
        mov cx, [PADDLE_X_1]  ;sets x position to 0
        inc dx ; y = y + 1

        ;checking if we need to draw more rows
        mov ax, dx
        sub ax, [PADDLE_Y_1]

        cmp ax, [PADDLE_SIZE_Y]
        jng DRAW_PADDLE_PIXELS_1


    
    ret  ;returns to where to the place that called the procedure 



;draws the rgiht paddle
proc DRAW_PADDLE_2
    mov cx, [PADDLE_X_2] ; initial column (x)
    mov dx, [PADDLE_Y_2] ; initial row (y)
    DRAW_PADDLE_PIXELS_2:
        ; draws a pixel in a row
        mov ah, 0ch
        mov al, 0fh ;color white
        mov bh, 00h ;set the page number
        int 10h
        inc cx ; x = x + 1

        ;checking if we need to draw more pixels in the same row
        mov ax, cx
        sub ax, [PADDLE_X_2]

        cmp ax, [PADDLE_SIZE_X]
        jng DRAW_PADDLE_PIXELS_2


        ; if all the pixels in a row were drawn
        ; proceeds to the next row
        mov cx, [PADDLE_X_2]  ;sets x position to 0
        inc dx ; y = y + 1

        ;checking if we need to draw more rows
        mov ax, dx
        sub ax, [PADDLE_Y_2]

        cmp ax, [PADDLE_SIZE_Y]
        jng DRAW_PADDLE_PIXELS_2


    
    ret  ;returns to where to the place that called the procedure 


proc MOVE_PADDLES
    ;left paddle's movement

    ;check if any key is being pressed
    mov ah, 01h
    int 16h
    jz CHECK_2_PADDLE_MOVEMENT  ;jemps if zf = 1 
    ;check which key is being pressed (al = ASCII charachter)

    mov ah, 00h
    int 16h
    ;if it is 'w' or 'W' move up
    cmp al, 77h ; 'w'
    je MOVE_1_PADDLE_UP
    cmp al, 57h ; 'W'
    je MOVE_1_PADDLE_UP
    ;if it is 's' or 'S' move down
    cmp al, 73h ; 's'
    je MOVE_1_PADDLE_DOWN
    cmp al, 53h ; 'S'
    je MOVE_1_PADDLE_DOWN 

    jmp CHECK_2_PADDLE_MOVEMENT


    ; moves the left paddle up if needed
    MOVE_1_PADDLE_UP:
        mov ax, [PADDLES_VELOCITY]
        sub [PADDLE_Y_1], ax

        cmp [PADDLE_Y_1], 00h
        jl FIX_PADDLE_1_TOP

        jmp CHECK_2_PADDLE_MOVEMENT
        ;forbidding the left paddle from going too high
        FIX_PADDLE_1_TOP:
            mov [PADDLE_Y_1], 0
            jmp CHECK_2_PADDLE_MOVEMENT



    ; moves the left paddle down if needed
    MOVE_1_PADDLE_DOWN:
        mov ax, [PADDLES_VELOCITY]
        add [PADDLE_Y_1], ax
        
        mov ax, [WINDOW_HEIGHT]
        sub ax, [PADDLE_SIZE_Y]

        cmp [PADDLE_Y_1], ax
        jg FIX_PADDLE_1_DOWN

        jmp CHECK_2_PADDLE_MOVEMENT
        ;forbidding the left paddle from going too low
        FIX_PADDLE_1_DOWN:
            mov ax, [WINDOW_HEIGHT]
            sub ax, [PADDLE_SIZE_Y]
            sub ax, 1
            mov [PADDLE_Y_1], ax
            
            jmp CHECK_2_PADDLE_MOVEMENT


    

    ;right paddle's movement
    CHECK_2_PADDLE_MOVEMENT:

        ;if it is 'o' or 'O' move up
        cmp al, 6fh ; 'o'
        je MOVE_2_PADDLE_UP
        cmp al, 4fh ; 'O'
        je MOVE_2_PADDLE_UP
    ;if it is 'l' or 'L' move down
        cmp al, 6ch ; 'l'
        je MOVE_2_PADDLE_DOWN
        cmp al, 4ch ; 'L'
        je MOVE_2_PADDLE_DOWN 
        ret


        ; moves the right paddle up if needed
        MOVE_2_PADDLE_UP:
            mov ax, [PADDLES_VELOCITY]
            sub [PADDLE_Y_2], ax

            cmp [PADDLE_Y_2], 00h
            jl FIX_PADDLE_2_TOP

            ret
            ;forbidding the right paddle from going too high
            FIX_PADDLE_2_TOP:
                mov [PADDLE_Y_2], 0
                ret

        ; moves the right paddle down if needed
        MOVE_2_PADDLE_DOWN:
            mov ax, [PADDLES_VELOCITY]
            add [PADDLE_Y_2], ax

            mov ax, [WINDOW_HEIGHT] 
            sub ax, [PADDLE_SIZE_Y]

            cmp [PADDLE_Y_2], ax
            jg FIX_PADDLE_2_DOWN

            ret
            ;forbidding the right paddle from going too low
            FIX_PADDLE_2_DOWN:

                mov ax, [WINDOW_HEIGHT]
                sub ax, [PADDLE_SIZE_Y]

                sub ax, 1
                mov [PADDLE_Y_2], ax
    ret

;generates a random number between 5 to 195
proc GENERATE_RANDOM_NUMBER_PLACE
    mov ah, 0
    int 1ah

    mov ax, dx
    mov dx, 05h
    mov bx, 0c3h;195
    div bx

    mov [byte ptr RANDOM_PLACE], dl

    

    ret


;generates a random number between 4 to 9
;proc GENERATE_RANDOM_NUMBER_SPEED
    ;mov ah, 0
    ;int 1ah

    ;mov ax, dx
    ;mov dx, 4
    ;mov bx, 09h
    ;div bx

    ;mov [byte ptr RANDOM_PLACE], dl

    

    ;ret


proc DRAW_WHITE_PIXEL
;drawing white pixel in the bottom right corner
    mov ah, 0ch
    mov al, 0fh
    mov bh, 00h ;set the page number
    mov cx, 200 ; column (x)
    mov dx, 100 ; row (y)
    int 10h
    ret

;ending the program
proc GO_OUT
    jmp exit


; --------------------------
	
exit:
	mov ax, 4c00h
	int 21h
END start


