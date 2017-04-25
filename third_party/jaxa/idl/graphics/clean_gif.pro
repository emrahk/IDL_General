;+
; Name:
;	CLEAN
;
; Purpose:
;	To fix-up a gif image with a weird color table.  Gifs, in general,
;	have color tables in random order.  It is helpful to have them sorted
;	out in intensity order.  CLEAN_GIF does that.  It is designed to be 
;	used on memory-resident gif images or as a replacement for READ_GIF
;	(with a slight change of parameter order from READ_GIF).
;
; Usage:
;	ZFIX_GIF,a,r,g,b,f  - Read a gif image, clean, and return in (a,r,g,b)
;	ZFIX_GIF,a,rgb,f    - Read a gif image, clean, and return in (a,rgb)
;	ZFIX_GIF,a,f	    - Read a gif image, clean, and return in (a)
;	ZFIX_GIF,a,r,g,b    - Clean (a,r,g,b) in place
;	ZFIX_GIF,a,rgb      - Clean (a,rgb) in place
; 
; PARAMETERS:
;	A   - the image to fix.  (I/O; if 'F' specified, output only)
;	RGB - a 256x3 matrix containing the complete color table (I/O)
;		(This may be used INSTEAD of r,g, and b).
;	R   - a 256 element array; the red   part of the color table (I/O)
;	G   - a 256 element array; the green part of the color table (I/O)
;	B   - a 256 element array; the blue  part of the color table (I/O)
;	F   - A file to load in. (Input only)
; 
; Method: 
;	If necessary, a gif image is read in from a file.  Then the 
;	color table is sorted and the image values diddled to match the
;	sorting order.  Finally, appropriate values are stuck back into th
;	parameters.
;
; History:
;	Written by Craig DeForest, 2-Sep-98
;
;-


pro clean_gif,a,r,g,b,f

read=0

case n_params() of 
	2: begin ; we have either a,rgb or a,f
	 	if data_chk(r,/string) then begin
			read = 1
			rgbflag = 0
			f = r
		end else begin
			read = 0
			rgbflag = 2
		end
	  end
	3: begin  ; we have a,rgb,f
		read = 1
		rgbflag=2
		f=g
	   end
	4: begin ; we have a,r,g,b
		read = 0
		rgbflag = 1
	   end
	5: begin ; we have a,r,g,b,f
		read = 1
		rgbflag = 1
	   end
end

if(read) then begin
	read_gif,f,a,r1,g1,b1
	case rgbflag of
		0: ; do nothing
		1: begin
			r=r1
			g=g1
			b=b1
		   end
		2: r = [[r],[g],[b]]
	end
end

case rgbflag of 
	0: v = total([[fix(r1)],[fix(g1)],[fix(b1)]],2)
	1: v = total([[fix(r)],[fix(g)],[fix(b)]],2)
	2: v = total(fix(r),2)
end

s = sort(v)
s1 = sort(s)

case rgbflag of
	0:
	1: begin
		r = r(s)
		g = g(s)
		b = b(s)
	end
	2: r = [[r(s,0)],[r(s,1)],[r(s,2)]]
end		

a1 = a
a(*) = s1(a1(*))
end

	
		
