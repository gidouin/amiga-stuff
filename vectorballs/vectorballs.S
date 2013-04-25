;-----------------------------------------------
; Intro for Microtel meeting at Rennes, May 1990
; Code:  Frederic Gidouin
; Gfx:   Orion
; Music: Apollo / Gwenael M.
;-----------------------------------------------
>EXTERN "music/mod.art.muzak",mt_data
>EXTERN "gfx/fonts8",char
>EXTERN "gfx/ball",i_balls
>EXTERN "sinus.table",tblsin
>EXTERN "gfx/logo",logo
>EXTERN "objects/obj1",objs
>EXTERN "objects/obj2",objs+660
>EXTERN "objects/obj3",objs+1068
>EXTERN "objects/obj5",objs+1396
>EXTERN "objects/obj6",objs+2404
>EXTERN "objects/obj8",objs+2832
>EXTERN "objects/obj7",objs2
;---------------------
start:
	jsr	clear_buf
	jsr	init_balls
	jsr	set_msk

	move.b	#%10000111,$bfd100
	move.l	$4,a6
	jsr	-$84(a6)
	lea	$dff000,a6
	move	$2(a6),s_dma
	or	#$c000,s_dma
	move	$1c(a6),s_ireq
	or	#$c000,s_ireq

	move	#$3fff,$9a(a6)
	move	#$8020,$9a(a6)
	

	move	#$3fff,$96(a6)
	move	#$83c0,$96(a6)
	move.l	#$2c812ae1,$8e(a6)
	clr.l	$102(a6)
	move.l	#$3800d0,$92(a6)

	jsr	cree_copliste
	jsr	set_screen
	move.l	#copper_list,$80(a6)
	clr	$88(a6)	
	
	jsr	mt_init

	jsr	set_irq

	jsr	clear_screen
	jsr	wait_blitter
	jsr	swap_screens
	jsr	clear_screen

	jsr	init_obj
	jsr	init_centre
	jsr	set_fondu
	
	jsr	logo_in

	jsr	balls_in
wait:
	cmp.b	#$ff,$dff006
	bne.s	wait


	jsr	change_obj
	jsr	swap_screens
	jsr	set_screen
	jsr	clear_screen
	jsr	rot_balls
	jsr	set_perspective

	jsr	tri_balls

	jsr	wait_blitter
	jsr	display_object
	jsr	anim_balls	


	jsr	anim_intern


	btst	#2,$dff016
	bne	no_chg

	move	#1,do_change
no_chg:
	btst	#6,$bfe001
	bne.s	wait

	jsr	balls_out

fond:	cmp.B	#$ff,$dff006
	bne.s	fond

	jsr	balls_fondu
	tst	do_balls_fondu
	bne.s	fond	

	jsr	logo_out


	jsr	mt_end

	move.l	s_vector+2,$6c.w		
	move	#$7fff,$dff096
	move	s_dma,$dff096
	move	#$7fff,$dff09a
	move	s_ireq,$dff09a
	move.l	$4,a6
	lea	name_glib,a1
	moveq	#0,d0
	jsr	-$228(a6)
	move.l	d0,a0
	move.l	$26(a0),$dff080
	clr	$dff088
	jmp	-$8a(a6)
set_irq:
	move.l	$6c.w,s_vector+2
	move.l	#irq,$6c.w
	rts
clear_buf:
	lea	buf_scr,a0
	moveq	#104,d0
clb:	clr.l	(a0)+
	dbf	d0,clb
	rts
init_balls:

	lea	i_balls,a0
	lea	balls,a1

	moveq	#31,d0
cree_balls:
	moveq	#9,d1

	move	d1,d2
	move	d1,d3
	move	d1,d4
	lea	0(a0),a2
	lea	1280(a0),a3
	lea	2560(a0),a4
	lea	3840(a0),a5
cb0:
	move.l	(a2)+,(a1)+
	dbf	d1,cb0
cb1:
	move.l	(a3)+,(a1)+	
	dbf	d2,cb1
