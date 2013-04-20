;
; crack intro (c) ART&SCIENCE / Frederic Gidouin
;

music=$4122c

copper_list=$50000
screen=$58000
char=$60000

boot=$61000
tblsin=$7f000
tblcos=$7f800
screen0=$62000
screen1=$72000
>EXTERN"tblsin",tblsin
>EXTERN"tblcos",tblcos
>EXTERN"char8",char
>EXTERN"rsi.bin",music
;>EXTERN"power_boot",boot
;---------------------
start:

	move.b	#$87,$bfd100
	move.l	$4,a6
	jsr	-$84(a6)

	bsr	aff
	bsr	init_copper
	moveq	#0,d0
	moveq	#0,d1
	jsr	$4124e
	clr	pcol

	lea	s_dma(pc),a5
	lea	$dff000,a6
	move	$2(a6),(a5)
	or	#$c000,(a5)+
	
	move	$1c(a6),(a5)
	or	#$c000,(a5)

	move	#$3fff,$96(a6)
	move	#$7fff,$9a(a6)
	move	#$83c0,$96(a6)
	move	#$e008,$9a(a6);clavier seul

	move.l	#$2c812ae1,$8e(a6)
	move.w	#$3000,$100(a6)
	clr.l	$108(a6)
	clr.l	$104(a6)
	move	#$1,$102(a6)
	move.l	#$3800d0,$92(a6)

	bsr	set_screen
	move.l	#copper_list,$80(a6)
	clr	$88(a6)	
	clr	$180(a6)
	move	#$77a,$182(a6)
	move	#$fff,$184(a6)
	move	#$bbe,$186(a6)

	clr	$188(a6)

	move	#$77a,$18a(a6)
	move	#$fff,$18c(a6)
	move	#$bbe,$18e(a6)

	bsr	clear_screen
	bsr	wait_blitter
	bsr	swap_screens
	bsr	clear_screen

	bsr	init_scroll
wait:
	cmpi.b	#$ff,$dff006
	bne.s	wait

	bsr	swap_screens
	bsr	set_screen
	bsr	wait_blitter
	bsr	clear_screen

	bsr	fondu	
	jsr	$413e4
	bsr	chg_col
	bsr	anim
	bsr	scroll

	bsr	rotations
	bsr	wait_blitter

	bsr	display_scroll
	bsr	wait_blitter

	btst	#10,$dff016
	beq	right	


	btst	#$6,$bfe001
	bne	wait
	bra	no_right
right:
	move.w	#$6020,boot+$4e

no_right:

	lea	name_glib(pc),a1
	lea	$dff000,a4
	lea	s_dma(pc),a5
	move.l	$4.w,a6

	move	#$7fff,$96(a4)
	move	#$7fff,$9a(a4)
	move	(a5)+,$96(a4)
	move	(a5),$9a(a4)
	move.w	#$f,$96(a4)

	moveq	#0,d0
	jsr	-$228(a6)
	move.l	d0,a0
	move.l	$26(a0),$80(a4)
	move	d0,$88(a4)
	jmp	-$8a(a6)

s_dma:	dc.w	0
s_intena:dc.w	0
name_glib:	dc.b	'graphics.library',0
	even

init_copper:
	lea	copper_list,a0

	move.l	#$ea8000,(a0)+
	move.l	#$e80005,(a0)+
	move.l	#$e20000,(a0)+
	move.l	#$e00000,(a0)+
	move.l	#$e60000,(a0)+
	move.l	#$e40000,(a0)+

	move.l	#$4037fffe,(a0)+
	move.l	a0,barrecol

	moveq	#$2a,d1
ic0:	move.l	#$01800000,(a0)+
	dbf	d1,ic0

	move.l	#$4107fffe,(a0)+
	move.l	#$00968100,(a0)+
	move.l	#$01800000,(a0)+

	move.l	#$ffdffffe,(a0)+
	move.l	#$100ffffe,(a0)+
	move.l	#$00960100,(a0)+

	move.l	#$110ffffe,(a0)+

	move.l	a0,barrecol+4

	moveq	#$2a,d1
