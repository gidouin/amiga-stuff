musix=$40000

nums=$52000
mask=$53000

screen_info=$59000
buffer=$64000
screen0=$6e000
screen1=$77000

tblcos=$7f000
tblsin=$7f800

>EXTERN"tblsin",tblsin
>EXTERN"tblcos",tblcos
>EXTERN"nums.pic",nums
>EXTERN"astaroth.bin",musix
;---------------------
start:
	move	#0,active_face

	move	#4,d0
	jsr	musix

	lea	buffer,a0
	lea	screen_info,a1
	move	#5119,d0
c:	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d0,c
	
	lea	mask,a0
k:	lea	trame,a1
	moveq	#19,d0
k0:	move.l	(a1)+,(a0)+
	dbf	d0,k0
	cmpa.l	#mask+10240,a0
	bmi	k

	move.b	#%10000111,$bfd100
	move.l	$4,a6
	jsr	-$84(a6)
	lea	$dff000,a6
	move	$2(a6),s_dma
	or	#$c000,s_dma
	
	move	$1c(a6),s_intena
	or	#$c000,s_intena

	move	#$7fff,$9a(a6)
	move.l	$6c.w,save_level3
	move.l	#own_level3,$6c.w
	move	#$c028,$9a(a6)

	move	#$3fff,$96(a6)
	move	#$83c0,$96(a6)

	move	#$3000,$100(a6)
	move.l	#$2c812ae1,$8e(a6)
	move.l	#$280028,$108(a6)	
	clr.l	$102(a6)
	move.l	#$3800d0,$92(a6)


	move.l	#$0ddd0ddd,$188(a6)
	move.l	#$0ddd0ddd,$18c(a6)

	jsr	set_screen
	lea	copper_list(pc),a0
	clr	2(a0)
	move	#$f,6(a0)
	move	#$aa,$a(a0)
	move	#$fff,$e(a0)
	move.l	a0,$80(a6)
	clr	$88(a6)	

	move	#768*64+20,w_sizec1
	clr	w_modc1
	move.l	#0,w_adrc1

	bsr	init_screen_info

	bsr	clear_screen
	bsr	wait_blitter
	bsr	swap_screens
	bsr	clear_screen

	clr	nb_objet
	bsr	select_objet
	bsr	init_obj

	
wait:
	cmpi.b	#$ff,$dff006
	bne.s	wait

	not.b	flag_active_color
	bsr	change_objet

	jsr	swap_screens
	jsr	set_screen
	jsr	clear_screen
	jsr	swap_dim
	jsr	rotations
	jsr	anim
	jsr	test_clavier

	jsr	tri_faces

	jsr	wait_blitter

	jsr	trace_obj

	jsr	calc_dim

	bsr	display_info

	bsr	animation_interne	

	bsr	wait_blitter
	
	btst	#6,$bfe001
	bne.s	wait

	move	#0,d0
	jsr	musix


	move	#$7fff,$dff09a
	move	#$7fff,$dff096
	move.l	save_level3,$6c.w
	move	s_dma,$dff096
	move	s_intena,$dff09a

	move.l	$4,a6
	lea	name_glib,a1
	moveq	#0,d0
	jsr	-$228(a6)
	move.l	d0,a0
	move.l	$26(a0),$dff080
	clr	$dff088
	jmp	-$8a(a6)
s_dma:	dc.w	0
s_intena:dc.w	0
name_glib:	dc.b	'graphics.library',0
	even

own_level3:
	movem.l	d0-d7/a0-a6,-(a7)

	jsr	musix+4
	bsr	set_colors

	movem.l	(a7)+,d0-d7/a0-a6
	move.w	#$20,$dff09c
	rte

copper_list:
	dc.l	$01800000,$01820000,$01840000,$01860000
	dc.l	$2a0ffffe,$01800f8f,$2adffffe,$01800000
	dc.l	$e20000,$e00000
	dc.l	$e60000,$e40000
	dc.l	$ea0000,$e80000
	dc.l	$ffdffffe
	dc.l	$2b0ffffe,$01800f8f,$2bdffffe,$01800000
	dc.l	$fffffffe

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

	lea	copper_list+32(pc),a0

	move.l	used_screen(pc),d0
	bsr.s	install_screen
	
	addi	#$28,d0
	bsr.s	install_screen

	move.l	#screen_info,d0
install_screen:
	move	d0,$2(a0)
	swap	d0
	move	d0,$6(a0)
	swap	d0
	addq	#$8,a0
	rts
;---------------------------------
clear_screen:

	lea	$dff000,a5
	move.l	#$ffffffff,$44(a5)
	move	w_modc1,$66(a5)
	clr	$66(a5)
	clr	$74(a5)
	move.l	#$01f00000,$40(a5)
	move.l	other_screen(pc),a0
	add.l	w_adrc1,a0
	move.l	a0,$54(a5)
	move	w_sizec1,$58(a5)	
	rts

wait_blitter:
	move	#$8400,$dff096
wb:	btst	#14,$dff002
	bne.s	wb
	move	#$400,$dff096
	rts

;------------------------------	
xcentr:	dc.w	160
ycentr:	dc.w	120
xrot:	dc.w	0
yrot:	dc.w	0
zrot:	dc.w	0
;------------------------------
rotations:
	move	nbs,d7

	lea	coords_pt,a0
	lea	new_coords,a1
	lea	tblsin,a2
	lea	tblcos,a3

	move	za,d3
	move	d3,d4
	add	d3,d3
	add	d4,d4
	move	0(a3,d3.w),cos_tz+2
	move	0(a2,d4.w),sin_tz+2

	move	xa,d3
	move	d3,d4
	add	d3,d3
	add	d4,d4
	move	0(a3,d3.w),cos_tx+2
	move	0(a2,d4.w),sin_tx+2

	move	ya,d3
	move	d3,d4
	add	d3,d3
	add	d4,d4
	move	0(a3,d3.w),cos_ty+2
	move	0(a2,d4.w),sin_ty+2

	subq	#1,d7

rot0:
	movem	(a0)+,d0-d3

	sub	xrot(pc),d0
	sub	yrot(pc),d1
	sub	zrot(pc),d2

cos_tz:	move	#$0,d3
sin_tz:	move	#$0,d4
	move	d4,d5
	move	d3,d6

	muls	d0,d6		
	muls	d1,d5		
	add.l	d6,d5

	muls	d4,d0
	muls	d3,d1
	sub.l	d0,d1

	lsl.l	#2,d1
	swap	d1

	move.l	d5,d0
	lsl.l	#2,d0
	swap	d0

cos_tx:	move	#$0,d3
sin_tx:	move	#$0,d4
	move	d3,d5
	move	d4,d6

	muls	d1,d5
	muls	d2,d6
	add.l	d5,d6
	lsl.l	#2,d6
	swap	d6
	
	muls	d4,d1
	muls	d3,d2
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	d2

	move.l	d6,d1
	
cos_ty:	move	#$0,d3
sin_ty:	move	#$0,d4
	move	d3,d5
	move	d4,d6

	muls	d0,d5
	muls	d2,d6
	sub.l	d6,d5
	lsl.l	#2,d5
	swap	d5
	muls	d4,d0
	muls	d3,d2
	add.l	d0,d2

	lsl.l	#2,d2
	swap	d2
	move.l	d5,d0

	
	add	xrot(pc),d0
	add	yrot(pc),d1
	add	zrot(pc),d2

	add	#512,d2


	ext.l	d0
	lsl.l	#8,d0
	divs	d2,d0

	ext.l	d1
	lsl.l	#8,d1
	divs	d2,d1

	move	distance,d3
	addi	#256,d3

	ext.l	d0
	lsl.l	#8,d0
	divs	d3,d0

	ext.l	d1
	lsl.l	#8,d1
	divs	d3,d1

	add	xcentr(pc),d0
	add	ycentr(pc),d1

	movem	d0-d2,(a1)
	addq	#$8,a1

	dbf	d7,rot0
	rts

anim:
	lea	xi(pc),a0
	lea	xa(pc),a1
	moveq	#2,d0
an0:
	move	(a1),d1
	add	(a0)+,d1
	bge.s	an1
	addi	#360,d1