cb2:
	move.l	(a4)+,(a1)+
	dbf	d3,cb2
cb3:
	move.l	(a5)+,(a1)+
	dbf	d4,cb3
	lea	40(a0),a0
	dbf	d0,cree_balls
	rts
set_msk:
	lea	balls,a0
	lea	msk_balls,a1
	moveq	#31,d0
cm0:
	moveq	#9,d1
cm1:
	move.l	40(a0),d2
	or.l	80(a0),d2
	or.l	120(a0),d2
	or.l	(a0)+,d2
	move.l	d2,40(a1)
	move.l	d2,80(a1)
	move.l	d2,120(a1)	
	move.l	d2,(a1)+
	dbf	d1,cm1
	lea	120(a1),a1
	lea	120(a0),a0
	dbf	d0,cm0
	rts
irq:	
	movem.l	d0-d7/a0-a6,-(a7)

	jsr	scroll
	jsr	mt_music

	add	#1,tempo
	cmpi	#2,tempo
	bne	irq2
	clr	tempo
	jsr	balls_fondu
irq2:

	movem.l	(a7)+,d0-d7/a0-a6
s_vector:	jmp	0
tempo:	dc.w	1
s_dma:	dc.w	0
s_ireq:	dc.w	0
name_glib:	dc.b	'graphics.library',0
	even
cree_copliste:
	lea	copper_list,a0

	move.l	#$01005000,(a0)+
	move.l	#$01080000,(a0)+
	move.l	#$010a0000,(a0)+
	move.l	#logo,d2
	moveq	#4,d1
	move	#$e2,d0
cree_co0:
	move	d0,(a0)+
	move	d2,(a0)+
	subq	#2,d0
	swap	d2
	move	d0,(a0)+
	move	d2,(a0)+
	swap	d2
	add.l	#1640,d2
	addq	#6,d0
	dbf	d1,cree_co0


	move	#$180,d0
	moveq	#31,d1
cree_c0:move	d0,(a0)+
	addq	#2,d0
	clr	(a0)+
	dbf	d1,cree_c0


	move.l	#$550ffffe,(a0)+
	move.l	#$00960100,(a0)+
	move.l	#$01004000,(a0)+
	move.l	#$01080078,(a0)+
	move.l	#$010a0078,(a0)+

	move	#$180,d0
	moveq	#15,d1
cree_c1:move	d0,(a0)+
	addq	#2,d0
	clr	(a0)+
	dbf	d1,cree_c1

	move.l	#$560ffffe,(a0)+
	move.l	#$00968100,(a0)+
	move.l	#$e20000,(a0)+
	move.l	#$e00000,(a0)+
	move.l	#$e60000,(a0)+
	move.l	#$e40000,(a0)+
	move.l	#$ea0000,(a0)+
	move.l	#$e80000,(a0)+
	move.l	#$ee0000,(a0)+
	move.l	#$ec0000,(a0)+
	move.l	#$ffe1fffe,(a0)+
	move.l	#$200ffffe,(a0)+

	move.l	#$1001000,(a0)+
	move.l	#$1080002,(a0)+
	move.l	#$210ffffe,d1
	move.l	#buf_scr,d0
	move	#$e2,(a0)+
	move	d0,(a0)+
	swap	d0
	move	#$e0,(a0)+
	move	d0,(a0)+
	moveq	#9,d0
	lea	colors,a1
initco:
	move	#$182,(a0)+
	move	(a1)+,(a0)+
	move.l	d1,(a0)+
	addi.l	#$1000000,d1
	dbf	d0,initco
	move.l	#$fffffffe,(a0)+
	rts	

;--------------------------------
used_screen:	dc.l	screen0
other_screen:	dc.l	screen1

swap_screens:
	move.l	used_screen,d0
	move.l	other_screen,used_screen
	move.l	d0,other_screen
	rts
;--------------------------------

set_screen:

	lea	copper_list+272,a0
	move.l	used_screen,d0
	add.l	#1280,d0
	moveq	#3,d1