ic1:	move.l	#$01800000,(a0)+
	dbf	d1,ic1

	move.l	#$120ffffe,(a0)+
	move.l	#$01800224,(a0)+

	move.l	#$fffffffe,(a0)
	rts

barrecol:	dc.l	0,0
colors:
	dc.w	$fff,$fee,$fdd,$fcc,$fbb,$faa,$f99,$f88,$f77,$f66
	dc.w	$f55,$f44,$f33,$f22,$f11,$f10,$f20,$f30,$f40,$f50
	dc.w	$f60,$f70,$f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0
	dc.w	$ef0,$df0,$cf0,$bf0,$af0,$9f0,$8f0,$7f0,$6f0,$5f0
	dc.w	$4f0,$3f0,$2f0,$1f0,$0f0,$f1,$f2,$f3,$f4,$f5,$f6
	dc.w	$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$1ff,$2ff,$3ff,$4ff
	dc.w	$5ff,$6ff,$7ff,$8ff,$9ff,$aff,$bff,$cff,$dff,$eff,$fff
	
e_colors:
	dc.w	$fff,$fee,$fdd,$fcc,$fbb,$faa,$f99,$f88,$f77,$f66
	dc.w	$f55,$f44,$f33,$f22,$f11,$f10,$f20,$f30,$f40,$f50
	dc.w	$f60,$f70,$f80,$f90,$fa0,$fb0,$fc0,$fd0,$fe0,$ff0
	dc.w	$ef0,$df0,$cf0,$bf0,$af0,$9f0,$8f0,$7f0,$6f0,$5f0
	dc.w	$4f0,$3f0,$2f0,$1f0,$0f0,$f1,$f2,$f3,$f4,$f5,$f6
	dc.w	$f7,$f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff,$1ff,$2ff,$3ff,$4ff
	dc.w	$5ff,$6ff,$7ff,$8ff,$9ff,$aff,$bff,$cff,$dff,$eff,$fff
	
ptcol:	dc.l	colors
wcol:	dc.w	0

chg_col:
	addq	#1,wcol
	cmpi	#2,wcol
	bne	echgc
	clr	wcol

	move.l	ptcol,a0
	cmpa.l	#e_colors,a0
	bne.s	chgc0
	lea	colors-2,a0
chgc0:
	lea	2(a0),a0
	move.l	a0,ptcol
	
	move.l	barrecol,a1
	move.l	barrecol+4,a2
	lea	$a4(a2),a2

	moveq	#$14,d0
chgc1:
	move.w	(a0),2(a1)
	move.w	(a0),6(a1)

	move	(a0)+,6(a2)
	move	(a0)+,2(a2)

	addq	#8,a1
	subq	#8,a2
	dbf	d0,chgc1
	move	(a0)+,2(a1)
echgc:
	rts

used_screen:	dc.l	screen0
other_screen:	dc.l	screen1

swap_screens:
	lea	used_screen(pc),a0	
	move.l	(a0),d0
	move.l	4(a0),(a0)
	move.l	d0,4(a0)
	rts
;--------------------------------

set_screen:
	move.l	used_screen(pc),d0
	lea	copper_list+8,a0
	add.l	#400,d0
	move	d0,2(a0)
	swap	d0
	move	d0,6(a0)
	swap	d0
	add.l	#40,d0
	move	d0,10(a0)
	swap	d0
	move	d0,14(a0)
	rts
;---------------------------------
clear_screen:	

	lea	$dff000,a5
	move.l	#-1,$44(a5)
	clr	$66(a5)
	clr	$74(a5)
	move.l	#$01f00000,$40(a5)
	move.l	other_screen(pc),a0
	lea	400(a0),a0
	move.l	a0,$54(a5)
	move	#230*64+20,$58(a5)	
	rts

;---------------------------------
wait_blitter:
	move	#$8400,$dff096
wb:	btst	#14,$dff002
	bne.s	wb
	move	#$400,$dff096
	rts

