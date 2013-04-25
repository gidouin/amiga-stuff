obj:

	dc.w	4,3,1,32,160,110,0,0,0

	dc.w	48,48,48,0
	dc.w	16,48,48,0
	dc.w	-16,48,48,0
	dc.w	-48,48,48,0
	dc.w	48,16,48,0
	dc.w	-48,16,48,0
	dc.w	48,-16,48,0
	dc.w	-48,-16,48,0
	dc.w	48,-48,48,0
	dc.w	16,-48,48,0
	dc.w	-16,-48,48,0
	dc.w	-48,-48,48,0

	dc.w	48,48,16,0
	dc.w	-48,48,16,0
	dc.w	48,-48,16,0
	dc.w	-48,-48,16,0

	dc.w	48,48,-16,0
	dc.w	-48,48,-16,0
	dc.w	48,-48,-16,0
	dc.w	-48,-48,-16,0

	dc.w	48,48,-48,0
	dc.w	16,48,-48,0
	dc.w	-16,48,-48,0
	dc.w	-48,48,-48,0
	dc.w	48,16,-48,0
	dc.w	-48,16,-48,0
	dc.w	48,-16,-48,0
	dc.w	-48,-16,-48,0
	dc.w	48,-48,-48,0
	dc.w	16,-48,-48,0
	dc.w	-16,-48,-48,0
	dc.w	-48,-48,-48,0


	dc.w	0,0,0,2

anim_balls2:
	lea	pt_h(pc),a0
	move	d1,d5
	move	d2,d6
	move	(a0),d1

	add	d0,d1	
	cmpi	#360,d1
	bmi.s	a_b3_0
	subi	#360,d1
a_b3_0:
	move	d1,(a0)
	move	d1,d0

	jsr	(a5)
	

	muls	d5,d1
	lsl.l	#2,d1
	swap	d1
	sub	d6,d1
	move	d1,(a4)
	rts

pt_h:	dc.w	0
pt_h2:	dc.w	0