set_s:
	move	d0,2(a0)
	swap	d0
	move	d0,6(a0)
	swap	d0
	add.l	#40,d0
	addq	#8,a0
	dbf	d1,set_s
	rts

;-------------------------------
aff_ball:
	ext.l	d1
	tst	d1
	bmi	no_aff
	cmpi	#210,d1
	bhi	no_aff

	ext.l	d0
	tst	d0
	bmi	no_aff
	cmpi	#300,d0
	bhi	no_aff


	andi	#$ff,d1
	mulu	#160,d1
	move	d0,d2
	lsr	#3,d0
	bclr	#0,d0
	
	move.l	other_screen,a2
	add	d1,a2
	add	d0,a2

	andi	#$000f,d2
	lsl	#8,d2
	lsl	#4,d2

	lsl	#3,d3

	lea	balls,a3
	add	4(a6,d3.w),a3
	lea	msk_balls,a4
	add	4(a6,d3.w),a4

wbli:
	btst	#14,$dff002
	bne	wbli


	move	d2,$dff042
	ori	#$fca,d2
	move	d2,$dff040


	move	0(a6,d3.w),$dff060
	move	0(a6,d3.w),$dff062
	move	0(a6,d3.w),$dff064
	move	0(a6,d3.w),$dff066

	move.l	a2,$dff048		;fd
	move.l	a3,$dff04c		;balls
	move.l	a4,$dff050		;msk
	move.l	a2,$dff054		;fd
	move	2(a6,d3.w),$dff058
no_aff:
	rts
;---------------------------------
clear_screen:
	lea	$dff000,a5
	move.l	#$ffffffff,$44(a5)
	clr	$66(a5)
	clr	$74(a5)
	move.l	#$01f00000,$40(a5)
	move.l	other_screen,a0
		
	move.l	a0,$54(a5)
	move	#20,$58(a5)	
	rts
;---------------------------------
wait_blitter:
	btst	#14,$dff002
	bne.s	wait_blitter
	rts
;---------------------------------
display_object:
	move.l	#$ffff0000,$dff044
	move	nbs,d7
	subq	#1,d7
	lea	new_pos,a0
	lea	datas_balls,a6
	lea	tbl_tri,a5
displ0:	move	(a5),d6
	addq	#4,a5
	lsl	#3,d6
	move	(a0,d6.w),d0
	move	2(a0,d6.w),d1
	move	6(a0,d6.w),d3
	move	d3,d6
	lsl	#3,d6
	sub	6(a6,d6.w),d0
	sub	6(a6,d6.w),d1
	bsr	aff_ball

	dbf	d7,displ0
	rts
;-------------------------------
tri_balls:
	lea	new_pos+4,a0
	lea	tbl_tri,a1
	moveq	#0,d1
	move	nbs,d0
	subq	#1,d0	
init_t0:move	d1,(a1)+
	move	(a0),(a1)+
	addq	#1,d1

	addq	#8,a0
	dbf	d0,init_t0



	move	nbs,d0
	subq	#2,d0
	lea	tbl_tri,a0
tri0:
	move	d0,d1
	lea	4(a0),a1
tri1:
	move.l	(a0),d2
	move.l	(a1)+,d3

	cmp	d2,d3
	bge.s	tri3

	dbf	d1,tri1


	lea	4(a0),a0
	dbf	d0,tri0
	rts

tri3:	
	move.l	d2,-4(a1)
	move.l	d3,(a0)
	dbf	d1,tri1

	lea	4(a0),a0
	dbf	d0,tri0
	rts	

;-----------------------------
nbs:	dc.w	0


objs:	blk.b	4000,0
objs2:	blk.b	1000,0


;------------------------------	
init_centre:
	move	add_centrx,x0+2
	move	add_centry,y0+2
	rts