;------------------------------
rotations:
	move.l	a7,save_sp


	lea	coords_pt,a0
	lea	new_coords,a1
	lea	tblsin,a2
	lea	tblcos,a3


	move	ya(pc),d0
	add	d0,d0
	move	0(a2,d0.w),a4
	move	0(a3,d0.w),a5

	move	xa(pc),d0
	add	d0,d0
	move	0(a2,d0.w),a6
	move	0(a3,d0.w),a7

	move	za(pc),d0
	add	d0,d0
	move	0(a2,d0.w),a2
	move	0(a3,d0.w),a3

	move	nbs,d7
	beq	no_rot
	subq	#1,d7
rot0:
	move	(a0)+,d0
	move	(a0)+,d1

	move	a2,d4
	move	a3,d5
	move	d0,d3
	move	d1,d6
	muls	d5,d0
	muls	d4,d6
	sub.l	d6,d0
	lsl.l	#2,d0
	swap	d0
	muls	d4,d3
	muls	d5,d1
	add.l	d3,d1
	lsl.l	#2,d1
	swap	d1
	
	move	a4,d2
	move	a5,d5
	move	d0,d3
	muls	d5,d0
	lsl.l	#2,d0
	swap	d0
	muls	d3,d2
	lsl.l	#2,d2
	swap	d2

	move	a6,d4
	move	a7,d5
	move	d1,d3
	move	d2,d6
	muls	d5,d1
	muls	d4,d6
	sub.l	d6,d1
	lsl.l	#2,d1
	swap	d1
	muls	d3,d4
	muls	d5,d2
	add.l	d4,d2
	lsl.l	#2,d2
	swap	d2

	addi	#$256,d2
	ext.l	d0
	ext.l	d1
	lsl.l	#8,d0
	lsl.l	#8,d1
	divs	d2,d0
	divs	d2,d1
	addi	#160,d0
	addi	#128,d1

	move	d0,(a1)+
	move	d1,(a1)+

	dbf	d7,rot0
no_rot:
	move.l	save_sp(pc),a7
	rts

save_sp:dc.l	0

anim:
	lea	xi(pc),a0
	lea	xa(pc),a1
	moveq	#2,d0
	move	#$168,d2
an0:
	move	(a1),d1
	add	(a0)+,d1
	tst	d1
	bge.s	an1
	add	d2,d1
an1:	cmp	d2,d1
	bmi.s	an2
	sub	d2,d1
an2:
	move	d1,(a1)+
	dbf	d0,an0
	rts

xi:	dc.w	0
yi:	dc.w	0
zi:	dc.w	0
xa:	dc.w	0
ya:	dc.w	0
za:	dc.w	0

;---------------------------

la:
	dc.w	10
	dc.w	-40,0,40,20,13,-13,-20,-8,0,8
	dc.w	60,-60,60,60,40,40,60,20,-10,20
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,1,8,9,9,10,10,8
lb:	
	dc.w	10
	dc.w	-40,-40,-20,-20,40,40,-20,-20,20,20
	dc.w	60,-60,-60,-20,10,60,40,0,20,40
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,1,7,8,8,9,9,10,10,7
lc:
	dc.w	8
	dc.w	-40,-40,40,40,-20,-20,40,40
	dc.w	60,-60,-60,-40,-40,40,40,60
	dc.w	8,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,1
ld:
	dc.w	8
	dc.w	-40,-40,40,40,-20,-20,20,20
	dc.w	60,-60,0,60,40,-20,10,40
	dc.w	8,1,2,2,3,3,4,4,1,5,6,6,7,7,8,8,5
le:
	dc.w	10
	dc.w	-40,-40,40,-20,-20,20,20,-20,-20,40
	dc.w	60,-60,-60,-40,-10,-10,10,10,40,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lf:
	dc.w	10
	dc.w	-40,-40,40,40,-20,-20,20,20,-20,-20
	dc.w	60,-60,-60,-40,-40,-10,-10,10,10,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lg:
	dc.w	10
	dc.w	-40,-40,40,40,-20,-20,20,20,40,40
	dc.w	60,-60,-60,-40,-40,40,40,0,0,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lh:
	dc.w	10
	dc.w	-40,-40,-20,-20,40,40,20,20,-20,-20
	dc.w	60,-60,-60,0,0,60,60,20,20,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
