obj:
	dc.w	0,0,0,63,160,90,0,0,0

	dc.w	-48,-64,0,2
	dc.w	-32,-64,0,2
	dc.w	-16,-64,0,2
	dc.w	0,-64,0,2
	dc.w	16,-64,0,2
	dc.w	32,-64,0,2
	dc.w	48,-64,0,2


	dc.w	-48,-48,0,2
	dc.w	-32,-48,0,2
	dc.w	-16,-48,0,2
	dc.w	0,-48,0,2
	dc.w	16,-48,0,2
	dc.w	32,-48,0,2
	dc.w	48,-48,0,2

	dc.w	-48,-32,0,2
	dc.w	-32,-32,0,2
	dc.w	-16,-32,0,2
	dc.w	0,-32,0,2
	dc.w	16,-32,0,2
	dc.w	32,-32,0,2
	dc.w	48,-32,0,2

	dc.w	-48,-16,0,2
	dc.w	-32,-16,0,2
	dc.w	-16,-16,0,2
	dc.w	0,-16,0,2
	dc.w	16,-16,0,2
	dc.w	32,-16,0,2
	dc.w	48,-16,0,2

	dc.w	-48,0,0,2
	dc.w	-32,0,0,2
	dc.w	-16,0,0,2
	dc.w	0,0,0,2
	dc.w	16,0,0,2
	dc.w	32,0,0,2
	dc.w	48,0,0,2

	dc.w	-48,16,0,2
	dc.w	-32,16,0,2
	dc.w	-16,16,0,2
	dc.w	0,16,0,2
	dc.w	16,16,0,2
	dc.w	32,16,0,2
	dc.w	48,16,0,2

	dc.w	-48,32,0,2
	dc.w	-32,32,0,2
	dc.w	-16,32,0,2
	dc.w	0,32,0,2
	dc.w	16,32,0,2
	dc.w	32,32,0,2
	dc.w	48,32,0,2

	dc.w	-48,48,0,2
	dc.w	-32,48,0,2
	dc.w	-16,48,0,2
	dc.w	0,48,0,2
	dc.w	16,48,0,2
	dc.w	32,48,0,2
	dc.w	48,48,0,2

	dc.w	-48,64,0,2
	dc.w	-32,64,0,2
	dc.w	-16,64,0,2
	dc.w	0,64,0,2
	dc.w	16,64,0,2
	dc.w	32,64,0,2
	dc.w	48,64,0,2

anim:	dc.w	0
wph:	dc.w	0
wph2:	dc.w	0
phase:	dc.w	0
anim_balls2:
	lea	phase(pc),a6

	cmpi	#$1234,d5
	bne.s	pp
	clr	(a6)
pp:
	move	(a6),d7

	tst	d7
	bne.s	phase1	
phase0:
	move	#6,(a2)
	lea	anim(pc),a1
	clr	(a1)
	cmpi	#358,(a3)
	bmi	ex
	move	#2,2(a2)
	move	#1,(a6)
	rts
phase1:
	cmpi	#1,d7
	bne.s	phase2
	cmpi	#90,2(a3)
	bne	ex
	clr	(a2)
	move	#4,2(a2)
	move	#2,(a6)
	rts
phase2:
	cmpi	#2,d7
	bne.s	phase25
	cmpi	#180,2(a3)
	ble	ex
	move	#25,(a6)
	clr	2(a2)
	move	#8,(a2)	
	rts
phase25:
	cmpi	#25,d7
	bne	phase3
	cmpi	#9,(a3)
	bge	ex
	move	#3,(a6)
	lea	wph(pc),a1
	clr.l	(a1)
	move	#2,2(a2)
	clr	(a2)
	lea	ampli(pc),a1
	clr	(a1)
	lea	anim(pc),a1
	move	#1,(a1)
	rts
phase3:
	cmpi	#3,d7
	bne.s	phase4
	
	lea	wph(pc),a1
	addq	#1,(a1)
	cmpi	#180,(a1)
	ble.s	ph33
	move	#4,(a6)
	move	#4,2(a2)
	rts
ph33:
	addq	#1,2(a1)
	cmpi	#4,2(a1)
	bmi	ex
	clr	2(a1)

	lea	ampli(pc),a1
	cmpi	#40,(a1)
	bge.s	ph34
	addq	#2,(a1)
ph34:	rts
phase4:
	cmpi	#4,d7
	bne.s	phase5
	cmpi	#4,2(a3)
	bhi.s	ex
	move	#5,(a6)
	move	#4,4(a2)
	move	#5,(a2)
phase5:	
ex:	move	anim(pc),d1
	tst	d1
	bne.s	ok_anim
	rts
ampli:	dc.w	0

ok_anim:
	lea	pt_h(pc),a1
	add	#10,(a1)	
	cmpi	#360,(a1)
	bmi.s	a_b2_0
	subi	#360,(a1)
a_b2_0:
	move	(a1)+,d7

	move	ampli(pc),d5
	moveq	#8,d6
a_b2_1:	
	add	#20,d7
	cmpi	#360,d7
	bmi	a_b2_2
	subi	#360,d7
a_b2_2:
	move	d7,d0
	jsr	(a5)

	muls	d5,d1	
	lsl.l	#2,d1
	swap	d1
	subi	#20,d1
	ext.l	d1
	moveq	#6,d0
a_b2_3:
	move	d1,4(a4)
	addq	#8,a4

	dbf	d0,a_b2_3
	
	dbf	d6,a_b2_1

	rts

pt_h:	dc.w	0
