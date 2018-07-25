********12-BIT COLOUR LINEAR INTERPOLATION************
************ASM CODING COMPETITION #1*****************
***************(C) NIGHTFOX 2017**********************
******************************************************

	incdir "Include3.1:"
	include exec/exec_lib.i
	include hardware/custom.i

	SECTION CC1_Code,CODE_P
Start:
	movem.l d0-d7/a0-a7,-(sp)

OSOff:
	move.l 4.w,a6
	move.l #gfxname,a1
	clr.l d0
	jsr _LVOOpenLibrary(a6)
	move.l d0,a1
	move.l 38(a1),d4	;original copper pointer
	jsr _LVOCloseLibrary(a6)

	move.l #$dff000,a6
	move.w #$20,BEAMCON0(a6)	;switch to 50Hz mode
	move.w #$7fff,INTENA(a6)
	move.w #$7fff,INTREQ(a6)
	move.w #$7fff,INTREQ(a6)
	move.w #$7fff,DMACON(a6)
	
	move.w #$8680,DMACON(a6) 
	move.l #Copper,COP1LC(a6)

	move.w #$0123,d5	;colour 1
	move.w #$0f74,d6	;colour 2
	move.w d6,d1
	
	move.w d5,Col0+2
	move.w d6,Col15+2

	move.w d5,d0
	move.b #1,d2		;step  
	bsr LookupFunction
	move.w d0,Col1+2

	move.w d5,d0
	move.b #2,d2		;step  
	bsr LookupFunction
	move.w d0,Col2+2

	move.w d5,d0
	move.b #3,d2		;step  
	bsr LookupFunction
	move.w d0,Col3+2

	move.w d5,d0
	move.b #4,d2		;step  
	bsr LookupFunction
	move.w d0,Col4+2

	move.w d5,d0
	move.b #5,d2		;step  
	bsr LookupFunction
	move.w d0,Col5+2

	move.w d5,d0
	move.b #6,d2		;step  
	bsr LookupFunction
	move.w d0,Col6+2

	move.w d5,d0
	move.b #7,d2		;step  
	bsr LookupFunction
	move.w d0,Col7+2

	move.w d5,d0
	move.b #8,d2		;step  
	bsr LookupFunction
	move.w d0,Col8+2

	move.w d5,d0
	move.b #9,d2		;step  
	bsr LookupFunction
	move.w d0,Col9+2

	move.w d5,d0
	move.b #10,d2		;step  
	bsr LookupFunction
	move.w d0,Col10+2

	move.w d5,d0
	move.b #11,d2		;step  
	bsr LookupFunction
	move.w d0,Col11+2

	move.w d5,d0
	move.b #12,d2		;step  
	bsr LookupFunction
	move.w d0,Col12+2

	move.w d5,d0
	move.b #13,d2		;step  
	bsr LookupFunction
	move.w d0,Col13+2

	move.w d5,d0
	move.b #14,d2		;step  
	bsr LookupFunction
	move.w d0,Col14+2
	
waitmouse:
	btst #6,$bfe001
	bne waitmouse

	bra OSOn


OSOn:
	move.w #$7fff,DMACON(a6)
	or.w #$8200,d3
	move.w d3,DMACON(a6)
	move.l d4,COP1LC(a6)
	or #$c000,d5
	move d5,INTENA(a6)
	

Exit:
	movem.l (sp)+,d0-d7/a0-a7
	moveq #0,d0
	rts

LookupFunction:
	movem.l d1-d7/a0-a6,-(sp)

	move.b d0,d3	;put colour 1 in d3
	and.b #$f,d3	;only keep blue data
	move.b d1,d4	;put colour 2 in d4
	and.b #$f,d4	;only keep blue data
	sub.b d3,d4	;get blue difference

	move.b d0,d3	;put colour 1 in d3
	lsr.b #4,d3	;put green data at end
	move.b d1,d5	;put colour 2 in d5
	lsr.b #4,d5	;put green data at end
	sub.b d3,d5	;get green difference

	move.w d0,d6	;put colour 1 in d6
	lsr.w #8,d6	;put red data at end
	lsr.w #8,d1	;put red data at end
	sub.b d6,d1	;get red difference

	move.l #LookupTable,d7
	add.b d2,d7
	move.l d7,a0	;load lookup table address into register

	muls #16,d1	;get onto correct row
	muls #16,d5	;get onto correct row
	muls #16,d4	;get onto correct row

	move.l a0,d6	;copy table pointer
	add.w d1,d6	;adjust red pointer
	move.l d6,a1	;set pointer
	move.b (a1),d1	;get new red amount	

	move.l a0,d6	;copy table pointer
	add.w d5,d6	;adjust green pointer
	move.l d6,a1	;set pointer
	move.b (a1),d5	;get new green amount
	
	move.l a0,d6	;copy table pointer
	add.w d4,d6	;adjust blue pointer
	move.l d6,a1	;set pointer
	move.b (a1),d4	;get new blue amount
	
	add.b d4,d0	;add blue to final colour
	lsl.b #4,d5	;put green in correct position
	add.b d5,d0	;add green to final colour
	lsl.w #8,d1	;put red in correct position
	add.w d1,d0	;add red to final colour

	movem.l (sp)+,d1-d7/a0-a6
	rts

	SECTION CC1_Data,DATA_P