li:
	dc.w	8
	dc.w	-40,-10,-10,-40,40,10,10,40
	dc.w	60,40,-40,-60,-60,-40,40,60
	dc.w	8,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,1
lj:
	dc.w	10
	dc.w	-40,-40,0,0,-40,-40,40,40,20,20
	dc.w	60,40,40,-40,-40,-60,-60,-40,-40,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lk:
	dc.w	10
	dc.w	-40,-40,-20,-20,40,-20,40,20,-20,-20
	dc.w	60,-60,-60,-20,-60,0,60,60,20,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
ll:
	dc.w	6
	dc.w	-40,-40,-20,-20,40,40
	dc.w	60,-60,-60,40,40,60
	dc.w	6,1,2,2,3,3,4,4,5,5,6,6,1
lm:
	dc.w	10
	dc.w	-40,-40,0,40,40,20,20,0,-20,-20
	dc.w	60,-60,-20,-60,60,60,-10,10,-10,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
ln:
	dc.w	10
	dc.w	-40,-40,-20,20,20,40,40,20,-20,-20
	dc.w	60,-60,-60,20,-60,-60,60,60,-20,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lo:
	dc.w	8
	dc.w	-40,-40,40,40,-20,-20,20,20
	dc.w	60,-60,-60,60,40,-40,-40,40
	dc.w	8,1,2,2,3,3,4,4,1,5,6,6,7,7,8,8,5
lp:
	dc.w	10
	dc.w	-40,-40,40,40,-20,-20,-20,-20,20,20
	dc.w	60,-60,-60,20,20,60,0,-40,-40,0
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,1,7,8,8,9,9,10,10,7
lq:
	dc.w	10
	dc.w	20,20,-40,-40,40,40,-20,-20,20,20
	dc.w	60,20,20,-60,-60,60,0,-40,-40,0
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,1,7,8,8,9,9,10,10,7
lr:
	dc.w	10
	dc.w	-40,-40,40,20,40,-20,-20,-20,10,0
	dc.w	60,-60,-60,0,60,20,-20,-40,-40,-20
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,1,7,8,8,9,9,10,10,7
ls:
	dc.w	10
	dc.w	-40,-40,20,-40,-40,40,40,-20,40,40
	dc.w	60,40,40,-40,-60,-60,-40,-40,40,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lt:
	dc.w	8
	dc.w	-10,-10,-40,-40,40,40,10,10
	dc.w	60,-40,-40,-60,-60,-40,-40,60
	dc.w	8,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,1
lu:
	dc.w	8
	dc.w	-40,-40,-20,-20,20,20,40,40
	dc.w	60,-60,-60,40,40,-60,-60,60
	dc.w	8,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,1
lv:
	dc.w	8
	dc.w	-10,-40,-20,-5,5,20,40,10
	dc.w	60,-60,-60,10,10,-60,-60,60
	dc.w	8,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,1
lw:
	dc.w	10
	dc.w	-40,-40,0,40,40,20,20,0,-20,-20
	dc.w	-60,60,20,60,-60,-60,10,-10,10,-60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lx:
	dc.w	8
	dc.w	-40,-20,-40,0,40,20,40,0
	dc.w	60,0,-60,-20,-60,0,60,20
	dc.w	8,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,1
ly:
	dc.w	10
	dc.w	-10,-10,-40,-20,-5,5,20,40,10,10
	dc.w	60,20,-40,-60,-30,-30,-60,-40,20,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lz:
	dc.w	10
	dc.w	40,40,-20,40,40,-40,-40,20,-40,-40
	dc.w	60,40,40,-40,-60,-60,-40,-40,40,60
	dc.w	10,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,1
lpoint:
	dc.w	4
	dc.w	-15,-15,15,15
	dc.w	60,30,30,60
	dc.w	4,1,2,2,3,3,4,4,1
lpt_excl:
	dc.w	8
	dc.w	-15,-15,15,15,-15,-30,30,15
	dc.w	60,30,30,60,10,-60,-60,10
	dc.w	8,1,2,2,3,3,4,4,1,5,6,6,7,7,8,8,5
