/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    mov r2,0 /* register for 0 */
    
    ldr r4,=a_Multiplicand /* resets a_multiplicand to 0 */
    str r2,[r4]
    
    ldr r5,=b_Multiplier /* resets b_Multiplier to 0 */
    str r2,[r5]
    
    ldr r6,=rng_Error /* resets rng_Error to 0 */
    str r2,[r6]
    
    ldr r10,=a_Sign /* resets a _Sign to 0 */
    str r2,[r10]
    
    ldr r11,=b_Sign /* resets b_Sign to 0 */
    str r2,[r11]
    
    ldr r12,=prod_Is_Neg /* resets prod_Is_Neg to 0 */
    str r2,[r3]
    
    ldr r3,=a_Abs /* resets a_Abs to 0 */
    str r2,[r3]
    
    ldr r3,=b_Abs /* resets b_Abs to 0 */
    str r2,[r3] 
    
    ldr r3,=init_Product /* resets init_Product to 0 */
    str r2,[r3]
    
    ldr r3,=final_Product /* resets final_Product to 0 */
    str r2,[r3]
    
    str r0,[r4] /* copy r0 into a_Multiplicand */
    str r1,[r5] /* copy r1 into b_Multiplier */
    
    LDR r7,=4294934528 /* 0xffff8000 used to check if multiplicand fit in 16 bit */
    AND r8,r0,r7 /* and logic to test sign bits */
    CMP r8,r7 /* if all sign bits 1, then value in valid range for sign 16 bit */
    beq multiplier_check /* branch to next step */
    CMP r8,r2 /* if all sign bits 0, then value in valid range for sign 16 bit */
    beq multiplier_check /* branch to next step */
    /* if multiplicand sign bits not all 1 or 0, then error */

error:
    mov r2,1 /* register for 1 */
    str r2,[r6] /* set rng_Error to 1 */
    mov r0,0 /* set r0 to 0 */
    b done
    
multiplier_check:
    AND r9,r1,r7 /* and logic to test sign bits of multiplier */ 
    CMP r9,r7 /* if all sign bits 1, then value in valid range for sign 16 bit */ 
    beq store_sign /* move on to store sign bits */ 
    CMP r9,r2 /* if all sign bits 0, then value in valid range for sign 16 bit */ 
    beq store_sign /* move on to store sign bits */ 
    b error /* if multiplier sign bits not all 1 or 0, then error */
    
store_sign:
    str r8,[r10] /* store sign bits for multiplicand */
    str r9,[r11] /* store sign bits for multiplier */
    EOR r4,r8,r9 /* if both sign bits same result is 0, else result is 1 */
    CMP r4,r2 /* compare result to 0 */
    beq prod_positive /* if equal, then product is positive so set to 0 */
    mov r2,1 /* if not equal, product is negative */
    str r2,[r12] /* store 1 into prod_Is_Neg */
    b absolute_value /* branch to next step */

prod_positive:
    str r2,[r12] /* if result is 0, prod_Is_Neg is set to 0 */
    
absolute_value:
    LDR r2,=65535 /* 0x0000FFFF used to get absolute value */
    AND r0,r0,r2 /* abs value for a_multiplicand */
    AND r1,r1,r2 /* abs value for b_multiplier */
    LDR r3,=a_Abs
    str r0,[r3] /* stores abs value of a into mem location */
    LDR r3,=b_Abs
    str r1,[r3] /* stores abs value of b into mem location */
    
    mov r5,0 /* initially sets register for product to 0 */
  
shift_and_add:
    mov r2,0 /* register for 0 */
    CMP r1,r2 /* check if multiplier equal 0 */
    beq product_done /* if multiplier equals 0 */
    mov r2,1 /* register for 0x00000001 */
    AND r6,r1,r2 /* checks multiplier LSB if 0 or 1 */
    CMP r6,0 /* checks if LSB 0 */
    beq LSB_not_1 /* if 0 go straight to shifts */
    ADD r5,r5,r0 /* if LSB 1, add product and multiplicand */
    
LSB_not_1:
    LSR r1,r1,1 /* shift multiplier 1 to right */
    LSL r0,r0,1 /* shift multiplicand 1 to left */
    b shift_and_add /* go back to shift_and_add loop */
    
product_done:
    LDR r3,=init_Product /* register for initial product */
    str r5,[r3] /* stores product into mem location of init_Product */

check_final:
    LDR r2,[r12] /* loads if product is negative or not */
    CMP r2,0 /* if positive, store product into final product right away */
    beq final_done /* if negative, change sign values to 1 */
    LDR r2,=4294901760 /* loads 0xFFFF0000 to change sign values to 1 */
    ORR r5,r2,r5 /* or logic to get sign values to 1, leaves actual value alone */
    
final_done:
    ldr r3,=final_Product /* register for address of final_Product */
    str r5,[r3] /* store product into final product */
    ldr r0,[r3] /* final result to r0 */
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