add_centrx:	dc.w	0
add_centry:	dc.w	0
x_pt_rot:	dc.w	0
y_pt_rot:	dc.w	0
z_pt_rot:	dc.w	0
;------------------------------
rot_balls:
	bsr	init_angl
	bsr	init_translation_x
	bsr	init_translation_y
	bsr	init_translation_z
	bsr	init_matrice
	bsr	mul_matrice_z
	bsr	mul_matrice_y
	bsr	mul_matrice_x
	bsr	mul_matrice_balls
	rts
;--------------------------
init_angl:
	move	xa,xangl+2
	move	ya,yangl+2
	move	za,zangl+2
	rts
;---------------------------
init_translation_x:
	move	x_pt_rot,d0
	move	d0,xoffs+2
	neg	d0
	move	d0,offx+2
;--------------------------
init_translation_y:
	move	y_pt_rot,d0
	move	d0,yoffs+2
	neg	d0
	move	d0,offy+2
	rts

i_balls:	blk.b	5200,0
;--------------------------
init_translation_z:
	move	z_pt_rot,d0
	move	d0,zoffs+2
	neg	d0
	move	d0,offz+2
	rts
;---------------------------
get_sinus:
	tst	d0
	bpl.s	noaddi
	addi	#360,d0
noaddi:	
	lea	tblsin,a1
	move.l	d0,d2
	lsl	#1,d0
	move	(a1,d0.w),d1
	cmpi	#270,d2
	blt.s	plus9
	subi	#270,d2
	bra.s	suitsin
plus9:	addi	#90,d2
suitsin:lsl	#1,d2
	move	(a1,d2.w),d2
	rts
;---------------------------
init_matrice:
	lea	matrice,a0
	move.l	#$40000000,0(a0)
	move.l	#$40000000,8(a0)
	move	#$4000,16(a0)
	clr.l	4(a0)
	clr.l	12(a0)
	rts
;----------------------
mul_matrice_x:
xangl:	move	#0,d0
	bsr	get_sinus

	move	d1,d3
	move	d2,d4
	move	m11,r11
	move	m21,r21
	move	m31,r31
	muls	m12,d2
	muls	m13,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r12
	move	d3,d1
	move	d4,d2
	muls	m22,d2
	muls	m23,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r22
	move	d3,d1
	move	d4,d2
	muls	m32,d2
	muls	m33,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r32
	move	d3,d1
	move	d4,d2
	muls	m12,d1
	muls	m13,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r13
	move	d3,d1
	move	d4,d2
	muls	m22,d1
	muls	m23,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r23
	muls	m32,d3
	muls	m33,d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	d4
	move	d4,r33
	lea	matrice2,a1
	lea	matrice,a2
	moveq	#8,d7
rotxlop1:move	(a1)+,(a2)+
	dbf	d7,rotxlop1
	rts
;----------------------
mul_matrice_y:
yangl:	move	#0,d0
	bsr	get_sinus

	move	d1,d3
	move	d2,d4
	muls	m11,d2
	muls	m13,d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r11
	move	d3,d1
	move	d4,d2
	muls	m21,d2
	muls	m23,d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r21
	move	d3,d1
	move	d4,d2
	muls	m31,d2
	muls	m33,d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r31
	neg	d3
	move	d3,d1
	move	d4,d2
	move	m12,r12
	move	m22,r22
	move	m32,r32
	muls	m11,d1
	muls	m13,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r13
	move	d3,d1
	move	d4,d2
	muls	m21,d1
	muls	m23,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r23
	muls	m31,d3
	muls	m33,d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	d4
	move	d4,r33

	lea	matrice2,a1
	lea	matrice,a2
	moveq	#8,d7
rotylop1:move	(a1)+,(a2)+
	dbf	d7,rotylop1
	rts
;--------------------------
mul_matrice_z:
zangl:	move	#0,d0
	bsr	get_sinus

	move	d1,d3
	move	d2,d4
	muls	m11,d2
	muls	m12,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r11
	move	d3,d1
	move	d4,d2
	muls	m21,d2
	muls	m22,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r21
	move	d3,d1
	move	d4,d2
	muls	m31,d2
	muls	m32,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r31
	move	d3,d1
	move	d4,d2
	muls	m11,d1
	muls	m12,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r12
	move	d3,d1
	move	d4,d2
	muls	m21,d1
	muls	m22,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	d2
	move	d2,r22
	muls	m31,d3
	muls	m32,d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	d4
	move	d4,r32
	move	m13,r13
	move	m23,r23
	move	m33,r33
	lea	matrice2,a1
	lea	matrice,a2
	moveq	#8,d7