lpoint2:
	dc.w	8
	dc.w	-15,-15,15,15,-15,-15,15,15
	dc.w	40,10,10,40,-10,-40,-40,-10
	dc.w	8,1,2,2,3,3,4,4,1,5,6,6,7,7,8,8,5
lsp:
	dc.w	0

display_scroll:

	lea	new_coords,a0
	lea	faces,a1

	lea	min_x,a4
	move.l	#$02000000,(a4)
	move.l	#$02000000,4(a4)

	move	nbl,d7
	beq	no_disp
	subq	#1,d7

	move	#40,$dff066
	move	#40,$dff060
	move	#$8000,$dff074
	move	#$ffff,$dff072

	move.l	other_screen(pc),a2

trace_lignes:

	move	(a1)+,d5
	move	(a1)+,d6

	lsl	#2,d5
	lsl	#2,d6
	
	move	-4(a0,d5.w),d0
	move	-2(a0,d5.w),d1
	move	-4(a0,d6.w),d2
	move	-2(a0,d6.w),d3

;*********************************************** CALCUL EXTREM. BOITE ***

	cmp	(a4),d0
	bge.s	nxmin1	
	move	d0,(a4)
nxmin1:	cmp	2(a4),d0
	ble.s	nxmax1	
	move	d0,2(a4)
nxmax1:	
	cmp	(a4),d2
	bge.s	nxmin2	
	move	d2,(a4)
nxmin2:	cmp	2(a4),d2
	ble.s	nxmax2	
	move	d2,2(a4)
nxmax2:	
	cmp	4(a4),d1
	bge.s	nymin1	
	move	d1,4(a4)
nymin1:	cmp	6(a4),d1
	ble.s	nymax1	
	move	d1,6(a4)
nymax1:	
	cmp	4(a4),d3
	bge.s	nymin2	
	move	d3,4(a4)
nymin2:	cmp	6(a4),d3
	ble.s	nymax2	
	move	d3,6(a4)
nymax2:	


;********************************* TRACE LIGNE D0/D1 - D2/D3 ***********
	cmp	d1,d3
	bne.s	noteg
	cmp	d0,d2
noteg:	bge.s	noexg
	exg	d0,d2
	exg	d1,d3
noexg:
	sub	d0,d2
	sub	d1,d3

	lsl.l	#3,d1
	move	d1,d5
	lsl	#2,d5
	add	d5,d1

	moveq	#$f,d5
	move	d0,d4
	lsr	#3,d4
	bclr	#0,d4
	add	d4,d1
	and.l	d5,d0
	move	d0,d4
	ror.l	#4,d0
	not.b	d4
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

	ori.l	#$0b4a0003,d0
	eor	d5,$00(a2,d1.w)
	add.l	a2,d1

	move	#$8400,$dff096
ee:	btst	#14,$dff002
	bne	ee

	move	#$400,$dff096


	move.l	d0,$dff040
	move.l	d1,$dff048
	move.l	d1,$dff054	
	move.l	d6,$dff050
	move.l	d3,$dff062
	move	d2,$dff058

depas:

	dbf	d7,trace_lignes

	lea	w_size(pc),a5
	bsr	window_dim
	bsr	fill_plane
no_disp:
	rts

fill_plane:
	move.l	other_screen(pc),a2
	add.l	2(a5),a2

	move	#$8400,$dff096
wbl:	btst	#14,$dff002
	bne.s	wbl
	move	#$400,$dff096

	move.l	a2,$dff050
	move.l	a2,$dff054
	move	6(a5),$dff064
	move	6(a5),$dff066
	move.l	#$09f0001a,$dff040
	move	(a5),$dff058
	rts

w_size:	dc.w	$fc6
w_adr:	dc.l	$1a80
w_mod:	dc.w	$1c


;---------------------------------

window_dim:
	
	move	4(a4),d0
	move	6(a4),d1

	addq	#1,d1
	move	d1,d2
	sub	d0,d2
	addq	#1,d2
	mulu	#40,d1
	move	2(a4),d0
	addi	#$10,d0
	lsr	#3,d0
	andi.b	#$fe,d0
	ext.l	d0
	add.l	d0,d1
	subq	#2,d1
	
	move.l	d1,2(a5)
	move	(a4),d1
	lsr	#3,d1
	andi.b	#$fe,d1
	sub	d1,d0
	move	d0,d1
	lsr	#1,d1
	lsl.l	#6,d2
	add	d1,d2
	subi	#40,d0
	neg	d0
	move	d0,6(a5)
	move	d2,(a5)
	rts

