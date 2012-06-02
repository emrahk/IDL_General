pro accumgeta,fi,rootn,sidf,eidf,ct,ft,cr
	lets,ct,l
	outfile=fi+'.'+l+'.sav1'
	phafil=fi+'.'+l
	if(cr eq 1) then begin
		outfile=fi+'.'+l+'.cor5.sav1'
	endif
	sz=n_elements(sidf)
	idf=lonarr(2,sz)
	idf(0,*)=sidf
	idf(1,*)=eidf
        eband=[16,100]
        tres=1.D/1024.D
;	print,"ag:cl 1 idfs ",idf
	c1name=rootn+'.c1.dat'	
;	print,c1name
	if(cr eq 1) then begin
		c1cor=rootn+'.c1.cor2'	
		get_accum,c1name,c1count,c1live,mode='m',idfrange=idf,ul=c1cor,$
                          edgs=eband,iarr=idflvt,tres=tres
	endif else begin
		get_accum,c1name,c1count,c1live,mode='m',idfrange=idf,$
                          edgs=eband,iarr=idflvt,tres=tres

	endelse
	save,c1count,c1live,filename=outfile
;	if(ft eq 1) then begin
;		make_hexte_pha,c1count,c1live,fn=phafil,bk=0,cl=1
;	endif
	return
end

pro observe2a,fil,fits=fits,cor=cor
;
; reads occult files and runs get_accum
;
	cuts=0
	kwfits=0
	if(keyword_set(fits)) then kwfits=1
	kwcor=0
	if(keyword_set(cor)) then kwcor=1
	temp=''
	firstobs=1
	if (n_params() eq 0) then begin
		print,'Usage : observe,filename,/fits,/cor'
		return
	endif
	infile=fil+'.liv1'
	get_lun,u
	openr,u,infile
	while not eof(u) do begin
		readf,u,temp
		bs=strmid(temp,0,1)
		case bs of
			'#': begin
				print,temp
			end
			'r': begin
				print,temp
				readf,u,temp
				bs=strmid(temp,0,1)
				while bs ne 'r' do begin
					readf,u,temp
					bs=strmid(temp,0,1)
				endwhile
			end
			'c': begin
				accumgeta,fil,rootname,startidf,endidf,cuts,kwfits,kwcor
				cuts=cuts+1
				firstobs=1
			end
			'e': begin
				accumgeta,fil,rootname,startidf,endidf,cuts,kwfits,kwcor
				return
			end
			else: begin
				if(firstobs eq 1) then begin
					firstobs=0		
					crap=str_sep(temp," ")
					startidf=long(crap(0))
					endidf=long(crap(1))
					rootname=crap(2)
				endif else begin		
					crap=str_sep(temp," ")
					startidf=[startidf,long(crap(0))]
					endidf=[endidf,long(crap(1))]
					rootname=[rootname,crap(2)]
				endelse
			end
		endcase
	endwhile
	close,u
	free_lun,u
	accumgeta,fil,rootname,startidf,endidf,cuts,kwfits,kwcor
end

