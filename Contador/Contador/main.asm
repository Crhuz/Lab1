;
; Contador.asm
;
; Created: 2/3/2025 11:20:08 PM
; Author : super
;


.INCLUDE "M328PDEF.inc"  

.cseg  
.org 0x0000  

// Configuración de pila 
LDI     R16, LOW(RAMEND)  
OUT     SPL, R16  
LDI     R16, HIGH(RAMEND)  
OUT     SPH, R16  

// Configuración del MCU 
SETUP:  
    ; Configurar Puerto D como salida y apagarlo
    LDI     R16, 0xFF  
    OUT     DDRD, R16   
    LDI     R16, 0x00  
    OUT     PORTD, R16  

// Configurar Puerto B como salida y apagarlo  
    LDI     R16, 0xFF  
    OUT     DDRB, R16  
    LDI     R16, 0x00  
    OUT     PORTB, R16  

// Configurar Puerto C como entrada con pull-up activado  
    LDI     R16, 0x00  
    OUT     DDRC, R16  
    LDI     R16, 0xFF  
    OUT     PORTC, R16  

// Inicializar contadores en 0  
    LDI     R18, 0x00   ; Contador 1 (PD4 - PD7)  
    LDI     R22, 0x00   ; Contador 2 (PB1 - PB3)  

    RJMP    MAIN  

//  Bucle principal 
MAIN:  
    RCALL   LEER_BOTONES_C1
    RCALL   ACTUALIZAR_SALIDAS_C1   

    RCALL   LEER_BOTONES_C2  
    RCALL   ACTUALIZAR_SALIDAS_C2
	
	RCALL	LEER_BOTON_C3

    RJMP    MAIN  

//  SUBRUTINAS PARA PRIMER CONTADOR (PC0/PC1) 
LEER_BOTONES_C1:  
    SBIS    PINC, 0  
    RCALL   SUMAR_C1  
    SBIS    PINC, 1  
    RCALL   RESTAR_C1  
    RET  

SUMAR_C1:  
    RCALL   ANTIRREBOTE  
    SBIC    PINC, 0  
    RET  
    INC     R18  
    ANDI    R18, 0x0F   // Limitar a 4 bits  
    RET  

RESTAR_C1:  
    RCALL   ANTIRREBOTE  
    SBIC    PINC, 1  
    RET  
    CPI     R18, 0x00  
    BRNE    DEC_C1  
    LDI     R18, 0x0F  
    RET 
	 
DEC_C1:  
    DEC     R18  
    ANDI    R18, 0x0F  
    RET  

// SUBRUTINAS PARA SEGUNDO CONTADOR (PC2/PC3) 
LEER_BOTONES_C2:  
    SBIS    PINC, 2  
    RCALL   SUMAR_C2  
    SBIS    PINC, 3  
    RCALL   RESTAR_C2  
    RET  

SUMAR_C2:  
    RCALL   ANTIRREBOTE  
    SBIC    PINC, 2  
    RET  
    INC     R22  
    ANDI    R22, 0x0F   
    RET  

RESTAR_C2:  
    RCALL   ANTIRREBOTE  
    SBIC    PINC, 3  
    RET  
    CPI     R22, 0x00  
    BRNE    DEC_C2  
    LDI     R22, 0x0F  
    RET  
DEC_C2:  
    DEC     R22  
    ANDI    R22, 0x0F  
    RET

// SUBRUTINA PARA EL SUMADOR FINAL PC4
LEER_BOTON_C3:
	SBIS	PINC, 4
	RCALL	SUMATORIA_F
	RET

// SUMAR RESULTADOS FINALES
SUMATORIA_F:
    RCALL   ANTIRREBOTE  
    SBIC    PINC, 4  
    RET
    MOV     R16, R18  
    ADD     R16, R22  
    CPI     R16, 16  
    BRLO    NO_OVERFLOW  
    SBI     PORTB, 4  // Encender LED en PB4 si hay overflow
    SUBI    R16, 16  

NO_OVERFLOW:
    MOV     R24, R16  
    RCALL   ACTUALIZAR_SALIDAS_C3  
    RCALL   DELAY_1S   // Esperar 1 segundo antes de continuar
    RET

					   

// SUBRUTINA PARA MOSTRAR PRIMER CONTADOR EN PD4 - PD7 
ACTUALIZAR_SALIDAS_C1:  
    MOV     R16, R18  
    ANDI    R16, 0x0F  
    SWAP    R16           // Para no hacerme tantas bolas utilizo swap para cambiar la posicion de los bits
    OUT     PORTD, R16  
    RET  

// SUBRUTINA PARA MOSTRAR SEGUNDO CONTADOR EN PB1-PB3 
ACTUALIZAR_SALIDAS_C2:  
    MOV     R16, R22  
    ANDI    R16, 0x0F  
    OUT     PORTB, R16 
    RET  

// SUBRUTINA PARA MOSTRAR EL RESULTADO DEL SUMADOR
ACTUALIZAR_SALIDAS_C3:
	ANDI	R24, 0x0F
	OUT 	PORTD, R24
	RET    

// ANTIRREBOTE (20ms) 
ANTIRREBOTE:  
    LDI     R19, 210  
BUCLE1:  
    LDI     R20, 255  
BUCLE2:  
    LDI     R21, 25  
BUCLE3:  
    DEC     R21  
    BRNE    BUCLE3  
    DEC     R20  
    BRNE    BUCLE2  
    DEC     R19  
    BRNE    BUCLE1  
    RET

// Enseñar el valor de la suma por un segundo	
DELAY_1S:
    LDI     R19, 255
DELAY_LOOP1:
    LDI     R20, 255
DELAY_LOOP2:
    LDI     R21, 255
DELAY_LOOP3:
    DEC     R21
    BRNE    DELAY_LOOP3
    DEC     R20
    BRNE    DELAY_LOOP2
    DEC     R19
    BRNE    DELAY_LOOP1
    RET 