scroll:
	move	pos_scroll,dep+2
	addi	#40,dep+2

	lea	faces,a4
	lea	coords_pt,a3
	lea	adr_text,a6
	clr	nbs
	clr	nbl
	moveq	#4,d7
iss:
	move.l	(a6)+,a0
	move	(a0)+,d0
	beq	no_pt
	move	nbs,d2
	move	d0,d1

	add	d1,nbs
	subq	#1,d0
	add	d1,d1
	lea	0(a0,d1.w),a1
	lea	0(a1,d1.w),a2
init_s0:
	move	(a0)+,d6
dep:	add	#-200,d6
	move	d6,(a3)+
	move	(a1)+,(a3)+
	dbf	d0,init_s0

	move.l	a4,a0
	move	(a2)+,d0
	add	d0,nbl
	subq	#1,d0
init_s1:
	move	(a2)+,d3
	move	(a2)+,d4
	add	d2,d3
	add	d2,d4
	move	d3,(a0)+
	move	d4,(a0)+
	dbf	d0,init_s1
	exg	a0,a4
no_pt:
	addi.w	#100,dep+2
	dbf	d7,iss

	move	speed,d7
	sub	d7,pos_scroll
	cmpi	#-300,pos_scroll
	bgt	no_new
	move	#-200,pos_scroll

	lea	adr_text,a6
	move.l	4(a6),(a6)
	move.l	8(a6),4(a6)
	move.l	12(a6),8(a6)
	move.l	16(a6),12(a6)

	move.l	pt_text,a0
again:
	lea	tbl_let,a1
	lea	adr_let,a2

	move.b	(a0)+,d0

	cmp.b	#-1,d0
	beq	mod_opt

	tst	d0
	bne	no_end_txt
	bra	no_mod_opt
mod_opt:
	moveq	#5,d1
	lea	xi,a3
all_opt:
	move.b	(a0)+,d0
	lsl	#8,d0
	or.b	(a0)+,d0
	move	d0,(a3)+
	dbf	d1,all_opt
	
	move.b	(a0)+,speed+1

	move.b	(a0)+,d0
	bne	no_end_txt
no_mod_opt:
	lea	text(pc),a0
	bra.s	again
no_end_txt:
	move.l	a0,pt_text
search:
	lea	4(a2),a2
	cmp.b	(a1)+,d0
	bne	search
	
	move.l	-4(a2),16(a6)

no_new:
	rts


adr_text:
	blk.l	8,0

text:
	dc.b	-1,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,10
	dc.b	"ART AND SCIENCE IS REALLY PROUD TO RELEASE      "
	dc.b	-1,$00,$00,$00,$00,$00,$03,$1,$2e,$00,$00,$00,$79,6
	dc.b	"POWERMONGER !!!      "
	dc.b	-1,$00,$00,$00,$00,$00,$00,$01,$25,$00,$0a,$01,$2b,6
	dc.b	"PROTECTION CHECK REMOVED BY...     "
	dc.b	-1,$00,$00,$00,$00,$00,$03,$1,$2e,$00,$00,$00,$79,6
	dc.b	"GOT AND EID     "

	dc.b	-1,$00,$05,$00,$00,$00,$00,$1,$2e,$00,$00,$00,$16,6
	dc.b	"ORIGINAL BOUGHT BY J.Y.  AND SUPPLIED BY STARDUST.     "
	dc.b	-1,$00,$00,$00,$00,$ff,$fc,$00,$00,$00,$00,$00,$00,6
	dc.b	"HI TO THE FOLLOWING GUYS...     "

	dc.b	-1,$00,$02,$00,$00,$00,$04,$01,$28,$00,$00,$00,$b4,10
	dc.b	"ALAIN    APOLLON    CHRISTOPHE    FANT TAG    LOOPING"
	dc.b	"    SLH    STARDUST    PHILIPPE      "

	dc.b	-1,$ff,$fd,$00,$03,$00,$01,$01,$66,$00,$aa,$01,$66,6
	dc.b	"THIS INTRO WAS CODED BY GOT AND EID...       "
	dc.b	-1,$00,$00,$00,$00,$00,$03,$1,$2e,$00,$00,$00,$79,6
	dc.b	"ENJOY THIS FANTASTIC GAME !!!...                     ",0
	
	even 