an1:	cmpi	#360,d1
	bmi.s	an2
	subi	#360,d1
an2:	move	d1,(a1)+
	dbf	d0,an0
	rts
;------------------------------
distance:	dc.w	0

xa:	dc.w	0
ya:	dc.w	0
za:	dc.w	0

xi:	dc.w	0
yi:	dc.w	0
zi:	dc.w	0

nb_faces:	dc.w 	12+2+4
nbs:		dc.w	14+8
pt_faces:	dc.l	0
dat_x:		dc.l	0
dat_y:		dc.l	0
dat_z:		dc.l	0

colors:	dc.l	0,0
adr_objet:	dc.l	0

init_obj:
	move.l	adr_objet(pc),a0

	move.l	(a0)+,animation_routine	
	clr	pt_anim

	move	(a0)+,nb_faces
	move	(a0)+,nbs
	move	(a0)+,distance
	move	(a0)+,xi
	move	(a0)+,yi
	move	(a0)+,zi
	move	(a0)+,xa
	move	(a0)+,ya
	move	(a0)+,za

	move.l	(a0)+,colors
	move.l	(a0)+,colors+4

	move	#1,sens_fondu

	move	(a0)+,xrot
	move	(a0)+,yrot
	move	(a0)+,zrot


	move	nbs(pc),d0
	add	d0,d0
	lea	0(a0,d0.w),a1
	lea	0(a1,d0.w),a2
	lea	0(a2,d0.w),a3

	move.l	a0,dat_x
	move.l	a1,dat_y
	move.l	a2,dat_z
	move.l	a3,pt_faces

	lea	coords_pt,a3
	move	nbs,d0
	subq	#1,d0
init_o0:
	move	(a0)+,(a3)+
	move	(a1)+,(a3)+
	move	(a2)+,(a3)+
	clr	(a3)+
	dbf	d0,init_o0
	rts

trace_obj:

	clr	max_xc
	clr	max_yc
	move	#$200,min_xc
	move	#$200,min_yc

	clr	nb_vizib

	lea	new_coords,a0
	lea	tbl_tri,a5
	lea	adr_faces,a6

	move	nb_faces,d7
	subq	#1,d7
trace_faces:

	move	(a5),d0
	cmp	active_face,d0
	seq	flag_active
normal_face:
	addq	#4,a5

;			move.l	a5,-(a7)	;sert pour clipping
	lsl	#2,d0
	move.l	0(a6,d0.w),a1

	cmpi	#2,2(a1)
	beq	ligne

	move	(a1),color_face
	bge.s	tst_vu
	neg	color_face

	bra.s	vu
tst_vu:
	cmpi	#1,2(a1)
	beq.s	vu	;si sphere,alors visible

	bsr	test_visibl
	tst	ok_visibl
	bne	no_vu
vu:
	addq	#2,a1
	move	(a1)+,d4
	subq	#1,d4

	tst.b	flag_active
	beq.s	no_actived_face
	tst.b	flag_active_color
	bne.w	no_actived_face

;	not	color_face
no_actived_face:
	move	color_face,d5
	btst	#8,d5
	sne	face_transparente

	move	d5,d6
	andi	#$f,d5
	lsr	#4,d6
	andi	#$f,d6

	move	d5,trame_or
	or	d6,trame_or
	move	d5,trame_and
	and	d6,trame_and
actived_face:
	clr	pt_trame
	clr	max_x
	clr	max_y
	move	#$200,min_x
	move	#$200,min_y

	move	#80,$dff066
	move	#80,$dff060
	move	#$8000,$dff074
	move	#$ffff,msk+2

	lea	buffer,a2

	move.l	#$0b4a0003,bltcon


	clr	right_border
	clr	sup_rightb
	move	#255,inf_rightb

	clr	nb_clipping_right
	lea	tbl_clipping_right,a3
	clr	nb_clipping_left
;	lea	tbl_clipping_left,a5

	tst	d4
	beq	sphere

trace_lignes:

	move	(a1)+,d5
	move	(a1)+,d6

	subq	#1,d5
	subq	#1,d6
	lsl	#3,d5
	lsl	#3,d6
	
	move	0(a0,d5.w),d0
	move	2(a0,d5.w),d1
	move	0(a0,d6.w),d2
	move	2(a0,d6.w),d3

clip_right:
	movem.l	d4/d7,-(a7)

	lea	min_x,a4
	bsr	clipping

	tst	flag_face
	bne.s	depas

	bsr	find_lim
	bsr	draw_line
depas:
	movem.l	(a7)+,d4/d7


	dbf	d4,trace_lignes

	bsr	set_borders

suite_sphere:

	movem.l	d7/a0/a5/a6,-(a7)	

	bsr	window_dim

	tst	inv
	bne.s	out_screen

	bsr	fill_window
	addq	#1,nb_vizib

	clr	pt_trame
	btst	#0,max_y+1
	beq.s	ligne_paire	;meme base de tramage pour toutes les
				;faces (pour la transparence)
	addi	#40,pt_trame
ligne_paire:

	move.l	other_screen,a0
	moveq	#0,d6
all_planes:
	btst	d6,trame_or+1
	beq.s	no_plane0

	bsr	fill_plane
	bra.s	other_plane0
no_plane0:
	bsr	clear_plane
other_plane0:

	lea	40(a0),a0
	addq	#1,d6

	cmpi	#2,d6
	bne	all_planes
	
	bsr	clear_window	

	move	min_x,d0
	move	min_y,d1
	move	max_x,d2
	move	max_y,d3

	bsr	def_cadre
out_screen:
	movem.l	(a7)+,d7/a0/a5/a6
no_vu:
	bsr	wait_blitter

;	move.l	(a7)+,a5		;restore tbl_tri
	dbf	d7,trace_faces
	rts

ligne:
	clr	max_x
	clr	max_y
	move	#$200,min_x
	move	#$200,min_y

	move	#80,$dff066
	move	#80,$dff060
	move	#$8000,$dff074

	clr	right_border
	clr	sup_rightb
	move	#255,inf_rightb

	move.l	d7,-(a7)

	move	(a1),d7
	move	4(a1),d5
	move	6(a1),d6

	subq	#1,d5
	subq	#1,d6
	lsl	#3,d5
	lsl	#3,d6
	
	move	0(a0,d5.w),d0
	move	2(a0,d5.w),d1
	move	0(a0,d6.w),d2
	move	2(a0,d6.w),d3


	lea	min_x,a4
	bsr	clipping

	tst	flag_face
	bne.s	dep

	bsr	def_cadre

	move.l	other_screen,a2
	moveq	#0,d6	
li0:
	move.l	#$0bca0001,bltcon
	move	#$ffff,msk+2

	btst	d6,d7
	bne	nopl

	move.l	#$0bca0001,bltcon
	move	#$0,msk+2
nopl:
	movem.l	d0-d7/a2,-(a7)	
	bsr	draw_line
	movem.l	(a7)+,d0-d7/a2
	jsr	wait_blitter

	add.l	#40,a2
	addq	#1,d6
	cmpi	#2,d6
	bne	li0
dep:
	move.l	(a7)+,d7
	bra	no_vu	


draw_line:
	cmp	d1,d3
	bne	noteg
	cmp	d0,d2
noteg:	bge.s	noexg
	exg	d0,d2
	exg	d1,d3
noexg:
	sub	d0,d2
	sub	d1,d3

	mulu	#80,d1

	moveq	#$f,d5
	move	d0,d4
	lsr	#3,d4
	bclr	#0,d4
	add	d4,d1
	and.l	d5,d0
	move	d0,d4
	ror.l	#4,d0
	not	d4
	and	d5,d4
	moveq	#0,d5
	bset	d4,d5
	bset	#2,d0
	tst	d2
	bpl.s	xless
	neg	d2
	eori	#1,d0
xless:
	cmp	d3,d2
	bhi.s	yless
	exg	d3,d2
	bclr	#2,d0
	add	d0,d0
yless:
	move	d3,d4
	sub	d2,d4
	lsl	#2,d4
	add	d3,d6
	move	d3,d6
	sub	d2,d6
	bpl.s	no_same
	ori	#$10,d0
