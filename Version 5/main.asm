;Text-To-Braille Converter V5
		
;<label>		<opcode>		<operand>				
				.include		"m328pdef.inc"

				.def			delay_count  =	r17
				.def			iLoopRl		 =	r24
				.def			iLoopRh		 =	r25

				.equ			ival		 =	60000
				.equ			LED_PORT	 =	PORTB
				.equ			LED_DDR		 =	DDRB
				.equ			LED_PINS	 =	0x3F
				.equ			BUFFER_SIZE	 =	16			;store upto 32 characters
				.equ			UBRR_Val     =  103			;9600 baud rate (for 16MHz)																

				.dseg
buffer:
				.byte			BUFFER_SIZE					;reserve 32 bytes in SRAM	
				
				.cseg
				.org			0x0000
				rjmp			main
				

;--------------------------------------------------------------------------------------------------------------------------------------
;Braille Patterns for A-Z-
BrailleTable:	
				.db	0b000001, 0b000101, 0b000011, 0b001011, 0b001001, 0b000111, 0b001111, 0b001101, 0b000110, 0b001110
				.db	0b010001, 0b010101, 0b010011, 0b011011, 0b011001, 0b010111, 0b011111, 0b011101, 0b010110, 0b011110
				.db	0b110001, 0b110101, 0b101110, 0b110011, 0b111011, 0b111001
;--------------------------------------------------------------------------------------------------------------------------------------

main:			
				ldi				r16,LED_PINS
				out				LED_DDR,r16	
				clr				r16
				out				LED_PORT,r16
				
				rcall			uart_init
				rcall			buffer_init
				
main_loop:
				rcall			receive_word
				rcall			delay_2s				; 2-second initial delay
				rcall			display_word
				rcall			clear_buffer			; Clear the buffer after completing the word
				rjmp			main_loop

;----------------------------------------------------------------------------------------
;Initiate stack pointer to buffer				
buffer_init:	
				ldi				XL,low(buffer)
				ldi				XH,high(buffer)
				ret
;----------------------------------------------------------------------------------------

receive_word:
				push			r16
				rcall			buffer_init

receive_loop:
				rcall			uart_receive
				
				; Check for Enter (CR or LF)
				cpi				r16,0x0D			; Carriage return
				breq			word_end
				cpi				r16,0x0A			; Line Feed
				breq			word_end
				
				;Convert lowercase to uppercase
				cpi				r16,'a'
				brlo			check_space
				cpi				r16,'z'+1
				brsh			check_space
				subi			r16,32				; a-A = 32
				
check_space:
				cpi				r16,' '
				breq			store_char


				;Store characters from A to Z
				cpi				r16,'A'
				brlo			receive_loop
				cpi				r16,'Z'+1	
				brsh			receive_loop
				
store_char:
				st				X+, r16
				cpi				XL, low(buffer + BUFFER_SIZE)
				brne			receive_loop
				
word_end:
				ldi				r16,0xFF
				st				X,r16
				pop				r16
				ret
				
display_word:
				push			r16
				push			r17
				rcall			buffer_init
				
display_loop:	
				ld				r16, X+
				cpi				r16, 0xFF
				breq			display_end

				cpi				r16, ' '
				breq			space_delay
				
				ldi				ZL, low(BrailleTable <<1)
				ldi				ZH,	high(BrailleTable <<1)
				subi			r16, 'A'						; get braille index
				add				ZL, r16
				adc				ZH, r1	
				lpm				r17, Z							; load programme memory
				out				LED_PORT, r17
				rcall			delay_2s

				clr				r17
				out				LED_PORT, r17
				rcall			delay_2s

				rjmp			display_loop

space_delay:
				clr				r17
				out				LED_PORT,r17
				rcall			delay_3s
				rjmp			display_loop


display_end:
				pop				r17
				pop				r16
				ret

; Clear the buffer after completing the word
clear_buffer:
				push			r16
				push			XL
				push			XH
				rcall			buffer_init					; Reset buffer pointer
clear_loop:
				ldi				r16, 0xFF					; Fill buffer with 0xFF (empty marker)
				st				X+, r16
				cpi				XL, low(buffer + BUFFER_SIZE)
				brne			clear_loop

				pop				XH
				pop				XL
				pop				r16
				ret

delay_16ms:
				ldi				iLoopRl, low(iVal)
				ldi				iLoopRh, high(iVal)
inner_delay:
				sbiw			iLoopRl, 1
				brne			inner_delay
				ret

delay_2s:
				ldi				delay_count, 125  ; 16ms x 125 = 2s
inner_delay_2s:
				rcall			delay_16ms
				dec				delay_count
				brne			inner_delay_2s
				ret

delay_3s:
				ldi				delay_count, 188  ; 16ms x 188 = 3s
inner_delay_3s:
				rcall			delay_16ms
				dec				delay_count
				brne			inner_delay_3s
				ret

;-------------------------------------------------------------------------------------------
;Initiate date receiving and transmitting
uart_init:
				ldi				r16, HIGH(UBRR_Val)
				sts				UBRR0H, r16
				ldi				r16, LOW(UBRR_Val)
				sts				UBRR0L, r16
				ldi				r16, (1 << RXEN0) | (1 << TXEN0)
				sts				UCSR0B, r16
				ldi				r16, (1 << UCSZ01) | (1 << UCSZ00)
				sts				UCSR0C, r16
				ret
;--------------------------------------------------------------------------------------------
uart_receive:
				lds				r18, UCSR0A
				sbrs			r18, RXC0
				rjmp			uart_receive
				lds				r16, UDR0
				ret