gfxname:	dc.b 'graphics.library',0

LookupTableStart:
		dc.b 0,-1,-2,-3,-4,-5,-6,-7,-8,-9,-$a,-$b,-$c,-$d,-$e,-$f
		dc.b 0,-1,-2,-3,-4,-5,-6,-7,-7,-8,-9,-$a,-$b,-$c,-$d,-$e
		dc.b 0,-1,-2,-3,-3,-4,-5,-6,-7,-8,-9,-$a,-$a,-$b,-$c,-$d
		dc.b 0,-1,-2,-2,-3,-4,-5,-6,-6,-7,-8,-9,-$a,-$a,-$b,-$c
		dc.b 0,-1,-2,-2,-3,-4,-4,-5,-6,-7,-7,-8,-9,-$a,-$a,-$b
		dc.b 0,-1,-1,-2,-3,-3,-4,-5,-5,-6,-7,-7,-8,-9,-9,-$a
		dc.b 0,-1,-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-7,-8,-8,-9
		dc.b 0,-1,-1,-2,-2,-3,-3,-4,-4,-5,-5,-6,-6,-7,-7,-8
		dc.b 0,0,-1,-1,-2,-2,-3,-3,-4,-4,-4,-5,-6,-6,-7,-7
		dc.b 0,0,-1,-1,-2,-2,-2,-3,-4,-4,-4,-4,-5,-5,-6,-6
		dc.b 0,0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-4,-5,-5
		dc.b 0,0,-1,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-3,-4,-4
		dc.b 0,0,0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-3,-3,-3
		dc.b 0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2
		dc.b 0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1
LookupTable:	dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
		dc.b 0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2
		dc.b 0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3
		dc.b 0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4
		dc.b 0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5
		dc.b 0,0,1,1,2,2,2,3,4,4,4,4,5,5,6,6
		dc.b 0,0,1,1,2,2,3,3,4,4,4,5,6,6,7,7
		dc.b 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
		dc.b 0,1,1,2,2,3,4,4,5,5,6,7,7,8,8,9
		dc.b 0,1,1,2,3,3,4,5,5,6,7,7,8,9,9,$a
		dc.b 0,1,2,2,3,4,4,5,6,7,7,8,9,$a,$a,$b
		dc.b 0,1,2,2,3,4,5,6,6,7,8,9,$a,$a,$b,$c
		dc.b 0,1,2,3,3,4,5,6,7,8,9,$a,$a,$b,$c,$d
		dc.b 0,1,2,3,4,5,6,7,7,8,9,$a,$b,$c,$d,$e
		dc.b 0,1,2,3,4,5,6,7,8,9,$a,$b,$c,$d,$e,$f 

	SECTION CC1_Copper,DATA_C
Copper:
	dc.w BPLCON0,$0200

	dc.w $1301,$fffe
Col0:	dc.w COLOR,0

	dc.w $2501,$fffe
Col1:	dc.w COLOR,0

	dc.w $3701,$fffe
Col2:	dc.w COLOR,0

	dc.w $4901,$fffe
Col3:	dc.w COLOR,0

	dc.w $5b01,$fffe
Col4:	dc.w COLOR,0

	dc.w $6d01,$fffe
Col5:	dc.w COLOR,0

	dc.w $7f01,$fffe
Col6:	dc.w COLOR,0

	dc.w $9101,$fffe
Col7:	dc.w COLOR,0

	dc.w $a301,$fffe
Col8:	dc.w COLOR,0

	dc.w $b501,$fffe
Col9:	dc.w COLOR,0

	dc.w $c701,$fffe
Col10:	dc.w COLOR,0

	dc.w $d901,$fffe
Col11:	dc.w COLOR,0

	dc.w $eb01,$fffe
Col12:	dc.w COLOR,0

	dc.w $fd01,$fffe
Col13:	dc.w COLOR,0
	dc.w $ffdf,$fffe

	dc.w $1001,$fffe
Col14:	dc.w COLOR,0

	dc.w $2201,$fffe
Col15:	dc.w COLOR,0

	dc.w $ffff,$fffe

