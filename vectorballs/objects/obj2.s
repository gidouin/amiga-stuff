obj:

	dc.w	3,4,7,39,160,100,0,0,0

	dc.w	0,0,0,0
	dc.w	32,0,0,0
	dc.w	-32,0,0,0
	dc.w	0,32,0,0
	dc.w	0,-32,0,0
	dc.w	0,0,32,0
	dc.w	0,0,-32,0


	dc.w	24,24,24,2
	dc.w	8,24,24,2
	dc.w	-8,24,24,2
	dc.w	-24,24,24,2
	dc.w	24,8,24,2
	dc.w	-24,8,24,2
	dc.w	24,-8,24,2
	dc.w	-24,-8,24,2
	dc.w	24,-24,24,2
	dc.w	8,-24,24,2
	dc.w	-8,-24,24,2
	dc.w	-24,-24,24,2

	dc.w	24,24,8,2
	dc.w	-24,24,8,2
	dc.w	24,-24,8,2
	dc.w	-24,-24,8,2

	dc.w	24,24,-8,2
	dc.w	-24,24,-8,2
	dc.w	24,-24,-8,2
	dc.w	-24,-24,-8,2

	dc.w	24,24,-24,2
	dc.w	8,24,-24,2
	dc.w	-8,24,-24,2
	dc.w	-24,24,-24,2
	dc.w	24,8,-24,2
	dc.w	-24,8,-24,2
	dc.w	24,-8,-24,2
	dc.w	-24,-8,-24,2
	dc.w	24,-24,-24,2
	dc.w	8,-24,-24,2
	dc.w	-8,-24,-24,2
	dc.w	-24,-24,-24,2

	dc.w	0,0,0,2

anim_balls2:

	lea	pt_h(pc),a6
	
	move	d1,2(a6)
	move	(a6),d1

	add	d0,d1	
	cmpi	#360,d1
	bmi.s	a_b3_0
	subi	#360,d1
a_b3_0:
	move	d1,d0
	move	d1,(a6)

	lea	obj+18(pc),a0
	jsr	(a5)


	muls	2(a6),d1
	lsl.l	#2,d1
	swap	d1


	moveq	#38,d5
a_b3_1:

	
	move	(a0),d3
	ext.l	d3
	add	d1,d3
	move	d3,(a4)

	
	lea	8(a0),a0
	lea	8(a4),a4
	

	dbf	d5,a_b3_1
	rts

pt_h:	dc.w	0
pt_h2:	dc.w	0