no_same:
	lsl	#2,d3
	lsl	#2,d0
	addq	#1,d2
	lsl	#6,d2
	addq	#2,d2
	swap	d3
	move	d4,d3

	move.l	bltcon,d4
	or.l	d4,d0
	move	d1,d4

	move	#$8400,$dff096
wbi:	btst	#$e,$dff002
	bne.s	wbi
	move	#$400,$dff096

	eor	d5,$00(a2,d1.w)
	add.l	a2,d1
msk:	move	#$0,$dff072
	move.l	d0,$dff040
	move.l	d1,$dff048
	move.l	d1,$dff054	
	move.l	d6,$dff050
	move.l	d3,$dff062
	move	d2,$dff058		
	rts

bltcon:	dc.l	0

rayon:		dc.w	40
centre_x:	dc.w	160
centre_y:	dc.w	200

save_sp:	dc.l	0

sphere:
	movem.l	d0-d7/a0-a6,-(a7)

	clr	inv
	
	move	(a1)+,d0
	subq	#1,d0
	lsl	#3,d0
	move	0(a0,d0.w),centre_x
	move	2(a0,d0.w),centre_y

	move	4(a0,d0.w),d2
	add	distance,d2
;	subi	#128,d2

	move	(a1),d0
	ext.l	d0
	lsl.l	#8,d0
	divs	d2,d0

;	ext.l	d0
;	lsl.l	#8,d0
;	move	distance,d2
;	addi	#$100,d2
;	divs	d2,d0


	move	d0,rayon


	move	centre_x(pc),d0
	move	centre_y(pc),d1
	move	d0,d2
	move	d1,d3
	move	rayon(pc),d4
	sub	d4,d0
	sub	d4,d1
	add	d4,d2
	add	d4,d3
	bsr	find_lim	


	move	rayon(pc),d3

	moveq	#0,d0
	move	d3,d1
	bsr	get_start_point
	move.l	a0,a5
	move.w	d0,d5

	move	d3,d0
	moveq	#0,d1
	bsr	get_start_point
	move.l	a0,a6
	move.w	d0,d6

	move	d3,d0
	neg	d0
	moveq	#0,d1
	bsr	get_start_point
	move.l	a0,a4
	move.w	d0,d4


	suba.l	a0,a0		;x=0
	suba.l	a1,a1
	move	d3,a1	;y=rayon


	move	d3,d0
	muls	#$2d41,d0
	lsl.l	#2,d0
	swap	d0
;	subq	#1,d0		;nb de pixels pour arc pi/4 rad

	moveq	#$3,d1
	sub	rayon(pc),d1
	sub	rayon(pc),d1	;D de départ


	move.l	a7,save_sp

	move.l	a5,a7
	move.w	d5,d7

	move	#80,a3		;taille ligne
repeat:
	tst	d1
	bpl.s	vers_bas	
vers_droite:
	move	a0,d2	;utilise X pour caluler nouveau D
	lsl	#2,d2
	add	d2,d1
	addq	#$6,d1	;D = D + 4X + 6

	addq	#1,a0	;inc compteur interne X

	sub	a3,a6		;arc1 | 1 ligne vers le haut
	sub	a3,a4

	ror	#1,d7		;arc0 | pixel à droite
	bcc.s	arc_0		;arc0 | si <16 alors meme adresse
	addq	#2,a7		;arc0 | sinon suivante
arc_0:
	rol	#1,d5
	bcc.s	display_point	;arc2 | pixel à gauche
	subq	#2,a5		;arc2 | si <16 alors meme adresse

	bra.s	display_point

vers_bas:
	or	d7,(a7)
	or	d5,(a5)

	move	a0,d2		;X dans d2
	sub	a1,d2		;(x-y) dans d2
	lsl	#2,d2		;*4
	add	d2,d1		;+ D
	add	#$a,d1	;D = D + 4( X - Y ) + 10

	addq	#1,a0	;inc compteur interne X
	subq	#1,a1	;dec compteur interne Y

	add	a3,a7		;ligne suivante |arc0
	sub	a3,a6		;arc1 | ligne prec
	add	a3,a5		;arc2 | ligne suiv
	sub	a3,a4		;arc3 | ligne prec


	ror	#1,d7		;pixel à droite
	bcc.s	arc_2	;si <16 alors meme adresse
	addq	#2,a7
arc_2:
	rol	#1,d6		;pixel à gauche |arc1
	bcc.s	arc_3	
	subq	#2,a6
arc_3:
	rol	#1,d5		;idem |arc2
	bcc.s	arc_4
	subq	#2,a5
arc_4:
	ror	#1,d4		;arc3
	bcc.s	display_point
	addq	#2,a4
display_point:

	or	d6,(a6)
	or	d4,(a4)

	dbf	d0,repeat	

	move.l	save_sp(pc),a7


	move.l	a2,a6
	move	centre_y,d6
	mulu	#80,d6
	add.l	d6,a6

	move	rayon(pc),d1

	move	centre_x(pc),d0
	sub	d1,d0	
	lsr	#3,d0
	andi	#$fffe,d0	;mot offset
	add	d0,a6

	move	d1,d0
	lsr	#4,d0
	andi	#$fffe,d0

	add	d1,d1
	add	#$20,d1
	lsr	#4,d1

	move.l	#$09f00000,$dff040	;A=D
	move.l	#$ffffffff,$dff044	;bits masque à 1

	move.l	a6,$dff054	;Destination=adresse debut ligne milieu 
	sub.l	#80,a6
	move.l	a6,$dff050	;source A = Idem -40

	moveq	#-80,d2
	sub	d1,d2	
	sub	d1,d2	
	move	d2,$dff064	;modA negatif pour arriver au debut de la
				;ligne	precedente

	moveq	#80,d2
	sub	d1,d2
	sub	d1,d2
	move	d2,$dff066	;modulo D normal

	move	rayon,d0
	lsl	#6,d0
	or	d1,d0
	
	move	d0,$dff058	;taille ("rayon" lignes de "rayons"/16)

	move	#$8400,$dff096
wbli:	btst	#14,$dff002
	bne.s	wbli
	move	#$400,$dff096



;	lea	screen+10240,a0

;	move.l	a0,$dff050
;	move.l	a0,$dff054
;	move	#0,$dff064
;	move	#0,$dff066
;	move.l	#$09f0001a,$dff040
;	move.l	#-1,$dff044
;	move	#100*64+20,$dff058


	movem.l	(a7)+,d0-d7/a0-a6
	bra	suite_sphere


get_start_point:

	move.l	a2,a0
	move	centre_y(pc),d2
	sub	d1,d2
	mulu	#80,d2
	add.l	d2,a0

	add	centre_x(pc),d0
	move	d0,d1
	lsr	#3,d0
	andi.b	#$fe,d0
	add	d0,a0

	move.w	#$8000,d0
	andi	#$f,d1
	lsr	d1,d0
	rts


fill_window:
	lea	buffer,a2
	add.l	w_adr,a2

	move	#$8400,$dff096
wbl:	btst	#14,$dff002
	bne.s	wbl
	move	#$400,$dff096

	move.l	a2,$dff050
	move.l	a2,$dff054
	move	w_mod,$dff064
	move	w_mod,$dff066
	move.l	#$09f0001a,$dff040
	move.l	#-1,$dff044
	move	w_size,$dff058
	rts

clear_window:
	lea	buffer,a2
	add.l	w_adr,a2
	
	move	#$8400,$dff096
wblit:	btst	#14,$dff002
	bne.s	wblit
	move	#$400,$dff096

	move.l	a2,$dff054


	move	w_mod,$dff066

	clr	$dff074
	move.l	#$01f00002,$dff040
	move.l	#-1,$dff044
	move	w_size,$dff058
	rts

fill_plane:
	lea	buffer,a2
	add.l	w_adr,a2

	move.l	a0,a1
	add.l	w_adr,a1

	move	#$8400,$dff096
