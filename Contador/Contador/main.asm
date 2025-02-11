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