rotzlop1:move	(a1)+,(a2)+
	dbf	d7,rotzlop1
	rts
;------------------------
mul_matrice_balls:
	move	nbs,d0
	subq	#1,d0

	lea	coords_balls,a1
	lea	new_pos,a2

mmb:	move	(a1)+,d1
offx:	addi	#0,d1
	move	d1,d4
	move	(a1)+,d2
offy:	addi	#0,d2
	move	d2,d5
	move	(a1)+,d3
offz:	addi	#0,d3
	move	d3,d6

	muls	m11,d1
	muls	m21,d2
	muls	m31,d3
	add.l	d1,d2
	add.l	d2,d3
	lsl.l	#2,d3
	swap	d3
xoffs:	addi	#0,d3

	move	d3,(a2)+
	move	d4,d1
	move	d5,d2	
	move	d6,d3
	muls	m12,d1
	muls	m22,d2
	muls	m32,d3
	add.l	d1,d2
	add.l	d2,d3
	lsl.l	#2,d3
	swap	d3
yoffs:	addi	#0,d3

	move	d3,(a2)+
	muls	m13,d4
	muls	m23,d5
	muls	m33,d6
	add.l	d4,d5
	add.l	d5,d6
	lsl.l	#2,d6
	swap	d6
zoffs:	addi	#0,d6
	move	d6,(a2)+
	move	(a1)+,(a2)+
	dbf	d0,mmb
	rts
;---------------------
set_perspective:
	lea	new_pos,a1
	move	nbs,d0
	subq	#1,d0

spe0:	move	4(a1),d5
	move	d5,d6
	move	distance,d4
	sub	d5,d4
	ext.l	d4
	lsl.l	#8,d4
	move	projec_z,d3
	ext.l	d3
	sub.l	d6,d3
	bne.s	spe1

	clr.l	(a1)
	bra.s	spe2

spe1:	divs	d3,d4
	move	d4,d3
	move	(a1),d1
	move	d1,d2
	neg	d1
	muls	d1,d3
	lsr.l	#8,d3

	add	d3,d2
x0:	addi	#0,d2
	move	d2,0(a1)
	move	2(a1),d1
	move	d1,d2
	neg	d1
	muls	d1,d4
	lsr.l	#8,d4

	add	d4,d2
	neg	d2
y0:	addi	#0,d2
	move	d2,2(a1)
spe2:
	lea	8(a1),a1
	dbf	d0,spe0
	rts

tblsin:	blk.b	800,0
;-------------------
anim_balls:
	move	xi,d0
	add	d0,xa
	cmpi	#360,xa
	ble	less0
	subi	#360,xa
less0:
	move	yi,d0
	addi	d0,ya
	cmpi	#360,ya
	ble	less1
	subi	#360,ya

less1:	
	move	zi,d0
	add	d0,za
	cmpi	#360,za
	ble	less2
	subi	#360,za
less2:
	rts
;------------------------------
distance:	dc.w	0
projec_z:	dc.w	-$100
matrice:
m11:	dc.w	0
m12:	dc.w	0
m13:	dc.w	0
m21:	dc.w	0
m22:	dc.w	0
m23:	dc.w	0
m31:	dc.w	0
m32:	dc.w	0
m33:	dc.w	0
matrice2:
r11:	dc.w	$4000
r12:	dc.w	0
r13:	dc.w	0
r21:	dc.w	0
r22:	dc.w	$4000
r23:	dc.w	0
r31:	dc.w	0
r32:	dc.w	0
r33:	dc.w	$4000
xa:	dc.w	0
ya:	dc.w	0
za:	dc.w	0
datas_balls:
	dc.w	34,8195,0,16
	dc.w	34,8195,4,10
	dc.w	36,4098,8,8
	dc.w	36,2050,12,4