wblite:	btst	#14,$dff002
	bne.s	wblite
	move	#$400,$dff096
	
	move.l	a2,$dff050	;a
	move.l	a2,$dff04c	;b
	move.l	a1,$dff048	;c
	move.l	a1,$dff054	;d

	move	w_mod,$dff062
	move	w_mod,$dff064	;a
	move	w_mod,$dff066	;d
	move	w_mod,$dff060	;c

	btst	d6,trame_and+1
	bne.s	notram


	move.l	mask,a1
	add	pt_trame,a1
	add	#40,pt_trame	;;;;;

	move.l	a1,$dff04c
	move	w_mod,d0
	subi	#$28,d0
	move	d0,$dff062

notram:
	move.l	#$0fca0002,$dff040
	move.l	#-1,$dff044
	move	w_size,$dff058
	rts

clear_plane:
	tst.b	face_transparente
	bne.s	no_clear_bicoz_face_transparente

	lea	buffer,a2
	add.l	w_adr,a2

	move.l	a0,a1
	add.l	w_adr,a1

	move	#$8400,$dff096
wli:	btst	#14,$dff002
	bne.s	wli
	move	#$400,$dff096

	move.l	a2,$dff050
	move.l	a1,$dff04c	;b
	move.l	a1,$dff054	;d

	move	w_mod,$dff064
	move	w_mod,$dff066
	move	w_mod,$dff062

	move.l	#$0d0c0002,$dff040
	move.l	#-1,$dff044
	move	w_size,$dff058

no_clear_bicoz_face_transparente:
	rts

find_lim:
	cmp	min_x,d0
	bge.s	nxmin1	
	move	d0,min_x
nxmin1:	cmp	max_x,d0
	ble.s	nxmax1	
	move	d0,max_x
nxmax1:	
	cmp	min_x,d2
	bge.s	nxmin2	
	move	d2,min_x
nxmin2:	cmp	max_x,d2
	ble.s	nxmax2	
	move	d2,max_x
nxmax2:	

	cmp	min_y,d1
	bge.s	nymin1	
	move	d1,min_y
nymin1:	cmp	max_y,d1
	ble.s	nymax1	
	move	d1,max_y
nymax1:	
	cmp	min_y,d3
	bge.s	nymin2	
	move	d3,min_y
nymin2:	cmp	max_y,d3
	ble.s	nymax2	
	move	d3,max_y
nymax2:	
	rts


def_cadre:
	cmp	min_xc,d0
	bge.s	nxi1	
	move	d0,min_xc
nxi1:	cmp	max_xc,d0
	ble.s	nxa1	
	move	d0,max_xc
nxa1:	
	cmp	min_xc,d2
	bge.s	nxi2	
	move	d2,min_xc
nxi2:	cmp	max_xc,d2
	ble.s	nxa2	
	move	d2,max_xc
nxa2:
	cmp	min_yc,d1
	bge.s	nyi1	
	move	d1,min_yc
nyi1:	cmp	max_yc,d1
	ble.s	nya1	
	move	d1,max_yc
nya1:	
	cmp	min_yc,d3
	bge.s	nyi2	
	move	d3,min_yc
nyi2:	cmp	max_yc,d3
	ble.s	nya2	
	move	d3,max_yc
nya2:	
	rts


w_size:	dc.w	$fc6
w_adr:	dc.l	$1a80
w_mod:	dc.w	$1c



;---------------------------------


window_dim:
	clr	inv

	moveq	#0,d0
	move	min_y,d0
	cmp	#255,d0
	bmi	wd0
	move	#1,inv
	rts
wd0:
	moveq	#0,d1
	move	max_y,d1
	tst	d1
	bhi.s	wd1
	move	#1,inv
	rts
wd1:
	andi	#$ff,d1
	addq	#1,d1
	move	d1,d2
	sub	d0,d2
	addq	#1,d2
	mulu	#80,d1
	move	max_x,d0
	addi	#$10,d0
	lsr	#3,d0
	andi.b	#$fe,d0
	ext.l	d0
	add.l	d0,d1
	subq	#2,d1
	
	move.l	d1,w_adr
	move	min_x,d1
	lsr	#3,d1
	andi.b	#$fe,d1
	sub	d1,d0
	move	d0,d1
	lsr	#1,d1
	lsl.l	#6,d2
	add	d1,d2
	subi	#80,d0
	neg	d0
	move	d0,w_mod
	move	d2,w_size
	rts


w_sizec1:	dc.w	49172
w_adrc1:	dc.l	0
w_modc1:	dc.w	0
w_sizec2:	dc.w	49172
w_adrc2:	dc.l	0
w_modc2:	dc.w	0

right_border:	dc.w	0
sup_rightb:	dc.w	0
inf_rightb:	dc.w	0


set_borders:
	;avant window_dim & fill_window

	move.l	d7,-(a7)

	move	nb_clipping_right,d7
	lsr	#1,d7
	beq	no_right_clip
	lea	tbl_clipping_right,a3

	subq	#1,d7
all_clipping:
	move	#319,d0
	move	#319,d2
	move	(a3)+,d1
	move	(a3)+,d3

	bsr	find_lim
	bsr	draw_line


	dbf	d7,all_clipping

no_right_clip:

	move.l	(a7)+,d7
	rts

	move	nb_clipping_left,d7
	beq.s	no_left_clip
	lsr	#1,d7
	lea	tbl_clipping_left,a3
	subq	#1,d7

all_clipping_left:
	move	#0,d0
	move	#0,d2
	move	(a3)+,d1
	move	(a3)+,d3

	bsr	find_lim
	bsr	draw_line

	dbf	d7,all_clipping_left
	
no_left_clip:

	move.l	(a7)+,d7
	rts


fonction:
	btst	#0,d0
	beq	nofo
	move	#$9,d1
	sub	#$4d,d0
	lsr	#1,d0
	sub	d0,d1
	move	d1,new_objet
nofo:
	rts
test_clavier:
	

	moveq	#0,d0
	move.b	$bfec01,d0

	cmp	#$5f,d0
	bgt.s	pas_f
	cmp	#$4d,d0
	blt	pas_f
	bra	fonction
pas_f:
	cmp	#$6b,d0
	bne.s	zoom_m

	add	#18,distance
	bra.L	same_key
zoom_m:
	cmp	#$43,d0
	bne.s	zoom_p
	
	cmpi	#-210,distance
	ble.L	same_key

	subi	#10,distance

	bra.L	same_key
zoom_p:
	cmp	#$7f,d0
	bne	nostp
	
	clr	xi
	clr	yi
	clr	zi
	bra.L	same_key

nostp:
	cmp	#$77,d0
	bne.s	noinit
	clr	xi
	clr	yi
	clr	zi
	clr	xa
	clr	ya
	clr	za
	bra.s	same_key

noinit:
	cmp	#$a1,d0
	bne.s	nodr
	addi	#4,xcentr
nodr:
	cmp	#$a5,d0
	bne.s	noga
	subi	#4,xcentr
noga:
	cmp	#$83,d0
	bne.s	noha
	subi	#4,ycentr
noha:	
	cmp	#$c3,d0
	bne.s	noba
	addi	#4,ycentr
noba:
	cmp	prec_key,d0
	beq.s	same_key

	move	d0,prec_key
	

	lea	tbl_keys,a0
	lea	xi,a1
	moveq	#5,d7	
testc:
	cmp	(a0),d0	
	bne.s	nothis

	movem	(a1),d0-d2

	add	2(a0),d0
	add	4(a0),d1
	add	6(a0),d2
	movem	d0-d2,(a1)
	bra.s	same_key
nothis:	addq	#8,a0
	dbf	d7,testc
same_key:
	rts
prec_key:
	dc.w	0
tbl_keys:
	dc.w	$73,0,0,-1
	dc.w	$41,0,0,1
	dc.w	$61,0,-1,0
	dc.w	$63,0,1,0
	dc.w	$67,-1,0,0
	dc.w	$65,1,0,0


flag_face:	dc.w	0
clipping:
	clr	flag_face

	cmp	d0,d2
	ble.s	smin	
	exg	d0,d2
	exg	d1,d3
smin:
	tst	d2
	bge.s	noclip_x0

	clr	(a4)

	cmpi	#1,d0
	bge.s	clip_x0

	move	#1,flag_face
	rts
