obj:
	dc.w	4,5,5,64,160,110,-25,15,-20


	dc.w	-20,0,56,2
	dc.w	-14,14,56,2
	dc.w	0,20,56,2
	dc.w	14,14,56,2
	dc.w	20,0,56,2
	dc.w	14,-14,56,2
	dc.w	0,-20,56,2
	dc.w	-14,-14,56,2

	dc.w	-20,0,40,2
	dc.w	-14,14,40,2
	dc.w	0,20,40,2
	dc.w	14,14,40,2
	dc.w	20,0,40,2
	dc.w	14,-14,40,2
	dc.w	0,-20,40,2
	dc.w	-14,-14,40,2

	dc.w	-20,0,24,2
	dc.w	-14,14,24,2
	dc.w	0,20,24,2
	dc.w	14,14,24,2
	dc.w	20,0,24,2
	dc.w	14,-14,24,2
	dc.w	0,-20,24,2
	dc.w	-14,-14,24,2

	dc.w	-20,0,8,2
	dc.w	-14,14,8,2
	dc.w	0,20,8,2
	dc.w	14,14,8,2
	dc.w	20,0,8,2
	dc.w	14,-14,8,2
	dc.w	0,-20,8,2
	dc.w	-14,-14,8,2

	dc.w	-20,0,-8,2
	dc.w	-14,14,-8,2
	dc.w	0,20,-8,2
	dc.w	14,14,-8,2
	dc.w	20,0,-8,2
	dc.w	14,-14,-8,2
	dc.w	0,-20,-8,2
	dc.w	-14,-14,-8,2

	dc.w	-20,0,-24,2
	dc.w	-14,14,-24,2
	dc.w	0,20,-24,2
	dc.w	14,14,-24,2
	dc.w	20,0,-24,2
	dc.w	14,-14,-24,2
	dc.w	0,-20,-24,2
	dc.w	-14,-14,-24,2

	dc.w	-20,0,-40,2
	dc.w	-14,14,-40,2
	dc.w	0,20,-40,2
	dc.w	14,14,-40,2
	dc.w	20,0,-40,2
	dc.w	14,-14,-40,2
	dc.w	0,-20,-40,2
	dc.w	-14,-14,-40,2

	dc.w	-20,0,-56,2
	dc.w	-14,14,-56,2
	dc.w	0,20,-56,2
	dc.w	14,14,-56,2
	dc.w	20,0,-56,2
	dc.w	14,-14,-56,2
	dc.w	0,-20,-56,2
	dc.w	-14,-14,-56,2

	dc.w	-14,-14,-56,2


anim_balls2:
	lea	pt_h2(pc),a2
	move	d1,2(a2)
	move	(a2),d1
	

	add	d0,d1	
	cmpi	#360,d1
	bmi.s	a_b3_0
	subi	#360,d1
a_b3_0:
	move	d1,(a2)
	move	d1,d7

	lea	obj+18(pc),a0

	moveq	#7,d5
a_b3_1:

	moveq	#7,d6
a_b3_2:	
	
	move	d7,d0
	jsr	(a5)

	move	(a0),d3

	move	d3,d2
	add	d3,d3
	muls	d1,d3
	lsl	#2,d3
	swap	d3
	lsr	#1,d2
	ext	d2
	add	d2,d3
	move	d3,(a4)

	move	2(a0),d3
	move	d3,d2
	add	d3,d3
	muls	d1,d3
	lsl	#2,d3
	swap	d3
	lsr	#1,d2
	ext	d2
	add	d2,d3
	move	d3,2(a4)
	
	lea	8(a0),a0
	lea	8(a4),a4
	
	dbf	d6,a_b3_2

	add	2(a2),d7
	cmpi	#360,d7
	bmi.s	a_b2_8
	subi	#360,d7
a_b2_8:
	dbf	d5,a_b3_1
	rts

pt_h:	dc.w	0
pt_h2:	dc.w	0
	dc.w	0