liste_registres:
	dc.l	xi,yi,zi,nbs,add_centrx,add_centry
	dc.l	x_pt_rot,y_pt_rot,z_pt_rot	
init_obj:
	clr	distance
	clr	xa
	clr	ya
	clr	za
	cmpi	#3,nb_obj
	bne.s	noskier
	move	#90,ya
noskier:
	cmpi	#4,nb_obj
	bne.s	nologo
	move	#-250,distance
nologo:
	cmpi	#5,nb_obj
	bne.s	noloz
	move	#20,ya
	move	#90,xa
noloz:
	cmpi	#7,nb_obj
	bne.s	nodam

	move	#$1234,d5
	move.l	current_obj,a0
	jsr	530(a0)

nodam:	lea	liste_registres,a2
	move.l	current_obj,a0
	move	6(a0),d1
	moveq	#8,d0
init_o0:
	move.l	(a2)+,a1
	move	(a0)+,(a1)+
	dbf	d0,init_o0

	lea	coords_balls,a1
	lea	datas_balls,a2
	subq	#1,d1
init_o1:move	6(a0),d0
	move	d0,6(a1)
	lsl	#3,d0
	move	4(a2,d0.w),d0
	move	(a0),d2
	move	d2,(a1)

	move	2(a0),d2
	move	d2,2(a1)

	move	4(a0),d2
	move	d2,4(a1)
	lea	8(a1),a1
	lea	8(a0),a0
	dbf	d1,init_o1
	rts

xi:	dc.w	0
yi:	dc.w	0
zi:	dc.w	0
logo:	blk.b	8300,0

set_fondu:

	lea	tbl_fondu,a1	
	lea	tbl_fondu+1088,a3
	moveq	#0,d6
s_fondu:
	lea	logo+8200,a0
	lea	i_balls+5120,a2

	moveq	#0,d5
	moveq	#31,d7
fondu0:
	addq	#1,d5
	cmpi	#16,d5
	bhi	no_balls

	move	(a2)+,d0
	move	d0,d1
	move	d1,d2

	andi	#$f,d0
	andi	#$f0,d1
	andi	#$f00,d2

	mulu	d6,d0
	mulu	d6,d2	
	mulu	d6,d1
	
	lsr	#4,d0
	lsr	#4,d1
	lsr	#4,d2

	andi	#$f,d0
	andi	#$f0,d1
	andi	#$f00,d2

	or	d1,d0
	or	d2,d0
	move	d0,(a3)+

no_balls:

	move	(a0)+,d0
	move	d0,d1
	move	d1,d2

	andi	#$f,d0
	andi	#$f0,d1
	andi	#$f00,d2

	mulu	d6,d0
	mulu	d6,d2	
	mulu	d6,d1
	
	lsr	#4,d0
	lsr	#4,d1
	lsr	#4,d2

	andi	#$f,d0
	andi	#$f0,d1
	andi	#$f00,d2

	or	d1,d0
	or	d2,d0
	move	d0,(a1)+

	dbf	d7,fondu0

	addq	#1,d6
	cmpi	#17,d6
	bne.l	s_fondu
	rts

balls_out:
	move	#1,sf
	move	#16,sf+2
	move	#1,sf+4
	move	#1,do_balls_fondu
	rts
logo_out:
	moveq	#0,d3
	moveq	#15,d4	
	moveq	#1,d5
	bra.s	logo_col

balls_in:
	move	#16,sf
	move	#0,sf+2
	move	#-1,sf+4
	move	#1,do_balls_fondu
	rts
logo_in:
	moveq	#16,d3
	moveq	#0,d4
	moveq	#-1,d5

logo_col:
	move	d3,d0
lin0:	lea	tbl_fondu,a0
	lea	copper_list+$36,a1
	moveq	#16,d1
	sub	d0,d1
	lsl	#6,d1
	lea	0(a0,d1.w),a0

	move	#31,d1