clip_x0:

	sub	d1,d3
	move	d3,d5	;y1-y2
	muls	d0,d5	;x1*(y1-y2)
	
	
	sub	d0,d2
	neg	d2
	move	d2,d3
	muls	d1,d2	;y1*(x2-x1)
	add.l	d2,d5	;x1*(y1-y2)+y1*(x2-x1)
	divs	d3,d5
	move	d5,d3
	moveq	#0,d2	

	addq	#1,nb_clipping_left
;	move	d3,(a5)+

noclip_x0:
	cmpi	#319,d2
	ble.s	need_x320

	move	#1,flag_face
	rts
need_x320:
	cmpi	#319,d0
	ble.s	noclip_x320

clip_x320:
	move	#320,2(a4)
	movem.l	d2-d3,-(a7)	
	
	sub	d0,d2	;x2-x1
	sub	d1,d3	;y2-y1
	move	d3,d5	
	neg	d5	;y1-y2

	move	d1,d6

	muls	#319,d3	;(y2-y1)*318
	muls	d0,d5	;x1*(y1-y2)
	muls	d2,d1

	add.l	d3,d1
	add.l	d5,d1

	divs	d2,d1
	
	andi.l	#$ffff,d1
	ext.l	d1
	move	#319,d0

	addq	#1,nb_clipping_right
	move	d1,(a3)+

	cmp	sup_rightb,d1
	bmi.s	nonewsup
	move	d1,sup_rightb
nonewsup:
	cmp	inf_rightb,d1
	bhi.s	nonewinf
	move	d1,inf_rightb
nonewinf:

	movem.l	(a7)+,d2-d3

noclip_x320:
	
	cmp	d1,d3
	bge.s	no_exgy	
	exg	d3,d1
	exg	d2,d0
no_exgy:
	tst	d1
	bge.s	noclip_y0		

	clr	4(a4)

	tst	d3
	bge.s	clip_y0

	move	#1,flag_face	
	rts		
clip_y0:
	movem.l	d2-d3,-(a7)

	sub	d1,d3	;y1-y2
	move	d0,d5
	sub	d2,d0	;x2-x1
	
	muls	d1,d0	;(x2-x1)y1
	muls	d3,d5
	add.l	d5,d0
	divs	d3,d0
	moveq	#0,d1

	movem.l	(a7)+,d2-d3
noclip_y0:
	cmp	#255,d1
	ble.s	ligny

	move	254,6(a4)
	move	#1,flag_face
	rts
ligny:
	cmp	#255,d3
	ble.s	noclip_y255
	move	#254,6(a4)

	movem.l	d0-d1,-(a7)

	sub	d1,d3	;y1-y2
	sub	d0,d2	
	move	d2,d5	;x1-x2
	neg	d2	;x2-x1
	
	muls	d1,d2	;y1*(x2-x1)
	muls	#255,d5	;255*(x1-x2)
	muls	d3,d0	;x1*(y1-y2)

	add.l	d0,d2
	add.l	d5,d2

	divs	d3,d2


	move	#255,d3

	movem.l	(a7)+,d0-d1

noclip_y255:
	rts




calc_dim:
	tst	nb_vizib
	bne.s	pas_rien

	move	#768*64+20,w_sizec2
	move	#0,w_adrc2
	move	#0,w_modc2
	rts
pas_rien:

	move	min_xc,d0
	move	max_xc,d1
	move	min_yc,d2
	move	max_yc,d3

	sub	d2,d3
	addq	#1,d3
	move	d3,d4
	add	d4,d4
	add	d4,d3
	lsl.l	#6,d3
	or	#20,d3

	mulu	#80,d2
	move.l	d2,w_adrc2

	move	#0,w_modc2
	move	d3,w_sizec2

	rts

swap_dim:
	move	w_sizec2,d0
	move.l	w_adrc2,d1
	move	w_modc2,d2

	move	w_sizec1,w_sizec2
	move.l	w_adrc1,w_adrc2
	move	w_modc1,w_modc2

	move	d0,w_sizec1
	move.l	d1,w_adrc1
	move	d2,w_modc1
	
	rts


ok_visibl:	dc.w	0
test_visibl:
	
	move	4(a1),d0
	lsl	#3,d0
	movem	-8(a0,d0.w),d1-d2

	move	8(a1),d0
	lsl	#3,d0
	movem	-8(a0,d0.w),d3-d4

	sub	d1,d3
	sub	d2,d4

	move	12(a1),d0
	lsl	#3,d0
	movem	-8(a0,d0.w),d5-d6

	sub	d1,d5
	sub	d2,d6

	muls	d3,d6
	muls	d4,d5
	sub.l	d6,d5
	smi	ok_visibl
	rts

tri_faces:
	lea	tbl_tri,a1
	lea	new_coords,a2
	move.l	pt_faces,a3	
	lea	adr_faces,a4

	moveq	#0,d7
calc_z:	
	
	move.l	a3,(a4)+
	move	d7,(a1)+

	lea	2(a3),a0

	
	move	(a0)+,d1	; d1 = nb de points

	move	(a0)+,d2
	subq	#1,d2
	lsl	#3,d2
	move	4(a2,d2.w),d2	;z max
	cmpi	#1,d1
	bne.s	no_unique

	moveq	#0,d4
	move	(a0),d4		;rayon -> d4
	lsl.l	#8,d4
	move	d2,d6
;	addi	#256,d6
	divs	d6,d4		;rayon apparent
	asr	#1,d4
	sub	d4,d2		;rayon+Zcentre -> Z max de la sphere
	bra.s	findz
no_unique:
	addq	#2,a0
	move	d1,d3
	subq	#2,d1
moy_z:
	move	(a0),d4
	addq	#4,a0
	subq	#1,d4	
	lsl	#3,d4
	move	4(a2,d4.w),d6
	add	d6,d2
	dbf	d1,moy_z

	move	2(a3),d1
	ext.l	d2
	divs	d1,d2

findz:
	move	d2,(a1)+

	move	2(a3),d1	;nb pts
	lsl	#2,d1
	addq	#4,d1
	add	d1,a3		;pointe sur adr face suivante

	addq	#1,d7
	cmp	nb_faces,d7
	bne	calc_z

	move	nb_faces,d0
	subq	#1,d0
	lea	tbl_tri,a0
tri0:
	move	d0,d1
	beq.s	fin_tri
	subq	#1,d1
	lea	4(a0),a1
tri1:
	move.l	(a0),d2
tri2:	move.l	(a1)+,d3
	cmp	d2,d3
	bhi.s	tri3
	dbf	d1,tri1
	addq	#4,a0
	dbf	d0,tri0
fin_tri:
	rts
tri3:	
	move.l	d2,-4(a1)
	move.l	d3,(a0)
	exg	d2,d3
	dbf	d1,tri1

	addq	#4,a0
	dbf	d0,tri0
	rts

col:	dc.w	0

trame:	blk.l	10,$55555555
	blk.l	10,$aaaaaaaa


init_screen_info:
	
	lea	nums+$300,a0
	lea	screen_info,a1
	moveq	#59,d0
isi:
	move.l	(a0)+,(a1)
	move.l	(a0)+,4(a1)
	add.l	#80,a1
	dbf	d0,isi
	rts

table_infos:
	dc.w	0,2
	dc.l	56,xi,96,yi,136,zi
	dc.w	$1e0,2
	dc.l	56,xa,96,ya,136,za
	dc.w	$3c0,1
	dc.l	40,distance	
	dc.w	$5a0,1
	dc.l	40,nb_faces	
	dc.w	$780,1
	dc.l	40,nbs	
	dc.w	$960,1
	dc.l	40,nb_vizib