tbl_let:
	dc.b	" ABCDEFGHIJKLMNOPQRSTUVWXYZ.!:",0
	even
adr_let:
	dc.l	lsp,la,lb,lc,ld,le,lf,lg,lh,li,lj,lk,ll,lm,ln,lo,lp,lq,lr
	dc.l	ls,lt,lu,lv,lw,lx,ly,lz,lpoint,lpt_excl,lpoint2

init_scroll:
	move	#-200,pos_scroll
	lea	lsp(pc),a0
	lea	adr_text(pc),a1
	move.l	a0,(a1)+
	move.l	a0,(a1)+
	move.l	a0,(a1)+
	move.l	a0,(a1)+
	move.l	a0,(a1)+
	move.l	a0,(a1)
	move.l	#text,pt_text
	rts

pt_text:dc.l	0
speed:	dc.w	2

aff:
	lea	text_pres(pc),a0
	lea	screen,a1
	lea	char,a3
	moveq	#22,d1
aff12lign:
	moveq	#39,d0
aff19col:
	moveq	#0,d7
	move.b	(a0)+,d7

	bsr	aff_car
	
	lea	1(a1),a1

	dbf	d0,aff19col
	lea	320(a1),a1	

	dbf	d1,aff12lign
	
	rts

aff_car:
	lea	tbl_char(pc),a6
	moveq	#-1,d5
se:	move.b	(a6)+,d3
	beq	find
	addq	#1,d5
	cmp.b	d7,d3
	bne.s	se
find:
	lea	0(a3),a4
fadr:
	lea	0(a4,d5.w),a4
	lea	0(a1),a5	
	moveq	#7,d3
affl:
	move.b	(a4),(a5)
	lea	80(a4),a4
	lea	40(a5),a5
	dbf	d3,affl
	rts

tbl_char:dc.b	"0123456789:;<=>?./-',()*+!ABCDEFGHIJKLMNOPQRSTUVWXYZ ",0
	even

text_pres:
	dc.b	"----------------------------------------"
	dc.b	"         P O W E R M O N G E R (FINAL)  "
	dc.b	"----------------------------------------"
	dc.b	"                                        "
	dc.b	"         CRACKED BY GOT AND EID         "
	dc.b	"          OF THE UNFORGETTABLE          "
	dc.b	"           -ART AND SCIENCE-            "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	" SORRY FOR THIS BORING VECTORSCROLLER..."
	dc.b	" SOON I SHALL IMPROVE IT !              "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"     SPECIAL GREETINGS ARE GOING TO     "
	dc.b	"     JEAN-YVES - LOOPING - STARDUST     "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"     PRESS LEFT MOUSEBUTTON FOR GAME    "
	dc.b	"      AND RIGHT ONE  FOR GAME-INTRO     "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"              HAVE FUN !!!              "
	dc.b	"                                        "

pcol:	dc.w	0
wpcol:	dc.w	0
fondu:
	addq	#1,wpcol
	cmpi	#$2,wpcol
	bmi	fondu0
	clr	wpcol

	cmpi	#$f,pcol
	beq	fondu0
	addq	#1,pcol

	move	pcol,d0
	move	d0,d1
	lsr	#1,d0
	
	lsl	#4,d0
	or	d0,d1
	lsl	#4,d0
	or	d0,d1
	move	d1,$dff188


fondu0:	rts	



nbs:	dc.w	0
nbl:	dc.w	0
pos_scroll:dc.w	0
min_x:	dc.w	0
max_x:	dc.w	0
min_y:	dc.w	0
max_y:	dc.w	0

new_coords:	blk.w	400
coords_pt:	blk.w	400
faces:		blk.w	400