lin2:	move	(a0)+,(a1)
	addq	#4,a1
	dbf	d1,lin2

	move	#15000,d1
w:	nop
	dbf	d1,w

lin3:	cmp.B	#$ff,$dff006
	bne.s	lin3

	add	d5,d0
	cmp	d0,d4
	bne.s	lin0
	rts


do_balls_fondu:	dc.w	0
sf:	dc.w	0,0,0


balls_fondu:
	tst	do_balls_fondu
	beq	nofondu

	lea	sf,a0
	movem	(a0)+,d3-d5

	move	d3,d0
alin0:	lea	tbl_fondu+1088,a0
	lea	copper_list+$ca,a1
	
	moveq	#16,d1
	sub	d0,d1
	
	
	lsl	#5,d1
	lea	0(a0,d1.w),a0

	moveq	#15,d1
alin2:	move	(a0)+,(a1)
	addq	#4,a1
	dbf	d1,alin2

	add	d5,d0
	move	d0,sf
	cmp	d0,d4
	bne	nofondu

	clr	lum	
	clr	do_balls_fondu
nofondu:
	rts


;---------------------------------------
liste_obj:	dc.l	objs,objs+660,objs+1068,obj4,objs+1396
		dc.l	objs+2404,objs+2832,objs2,0
nb_obj:		dc.w	0
current_obj:	dc.l	objs
do_change:	dc.w	0
lum:		dc.w	0
please_wait:	dc.w	0
change_obj:
	tst	do_change
	beq.L	nocha

	cmpi	#1,do_change
	bne.s	suit_chg

	move	#1,lum
	jsr	balls_out
	clr	please_wait
	move	#2,do_change
	rts
	
suit_chg:
	tst	lum
	bne.s	nocha

	addq	#1,please_wait
	cmpi	#10,please_wait
	bmi.s	nocha

	addq	#1,nb_obj
	move	nb_obj,d0
	lsl	#2,d0
	lea	liste_obj,a0
	move.l	0(a0,d0.w),d1
	tst.l	d1
	bne.s	chg_o0
	move	#-1,nb_obj
	bra.s	change_obj
chg_o0:	move.l	d1,current_obj
	jsr	init_obj
	jsr	init_centre
	clr	do_change
	jsr	balls_in
nocha:
	rts		
		

anim_intern:
	move.l	current_obj,a1
	lea	coords_balls,a4
	lea	get_sinus,a5

	tst	nb_obj
	bne	anim2

	move	#20,d0
	move	#18,d1

	jmp	538(a1)

anim2:
	cmpi	#1,nb_obj
	bne	anim3

	move	#6,d0
	move	#40,d1
	jmp	338(a1)
anim3:
	cmpi	#2,nb_obj
	bne	anim4

	move	#14,d0
	move	#100,d1
	move	#80,d2
	lea	distance,a4
	jmp	282(a1)
anim4:
	cmpi	#3,nb_obj
	bne	anim5
	
	move	#20,d0
	jmp	anim_balls2

anim5:
	cmpi	#4,nb_obj
	bne	anim6

	lea	distance,a4
	lea	xa,a0
	jmp	986(a1)
	
anim6:
	cmpi	#5,nb_obj
	bne	anim7
	
	move	#20,d0
	lea	distance,a4
	jmp	386(a1)
anim7:
	cmpi	#6,nb_obj
	bne	anim8
	move	#10,d0
	lea	distance,a4
	jmp	514(a1)
anim8:
	cmpi	#7,nb_obj
	bne	anim9

	lea	xi,a2
	lea	xa,a3
	jmp	530(a1)

anim9:
	rts

obj4:	dc.w	0,356,0,52,140,70,30,0,0

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
	lea	coords_balls,a4
	lea	get_sinus,a5
	lea	pt_h(pc),a6
	move	(a6),d7

	add	#20,d7
	cmpi	#360,d7
	bmi.s	a_b3_0
	subi	#360,d7