display_info:
	lea	screen_info+7,a2
	move	xi,d5
	bsr	display_data
	lea	screen_info+12,a2
	move	yi,d5
	bsr	display_data
	lea	screen_info+17,a2
	move	zi,d5
	bsr	display_data

	lea	screen_info+487,a2
	move	xa,d5
	bsr	display_data
	lea	screen_info+492,a2
	move	ya,d5
	bsr	display_data
	lea	screen_info+497,a2
	move	za,d5
	bsr	display_data


	lea	screen_info+965,a2
	move	distance,d5
	bsr	display_data

	lea	screen_info+1445,a2
	move	nb_faces,d5
	bsr	display_data

	lea	screen_info+1924,a2
	move	nbs,d5
	bsr	display_data

	lea	screen_info+2404,a2
	move	nb_vizib,d5
	bsr	display_data

	lea	screen_info+2884,a2
	move	nb_clipping_left,d5
	bsr	display_data

	lea	screen_info+3364,a2
	move	#0,d5
	bsr	display_data
	lea	screen_info+3369,a2
	move	#0,d5
	bsr	display_data

	lea	screen_info+3844,a2
	move	nb_clipping_right,d5
	bsr	display_data

	lea	screen_info+4324,a2
	move	#0,d5
	bsr	display_data
	lea	screen_info+4329,a2
	move	#0,d5
	bsr	display_data
	rts

display_data:
	moveq	#3,d4
dd0:
	move	d5,d0
	lsr	#4,d5
	andi	#$f,d0
	mulu	#48,d0
	lea	nums,a5
	add	d0,a5

	move.b	(a5),3(a2)
	move.b	8(a5),83(a2)		
	move.b	16(a5),163(a2)		
	move.b	24(a5),243(a2)		
	move.b	32(a5),323(a2)		

	subq	#1,a2
	dbf	d4,dd0
	rts

phase_change_objet:dc.w	0
nb_objet:	dc.w	0
new_objet:	dc.w	0
liste_objet:	dc.l	objet0,planete,atari,cuboide,perpet
		dc.l	surf,toto,toto,toto,toto

change_objet:
	tst	phase_change_objet
	bne.s	install_new

	move	nb_objet,d0
	cmp	new_objet,d0
	beq.s	no_change_objet

	move	#-1,sens_fondu
	move	#1,phase_change_objet
	clr.l	colors
	clr.l	colors+4
no_change_objet:
	rts

install_new:
	tst	sens_fondu
	bne.s	endless_fondu

	clr	phase_change_objet
	move	new_objet,nb_objet
	bsr	select_objet
	bsr	init_obj
endless_fondu:
	rts
select_objet:
	move	nb_objet(pc),d0
	lea	liste_objet(pc),a0
	lsl	#2,d0
	move.l	0(a0,d0.w),adr_objet
	rts	

objet0:
	dc.l	immobile
	dc.w	12+2+4
	dc.w	14+8
	dc.w	$90
	dc.w	-2,6,3
	dc.w	$108,$141,$108
	dc.w	$0,$f,$aa,$fff

	dc.w	0,0,0

	dc.w	-80,80,80,-80
	dc.w	-80,80,80,-80
	dc.w	0,0,-130,130,0,0
	dc.w	-140,-140,140,140
	dc.w	-140,-140,140,140
	
	dc.w	-80,-80,80,80
	dc.w	-80,-80,80,80
	dc.w	-130,130,0,0,0,0
	dc.w	-190,-190,-190,-190
	dc.w	190,190,190,190

	dc.w	80,80,80,80	
	dc.w	-80,-80,-80,-80
	dc.w	0,0,0,0,130,-130
	dc.w	140,-140,-140,140
	dc.w	140,-140,-140,140

	dc.w	$11,4,1,2,2,3,3,4,4,1
	dc.w	$11,4,5,8,8,7,7,6,6,5
	dc.w	$12,4,2,6,6,7,7,3,3,2
	dc.w	$12,4,1,4,4,8,8,5,5,1
	dc.w	$10,4,1,5,5,6,6,2,2,1
	dc.w	$10,4,4,3,3,7,7,8,8,4
	dc.w	$13,1,9,50
	dc.w	$13,1,10,50
	dc.w	$33,1,11,50
	dc.w	$33,1,12,50
	dc.w	$23,1,13,50
	dc.w	$23,1,14,50
	dc.w	-$22,4, 15,16,16,17,17,18,18,15
	dc.w	-$22,4, 19,20,20,21,21,22,22,19
	dc.w	3,2, 15,19,19,15
	dc.w	3,2, 16,20,20,16
	dc.w	3,2, 17,21,21,17
	dc.w	3,2, 18,22,22,18
	rts
planete:
	dc.l	immobile

	dc.w 	49,49,110
	dc.w	$fffd,5,3
	dc.w	$69,$b0,$81
	dc.w	0,$ff0,$f20,$60
	dc.w	-30,20,300

	dc.w	0,0,-120,-150,-208,-260
	dc.w	-240,-300,-208,-260,-120,-150
	dc.w	0,0,120,150,208,260
	dc.w	240,300,208,260,120,150	
	dc.w	0,0,-120,-150,-208,-260
	dc.w	-240,-300,-208,-260,-120,-150
	dc.w	0,0,120,150,208,260
	dc.w	240,300,208,260,120,150	
	dc.w	0

	dc.w	240,300,208,260,120,150
	dc.w	0,0,-120,-150,-208,-260
	dc.w	-240,-300,-208,-260,-120,-150
	dc.w	0,0,120,150,208,260
	dc.w	240,300,208,260,120,150
	dc.w	0,0,-120,-150,-208,-260
	dc.w	-240,-300,-208,-260,-120,-150
	dc.w	0,0,120,150,208,260
	dc.w	0
	
	blk.w	24,20
	blk.w	24,-20
	dc.w	0

	dc.w	$11,4,1,2,2,4,4,3,3,1
	dc.w	$12,4,3,4,4,6,6,5,5,3
	dc.w	$11,4,5,6,6,8,8,7,7,5
	dc.w	$12,4,7,8,8,10,10,9,9,7
	dc.w	$11,4,9,10,10,12,12,11,11,9
	dc.w	$12,4,11,12,12,14,14,13,13,11
	dc.w	$11,4,13,14,14,16,16,15,15,13
	dc.w	$12,4,15,16,16,18,18,17,17,15
	dc.w	$11,4,17,18,18,20,20,19,19,17
	dc.w	$12,4,19,20,20,22,22,21,21,19
	dc.w	$11,4,21,22,22,24,24,23,23,21
	dc.w	$12,4,1,23,23,24,24,2,2,1


	dc.w	$32,4,3,27,27,25,25,1,1,3
	dc.w	$22,4,5,29,29,27,27,3,3,5
	dc.w	$32,4,7,31,31,29,29,5,5,7
	dc.w	$22,4,9,33,33,31,31,7,7,9
	dc.w	$32,4,11,35,35,33,33,9,9,11
	dc.w	$22,4,13,37,37,35,35,11,11,13
	dc.w	$32,4,15,39,39,37,37,13,13,15
	dc.w	$22,4,17,41,41,39,39,15,15,17
	dc.w	$32,4,19,43,43,41,41,17,17,19
	dc.w	$22,4,21,45,45,43,43,19,19,21
	dc.w	$32,4,23,47,47,45,45,21,21,23
	dc.w	$22,4,1,25,25,47,47,23,23,1

	dc.w	$11,4,25,27,27,28,28,26,26,25
	dc.w	$31,4,27,29,29,30,30,28,28,27
	dc.w	$11,4,29,31,31,32,32,30,30,29
	dc.w	$31,4,31,33,33,34,34,32,32,31
	dc.w	$11,4,33,35,35,36,36,34,34,33
	dc.w	$31,4,35,37,37,38,38,36,36,35
	dc.w	$11,4,37,39,39,40,40,38,38,37
	dc.w	$31,4,39,41,41,42,42,40,40,39
	dc.w	$11,4,41,43,43,44,44,42,42,41
	dc.w	$31,4,43,45,45,46,46,44,44,43
	dc.w	$11,4,45,47,47,48,48,46,46,45
	dc.w	$31,4,25,26,26,48,48,47,47,25

	dc.w	$10,4,4,2,2,26,26,28,28,4
	dc.w	$20,4,6,4,4,28,28,30,30,6
	dc.w	$10,4,8,6,6,30,30,32,32,8
	dc.w	$20,4,10,8,8,32,32,34,34,10
	dc.w	$10,4,12,10,10,34,34,36,36,12
	dc.w	$20,4,14,12,12,36,36,38,38,14
	dc.w	$10,4,16,14,14,38,38,40,40,16
	dc.w	$20,4,18,16,16,40,40,42,42,18
	dc.w	$10,4,20,18,18,42,42,44,44,20
	dc.w	$20,4,22,20,20,44,44,46,46,22
	dc.w	$10,4,24,22,22,46,46,48,48,24
	dc.w	$20,4,2,24,24,48,48,26,26,2

	dc.w	$33,1,49,160
	rts
