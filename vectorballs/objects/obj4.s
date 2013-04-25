obj:	dc.w	0,356,0,52,140,70,30,0,0

	dc.w	0,0,0,0
	dc.w	0,18,0,3
	dc.w	0,-29,0,0
	dc.w	0,34,0,0
	
	dc.w	-7,34,-12,3
	dc.w	6,34,-12,3

	dc.w	19,8,0,2
	dc.w	22,-5,0,2	;bras gauche
	dc.w	22,-15,-4,3	
	dc.w	22,-20,-12,2

	dc.w	-19,8,0,2
	dc.w	-22,-5,0,2
	dc.w	-22,-15,-4,3	;bras droit
	dc.w	-22,-20,-12,2

	dc.w	22,-28,-7,3
	dc.w	22,-34,-2,3
	dc.w	22,-40,3,3
	dc.w	22,-46,8,3
	dc.w	22,-52,13,3
	dc.w	22,-58,18,3	;baton gauche
	dc.w	22,-64,23,3
	dc.w	22,-70,28,3
	dc.w	22,-76,33,3


	dc.w	-22,-28,-7,3
	dc.w	-22,-34,-2,3
	dc.w	-22,-40,3,3
	dc.w	-22,-46,8,3
	dc.w	-22,-52,13,3
	dc.w	-22,-58,18,3	;baton droit
	dc.w	-22,-64,23,3
	dc.w	-22,-70,28,3
	dc.w	-22,-76,33,3


	dc.w	10,-48,0,2	;jambe gauche
	dc.w	10,-62,0,2
	dc.w	10,-76,0,2

	dc.w	-10,-48,0,2	;jambe droite
	dc.w	-10,-62,0,2
	dc.w	-10,-76,0,2

	dc.w	12,-83,-22,3
	dc.w	12,-88,-16,3
	dc.w	12,-88,-8,3
	dc.w	12,-88,0,3	;ski	gauche
	dc.w	12,-88,8,3
	dc.w	12,-88,16,3
	dc.w	12,-88,24,3

	dc.w	-12,-83,-22,3
	dc.w	-12,-88,-16,3
	dc.w	-12,-88,-8,3
	dc.w	-12,-88,0,3	;ski droit
	dc.w	-12,-88,8,3
	dc.w	-12,-88,16,3
	dc.w	-12,-88,24,3

anim_balls2:
	lea	pt_h(pc),a6
	move	(a6),d7

	add	d0,d7
	cmpi	#360,d7
	bmi.s	a_b3_0
	subi	#360,d7
a_b3_0:
	move	d7,(a6)

	lea	obj+18,a0

	move	d7,d0
	jsr	(a5)
	move	d1,d3

	addi	#180,d7
	cmpi	#360,d7
	bls.s	jk
	subi	#360,d7
jk:
	move	d7,d0
	jsr	(a5)
	move	d1,d4


	move	d3,d1
	move	d4,d2
	muls	#8,d1
	muls	#8,d2	
	lsl.l	#2,d1
	lsl.l	#2,d2
	swap	d1
	swap	d2
	move	d1,276(a4)
	move	d2,300(a4)


	move	d3,d1
	move	d4,d2
	muls	#5,d1
	muls	#5,d2
	lsl.l	#2,d1
	lsl.l	#2,d2
	swap	d1
	swap	d2
	move	d1,268(a4)
	move	d2,292(a4)

	move	d3,d1
	move	d4,d2
	muls	#3,d1
	muls	#3,d2
	lsl.l	#1,d1
	lsl.l	#2,d2
	swap	d1
	swap	d2
	move	d1,260(a4)
	move	d2,284(a4)

	move	d3,d1
	muls	#10,d1
	lsl.l	#2,d1
	swap	d1

	move	d4,d2
	muls	#10,d2
	lsl.l	#2,d2
	swap	d2

	add	#8*38,a4
	add	#8*38,a0

	moveq	#6,d5
a_b3_1:
	move	4(a0),d3
	ext.l	d3
	add	d1,d3
	move	d3,4(a4)

	move	60(a0),d3
	ext.l	d3
	add	d2,d3
	move	d3,60(a4)

	lea	8(a0),a0
	lea	8(a4),a4
	

	dbf	d5,a_b3_1
	rts

pt_h:	dc.w	0