a_b3_0:
	move	d7,(a6)

	lea	obj4+18,a0

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
char:	blk.b	900,0

scroll:
	bsr	decal_scroll
	bsr	new_scroll
	rts

new_scroll:
	move	speed_scr,d0
	add	d0,phase_scr
	cmpi	#8,phase_scr
	bmi	end_new_scroll

newsc0:	clr	phase_scr
	lea	texte,a0
	
	move	letter_scr,d0
	addi	#1,letter_scr
	moveq	#0,d1
	move.b	0(a0,d0),d1		
	beq	end_of_text
	cmpi.w	#8,d1
	bhi	nomodspeed
	move.w	d1,speed_scr
	bra	newsc0
end_of_text:clr	letter_scr
	bra	newsc0	
nomodspeed:
	lea	difchar,a0
	moveq	#-2,d0
newsc1:	move.b	(a0)+,d2
	bne	carac_connu			
	moveq	#0,d0
	bra	newsc2
carac_connu:
	addq	#2,d0
	cmpi.b	d1,d2
	bne	newsc1
newsc2:
	lea	char,a0
	lea	char_adr,a1
	move	(a1,d0.w),d0
	lea	0(a0,d0.w),a0
	lea	buf_scr,a1
	moveq	#9,d0	
newsc3:	move.b	(a0),40(a1)
	add	#40,a0
	add	#42,a1
	dbf	d0,newsc3
end_new_scroll:
	rts
	even
letter_scr:	dc.l	0
phase_scr:	dc.l	0
difchar: dc.b "ABCDEFGHIJKLMNOPQUVWXYZ0123456789 !.,[]'"
	dc.b	"RST()?/:-+><&*$#",0
	even
speed_scr:dc.w	1
texte:
	blk.b	80,32

	dc.b	"MICROTEL BREST !!! YEAH !!!"
	dc.b	"     UN CLUB BIEN BRETON,BIEN DE CHEZ NOUS....   "
	dc.b	"       MERCI AU CLUB DE RENNES ET AUX AUTRES POUR "
	dc.b	"CETTE MEMORABLE JOURNEE...  26 MAI 1990           "
	dc.b	0
	

h=400
	even
char_adr:dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
	dc.w	20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
	dc.w	36,37,38,39,h,h+1,h+2,h+3,h+4,h+5,h+6,h+7,h+8,h+9
	dc.w	h+10,h+11,h+12,h+13,h+14,h+15

decal_scroll:
	lea	buf_scr,a1
	moveq	#9,d0
dec0:
	lea	42(a1),a0
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	roxl.w	-(a0)
	lea	42(a1),a1
	dbf	d0,dec0	
	rts

colors:
	dc.w	$f,$22f,$44f,$66f,$88f,$aaf,$ccf,$ddf,$fff
	
mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	move.b	mt_data+$3b7,mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	move.b	$3(a6),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	cmp.b	#$1f,$3(a6)
	ble.s	mt_sets
	move.b	#$1f,$3(a6)
mt_sets:move.b	$3(a6),d0
	beq.s	mt_rts2
	move.b	d0,mt_speed
	clr.b	mt_counter
mt_rts2:rts

mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:blk.l	$1f,0
mt_voice1:	blk.w	10,0
		dc.w	$1
		blk.w	3,0
mt_voice2:	blk.w	10,0
		dc.w	$2
		blk.w	3,0
mt_voice3:	blk.w	10,0
		dc.w	$4
		blk.w	3,0
mt_voice4:	blk.w	10,0
		dc.w	$8
		blk.w	3,0
mt_data:	blk.b	88600




coords_balls:	blk.b	1000
new_pos:	blk.b	1000
tbl_tri:	blk.b	600
tbl_fondu:	blk.b	17*64
		blk.b	17*32
buf_scr:	blk.b	600
copper_list:	blk.b	550
screen0:	blk.b	42000
screen1:	blk.b	42000
balls:		blk.b	23000
msk_balls:	blk.b	23000