atari:
	dc.l	immobile
	dc.w 	12+6+2,24+8+2,100
	dc.w	3,3,-4,$a4,$118,$6a
	dc.w	0,$a,$aaa,$fff
	dc.w	0,0,0

	dc.w	0,0,-120,-120,-208,-208
	dc.w	-240,-240,-208,-208,-120,-120
	dc.w	0,0,120,120,208,208
	dc.w	240,240,208,208,120,120	
	dc.w	-120,120,120,-120
	dc.w	-120,120,120,-120
	dc.w	0,0

	dc.w	240,240,208,208,120,120
	dc.w	0,0,-120,-120,-208,-208
	dc.w	-240,-240,-208,-208,-120,-120
	dc.w	0,0,120,120,208,208

	dc.w	120,120,-120,-120
	dc.w	120,120,-120,-120
	dc.w	0,0

	dc.w	60,-60,60,-60,60,-60
	dc.w	60,-60,60,-60,60,-60
	dc.w	60,-60,60,-60,60,-60
	dc.w	60,-60,60,-60,60,-60
	dc.w	-120,-120,-120,-120
	dc.w	120,120,120,120
	dc.w	-200,200

	dc.w	$23,4,25,26,26,27,27,28,28,25
	dc.w	$23,4,30,29,29,32,32,31,31,30
	dc.w	$31,4,26,30,30,31,31,27,27,26
	dc.w	$31,4,25,28,28,32,32,29,29,25
	dc.w	$33,4,29,30,30,26,26,25,25,29
	dc.w	$33,4,28,27,27,31,31,32,32,28
	dc.w	-$22,1,33,72
	dc.w	-$22,1,34,72
	dc.w	-$11,4,1,2,2,4,4,3,3,1
	dc.w	-$110,4,3,4,4,6,6,5,5,3
	dc.w	-$11,4,5,6,6,8,8,7,7,5
	dc.w	-$110,4,7,8,8,10,10,9,9,7
	dc.w	-$11,4,9,10,10,12,12,11,11,9
	dc.w	-$110,4,11,12,12,14,14,13,13,11
	dc.w	-$11,4,13,14,14,16,16,15,15,13
	dc.w	-$110,4,15,16,16,18,18,17,17,15
	dc.w	-$11,4,17,18,18,20,20,19,19,17
	dc.w	-$110,4,19,20,20,22,22,21,21,19
	dc.w	-$11,4,21,22,22,24,24,23,23,21
	dc.w	-$110,4,1,23,23,24,24,2,2,1
	rts
cuboide:
	dc.l	immobile
	dc.w 	7+8,25,100
	dc.w	4,-3,5
	dc.w	0,0,0

	dc.w	0,$a00,$ffd,$ff8
	dc.w	-40,20,140

	dc.w	-120,120,120,-120
	dc.w	-120,120,120,-120
	dc.w	-180,-180,-180,-180
	dc.w	180,180,180,180
	dc.w	120,120,-120,-120
	dc.w	120,120,-120,-120
	dc.w	0

	dc.w	120,120,-120,-120
	dc.w	120,120,-120,-120
	dc.w	120,120,-120,-120
	dc.w	120,120,-120,-120
	dc.w	180,180,180,180
	dc.w	-180,-180,-180,-180
	dc.w	0

	dc.w	-180,-180,-180,-180
	dc.w	180,180,180,180	
	dc.w	-120,120,120,-120
	dc.w	-120,120,120,-120
	dc.w	-120,120,120,-120
	dc.w	-120,120,120,-120
	dc.w	0

	dc.w	-$110,4,1,2,2,3,3,4,4,1
	dc.w	-$110,4,6,5,5,8,8,7,7,6

	dc.w	-$111,4,9,10,10,11,11,12,12,9
	dc.w	-$111,4,13,16,16,15,15,14,14,13

	dc.w	-$111,4,17,18,18,19,19,20,20,17
	dc.w	-$111,4,21,24,24,23,23,22,22,21

	dc.w	$22,1,25,100

	dc.w	-$20,3,1,9,9,20,20,1
	dc.w	-$20,3,2,13,13,17,17,2	
	dc.w	-$20,3,3,21,21,16,16,3
	dc.w	-$20,3,4,24,24,12,12,4

	dc.w	-$20,3,5,19,19,10,10,5
	dc.w	-$20,3,6,14,14,18,18,6
	dc.w	-$20,3,7,15,15,22,22,7
	dc.w	-$20,3,8,23,23,11,11,8
	rts
perpet:
	dc.l	perpet_anim
	dc.w 	22,34,0
	dc.w	0,3,0,0,90,0
	dc.w	0,$f22,$4f,$ffa
	dc.w	0,0,0

	dc.w	-150,-90,-30,30,90,150
	blk.w	8,-220
	blk.w	8,220
	dc.w	-150,-150,-90,-90,-30,-30
	dc.w	30,30,90,90,150,150

	dc.w	20,20,20,20,20,20
	dc.w	80,-80,-80,60,60,-80,-80,80
	dc.w	80,-80,-80,60,60,-80,-80,80
	dc.w	-80,-80,-80,-80,-80,-80
	dc.w	-80,-80,-80,-80,-80,-80

	dc.w	0,0,0,0,0,0
	dc.w	-60,-60,-40,-40,40,40,60,60
	dc.w	-60,-60,-40,-40,40,40,60,60
	dc.w	-40,40,-40,40,-40,40
	dc.w	-40,40,-40,40,-40,40

	dc.w	$11,1,1,30
	dc.w	$10,1,2,30
	dc.w	$12,1,3,30
	dc.w	$13,1,4,30
	dc.w	$33,1,5,30
	dc.w	$32,1,6,30
	dc.w	-$22,8,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,7
	dc.w	-$22,8,16,15,15,22,22,21,21,20,20,19,19,18,18,17,17,16	
	dc.w	-$20,4,8,16,16,17,17,9,9,8
	dc.w	-$20,4,12,20,20,21,21,13,13,12
	dc.w	$33,2,1,23,23,1,$33,2,1,24,24,1
	dc.w	$33,2,2,25,25,1,$33,2,2,26,26,1
	dc.w	$33,2,3,27,27,1,$33,2,3,28,28,1
	dc.w	$33,2,4,29,29,1,$33,2,4,30,30,1
	dc.w	$33,2,5,31,31,1,$33,2,5,32,32,1
	dc.w	$33,2,6,33,33,1,$33,2,6,34,34,1

surf:
	dc.l	anim_surf
	dc.w 	50,50,0
	dc.w	-3,6,3,0,$11c,$16
	dc.w	0,$fff,$4fb,$4f
	dc.w	0,0,0

	dc.w	-180,-180,-180,-180,-180
	dc.w	-140,-140,-140,-140,-140
	dc.w	-100,-100,-100,-100,-100
	dc.w	-60,-60,-60,-60,-60
	dc.w	-20,-20,-20,-20,-20
	dc.w	20,20,20,20,20
	dc.w	60,60,60,60,60
	dc.w	100,100,100,100,100
	dc.w	140,140,140,140,140
	dc.w	180,180,180,180,180

	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80
	dc.w	-80,-40,0,40,80

	blk.w	50,0

	dc.w	$11,1,1,20
	dc.w	$11,1,2,20
	dc.w	$11,1,3,20
	dc.w	$11,1,4,20
	dc.w	$11,1,5,20
	dc.w	$12,1,6,20
	dc.w	$12,1,7,20
	dc.w	$12,1,8,20
	dc.w	$12,1,9,20
	dc.w	$12,1,10,20
	dc.w	$22,1,11,20
	dc.w	$22,1,12,20
	dc.w	$22,1,13,20
	dc.w	$22,1,14,20
	dc.w	$22,1,15,20
	dc.w	$13,1,16,20
	dc.w	$13,1,17,20
	dc.w	$13,1,18,20
	dc.w	$13,1,19,20
	dc.w	$13,1,20,20
	dc.w	$33,1,21,20
	dc.w	$33,1,22,20
	dc.w	$33,1,23,20
	dc.w	$33,1,24,20
	dc.w	$33,1,25,20
	dc.w	$23,1,26,20
	dc.w	$23,1,27,20
	dc.w	$23,1,28,20
	dc.w	$23,1,29,20
	dc.w	$23,1,30,20
	dc.w	$13,1,31,20
	dc.w	$13,1,32,20
	dc.w	$13,1,33,20
	dc.w	$13,1,34,20
	dc.w	$13,1,35,20
	dc.w	$22,1,36,20
	dc.w	$22,1,37,20
	dc.w	$22,1,38,20
	dc.w	$22,1,39,20
	dc.w	$22,1,40,20
	dc.w	$12,1,41,20
	dc.w	$12,1,42,20
	dc.w	$12,1,43,20
	dc.w	$12,1,44,20
	dc.w	$12,1,45,20
	dc.w	$11,1,46,20
	dc.w	$11,1,47,20
	dc.w	$11,1,48,20
	dc.w	$11,1,49,20
	dc.w	$11,1,50,20

toto:
	dc.l	anim_toto
	dc.w	21,21,$6c
	dc.w	4,-3,2,0,0,0
	dc.w	0,$f,$a,$8cf
	dc.w	0,0,0


	dc.w	-200,200,200,-200
	dc.w	-140,140,140,-140
	dc.w	-200,200,200,-200
	dc.w	-140,140,140,-140
	blk.w	5,0

	dc.w	-200,-200,200,200,-140,-140,140,140
	dc.w	-200,-200,200,200,-140,-140,140,140
	blk.w	5,0

	blk.w	8,30
	blk.w	8,-30
	dc.w	-160,-80,0,80,160

	dc.w	$11,4,1,2,2,6,6,5,5,1
	dc.w	$11,4,9,13,13,14,14,10,10,9
	dc.w	$20,4,5,6,6,14,14,13,13,5
	dc.w	$13,4,1,9,9,10,10,2,2,1	
	dc.w	$12,4,2,3,3,7,7,6,6,2
	dc.w	$12,4,10,14,14,15,15,11,11,10
	dc.w	$20,4,6,7,7,15,15,14,14,6
	dc.w	$13,4,2,10,10,11,11,3,3,2
	dc.w	$11,4,8,7,7,3,3,4,4,8
	dc.w	$11,4,16,12,12,11,11,15,15,16
	dc.w	$20,4,7,8,8,16,16,15,15,7
	dc.w	$13,4,4,3,3,11,11,12,12,4
	dc.w	$12,4,1,5,5,8,8,4,4,1
	dc.w	$12,4,13,9,9,12,12,16,16,13
	dc.w	$20,4,5,13,13,16,16,8,8,5
	dc.w	$13,4,1,4,4,12,12,9,9,1

	dc.w	$33,1,17,35
	dc.w	$33,1,18,35
	dc.w	$33,1,19,35
	dc.w	$33,1,20,35
	dc.w	$33,1,21,35


anim_toto:
	lea	tblsin,a1
	lea	tblcos,a3
	lea	coords_pt+$80,a2
	lea	pt_anim,a0

	add	#40,(a0)
	cmpi	#720,(a0)
	blt.s	no_over5
	subi	#720,(a0)
no_over5:
	move	(a0),d4
	moveq	#4,d7
all5:
	move	d4,d0

	addi	#40,d4
	cmpi	#720,d4
	blt.s	nototo
	subi	#720,d4
nototo:

	move	0(a3,d0.w),d1
	move	0(a1,d0.w),d0
	muls	#40,d0
	muls	#40,d1
	lsl.l	#2,d0	
	lsl.l	#2,d1
	swap	d0
	swap	d1

	move	d1,(a2)
	move	d0,2(a2)
	addq	#8,a2
	dbf	d7,all5
	rts



tbl_mvt:
	dc.w	1,1,2,2,3,3,4,4
	dc.w	5,5,5,10,5,15,5,20,5,25,5,30,4,35,3,40,2,45,1,50
anim_surf:
	lea	tblsin,a1
	lea	coords_pt,a2
	lea	tbl_mvt(pc),a3

	add	#40,pt_anim
	cmpi	#720,pt_anim
	ble.s	no_over2
	subi	#720,pt_anim
no_over2:
	move	pt_anim(pc),d3
	moveq	#13,d7
ai:
	move	d3,d0
	add	#50,d3
	cmpi	#720,d3
	bmi.s	no_over3
	subi	#720,d3
no_over3:
	move	0(a1,d0.w),d0
	muls	#50,d0
	lsl.l	#2,d0	
	swap	d0

	move	(a3)+,d6
	subq	#1,d6
	move	(a3)+,d4
diago:
	move	d4,d5
	addq	#4,d4	

	lsl	#3,d5
	move	d0,-4(a2,d5.w)

	dbf	d6,diago
	dbf	d7,ai
	rts



perpet_anim:
	add	#30,pt_anim
	cmpi	#720,pt_anim
	ble.s	no_over		
	subi	#720,pt_anim
no_over:
	move	pt_anim(pc),d2
	move.l	dat_x,a0
	lea	coords_pt,a1	
	lea	tblsin,a2
	move	0(a2,d2.w),d0

	muls	#40,d0
	lsl.l	#2,d0
	swap	d0
;	ext.l	d0

	cmpi	#360,d2
	bhi.s	ball1
	add	#10,a0
	add	#40,a1
ball1:
	move	(a0),d1
	add	d0,d1
	move	d1,(a1)
	rts

immobile:
	rts

pt_anim:	dc.w	0
animation_routine:dc.l	0

animation_interne:
	move.l	animation_routine(pc),a0
	jmp	(a0)	


sens_fondu:	dc.w	0
tempo_fondu:dc.w	0
set_colors:
	tst	sens_fondu
	beq.s	no_change_colors

	not	tempo_fondu
	beq.s	no_change_colors

	lea	copper_list(pc),a0
	lea	colors,a1
	suba.l	a6,a6

	move	sens_fondu(pc),d2
	andi	#$f,d2
	moveq	#3,d6

set_all_colors:
	
	move	(a1)+,d0
	move	2(a0),d1
	cmp	d0,d1
	beq.s	no_change

	bsr	fondu
	move.w	#$1,a6

no_change:
	move	d1,2(a0)
	addq	#$4,a0

	dbf	d6,set_all_colors
	cmp.l	#0,a6
	bne.s	pas_fini
	clr	sens_fondu

pas_fini:

no_change_colors:
	rts

fondu:
	moveq	#2,d7
	moveq	#0,d5
all_composantes:
	move	d0,d3
	move	d1,d4
	lsr	#4,d0
	lsr	#4,d1
	andi	#$f,d3
	andi	#$f,d4

	cmp	d3,d4
	beq.s	ok_blue
	add	d2,d4
	andi	#$f,d4
ok_blue:
	or	d4,d5
	ror	#4,d5
	dbf	d7,all_composantes
	ror	#4,d5
	move	d5,d1
	rts



save_level3:dc.l	0

min_xc:	dc.w	0
max_xc:	dc.w	0
min_yc:	dc.w	0
max_yc:	dc.w	0

min_x:	dc.w	0
max_x:	dc.w	0
min_y:	dc.w	0
max_y:	dc.w	0

face_transparente:dc.w	0
inv:		dc.w	0
nb_vizib:	dc.w	0
active_face:	dc.w	0
flag_active:	dc.w	0
flag_active_color:dc.w	0

color_face:	dc.w	0
trame_or:	dc.w	0
trame_and:	dc.w	0
pt_trame:	dc.w	0

new_coords:	blk.b	1000
adr_faces:	blk.l	100
coords_pt:	blk.b	1000

nb_clipping_left:	dc.w	0
tbl_clipping_left:	blk.w	40
nb_clipping_right:	dc.w	0
tbl_clipping_right:	blk.w	40

tbl_min:	blk.w	200
tbl_tri:	blk.l	200
