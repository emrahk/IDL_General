pro get_sci_hdr,sch,idf_hdr,arch=arch
;************************************************************************
; Subroutine extracts the science data header from the long integer
; array sch. Variables are:
;      sch..............long integer array
;  idf_hdr..............header containing science data
; The arrays contained in idf_hdr are found in Hexte design memo
; 30061-710-009,REV D page 5 or thereabouts.
; 8/22/93 Removed print statements
; First define the idf_hdr structure
;************************************************************************
idf_hdr = {sci,$
           idf_num:0L,$
           clstr_postn:' ',$
           clstr_id:'    ',$
           modul_position:' ',$
           dwell_time:'  ',$
           sci_mode:'    ',$
           ctl_tbl_index: 0L,$
           Na: 0L,$
           Nb: 0L,$
           Nc: 0L,$
           Nd: 0L,$
           Ne_: lonarr(8),$
           Nf: 0L,$
           Ng: 0L,$
           Nh: lonarr(9),$
           brstrg_en:'   ',$
           brs_evt_sto:' ',$
           brstrg_thres: 0L,$
           post_trg_cnt: 0L,$
           good_events: lonarr(4),$
           veto_events: lonarr(4),$
           mode_id: '    ',$
           pkts_sent: 0L,$
           tlm_ovf_flag: 0L,$
           lt_invalid: 0L}
;************************************************************************
; Make the number arrays for longword and byte conversion
;************************************************************************
long_nums = 2.^dindgen(32)
long_nums = transpose(rotate(long_nums,6))
byte_nums = long_nums(24:31)
dbyte_nums = long_nums(16:31)
hbyte_nums = long_nums(28:31)
;************************************************************************
; Sch(0): Get the 28 bit Instrument data frame count(IDF_NUM). The thing
; is laid in backwards so inversion is necessary.
;************************************************************************
num_read,32,sch(0),idf_bits
idf_bits = transpose(rotate(idf_bits,6))
idf_num0 = idf_bits(0:7)
idf_num1 = idf_bits(8:15)
idf_num2 = idf_bits(16:23)
idf_num3 = idf_bits(24:31)
idf_num = [idf_num3,idf_num2,idf_num1,idf_num0]
idf_hdr.idf_num = long(total(long_nums*idf_num))
;************************************************************************
; Sch(1): Get the cluster position(CLSTR_POSTN), cluster id: CLSTR_ID),
; dwell time(DWELL_TIME), Aperture modulation position
; command(MODULE_POSITION). Do cluster postion differently if 
; archive histogram mode.
;************************************************************************
clstr_postn_str = ['0 (FOR +/- 1.5 DEG)','+1.5','+3.0',$
 '0 (FOR +/- 3.0 DEG)','-3.0','-1.5','TBD','TBD'] 
m_p_str = ['FREEZE AT PRESENT POSITION','+/- 1.5 DEG','+/- 3.0 DEG',$
 '+1.5 DEG FIXED','-1.5 DEG FIXED','+3.0 DEG FIXED','-3.0 DEG FIXED',$
  '0 (+/- 1.5 DEG), FIXED','0 (+/- 3.0 DEG), FIXED']
d_t_str = ['CONTINUOUS','16 SECONDS','32 SECONDS','64 SECONDS',$
 '128 SECONDS']
clstr_id_str = ['CEU I','CEU II']
num_read,32,sch(1),long_bits
long_bits = transpose(rotate(long_bits,6))
if (ks(arch) ne 0)then begin
   byte4 = long_bits(0:7) 
   cp = total(byte_nums*byte4)
   if (cp lt 8)then idf_hdr.clstr_postn = clstr_postn_str(cp) $
   else idf_hdr.clstr_postn = clstr_postn_str(0)
endif else begin
   byte4 = rotate(long_bits(0:7),-6)   
   byte4(6:7) = 0
   cp = where(byte4 eq 1)
   if (cp(0) ne -1)then begin
      idf_hdr.clstr_postn = clstr_postn_str(cp(0))
   endif else begin
      idf_hdr.clstr_postn = clstr_postn_str(0)
   endelse
endelse
byte5 = long_bits(8:15) 
byte6 = fix(total(long_bits(16:23)*byte_nums))
byte7 = fix(total(long_bits(24:31)*byte_nums))
if (byte6 gt 8)then byte6 = 0
if (byte7 gt 4)then byte7 = 0
idf_hdr.clstr_id = clstr_id_str(byte5(0))
idf_hdr.modul_position = m_p_str(byte6)
idf_hdr.dwell_time = d_t_str(byte7)
;************************************************************************
; Sch(2): science mode(SCI_MODE),current science mode control 
; table index(CTL_TBL_INDEX),Control table data: Na,Nb,Nc,Nd
; Some control data are half a byte. This is in backwards
;************************************************************************
s_m_str = ['IDLE','EVENT LIST','HISTOGRAM BIN','MULTISCALAR BIN',$
   'PHA/PSA SPECTRA','NOT USED','BURST LIST DOWN LOAD','DIAGNOSTIC MODE']
num_read,32,sch(2),sch2_bits
sch2_bits = rotate(sch2_bits,2)
byte8 = sch2_bits(0:7)
byte9 = sch2_bits(8:15)
byte10 = sch2_bits(16:23)   
byte11 = sch2_bits(24:31)
a = where(byte8 eq 1)   
if (a(0) ne -1)then idf_hdr.sci_mode = s_m_str(a(0)) else $
idf_hdr.sci_mode = s_m_str(0)
idf_hdr.ctl_tbl_index = fix(total(byte9*byte_nums))
idf_hdr.Nb = long(total(byte10(0:3)*hbyte_nums))
idf_hdr.Na = long(total(byte10(4:7)*hbyte_nums))
idf_hdr.Nd = long(total(byte11(4:5)*[2,1]))
idf_hdr.Nc = long(total(byte11(6:7)*[2,1]))
;************************************************************************
; Sch(3): more control table data. The event list parameter Ne is 
; returned as a bit array. For the multiscalar data, the PHA 
; range parameters (low,high1,high2,...) are in Nh
; 1/11/94 Shifted Nh for msc bin (DCM)
;************************************************************************
num_read,32,sch(3),sch3_bits
sch3_bits = rotate(sch3_bits,2)
byte12 = sch3_bits(0:7)
byte13 = sch3_bits(8:15)
byte14 = sch3_bits(16:23)
byte15 = sch3_bits(24:31)
num_read,32,sch(4),sch4_bits
sch4_bits = rotate(sch4_bits,2)
byte16 = sch4_bits(0:7)
byte17 = sch4_bits(8:15)
byte18 = sch4_bits(16:23)
byte19 = sch4_bits(24:31)
num_read,32,sch(5),sch5_bits
sch5_bits = rotate(sch5_bits,2)
byte20 = sch5_bits(0:7)
byte21 = sch5_bits(8:15)
byte22 = sch5_bits(16:23)
byte23 = sch5_bits(24:31)
idf_hdr.Ne_ = long(byte12)
idf_hdr.Nf = long(total(byte13(4:7)*byte_nums(0:3)))
idf_hdr.Ng = long(total(byte14*byte_nums))
Nh = lonarr(9)
Nh(0) = long(total(byte15*byte_nums))
Nh(1) = long(total(byte16*byte_nums))
Nh(2) = long(total(byte17*byte_nums))
Nh(3) = long(total(byte18*byte_nums))
Nh(4) = long(total(byte19*byte_nums))
Nh(5) = long(total(byte20*byte_nums))
Nh(6) = long(total(byte21*byte_nums))
Nh(7) = long(total(byte22*byte_nums))
Nh(8) = long(total(byte23*byte_nums))
idf_hdr.Nh = shift(Nh,1)
;***********************************************************************
; Sch(6): Burst data arrays
;***********************************************************************
b_en_str = ['DISABLED','ENABLED']
b_e_str = ['START(RUNNING)','STOP(COMPLETED)']
num_read,32,sch(6),long_bits
long_bits = rotate(long_bits,2)
byte24 = long_bits(0:7)
byte25 = long_bits(8:15)
byte26 = long_bits(16:23)
byte27 = long_bits(24:31)
idf_hdr.brstrg_en = b_en_str(fix(byte24(7)))
idf_hdr.brs_evt_sto = b_e_str(fix(byte25(7)))
idf_hdr.brstrg_thres = long(total(byte26*byte_nums))
idf_hdr.post_trg_cnt = long(total(byte27*byte_nums))
;*****************************************************************************
; Sch(7:8): Detectors 1 thru 4 good event counts. These are stored in
; a 4 element long array GOOD_EVENTS. Once more the 16 bit numbers are
; entered in backwards and must be 'reversed'
;*****************************************************************************
good_events = lonarr(4)
for i = 0,1 do begin
 num_read,32,sch(7+i),long_bits
 long_bits = rotate(long_bits,2)
 for j = 0,1 do begin
  rhbyte = long_bits(8*j:8*j+7)
  lhbyte = long_bits(8*j+8:8*j+15)
  good_events(2*i+j) = long(total([lhbyte,rhbyte]*dbyte_nums))
 endfor
endfor
idf_hdr.good_events = good_events
;*****************************************************************************
; Sch(9:10): Detectors 1 thru 4 veto event counts. Stored and extracted
; the same way as good_events. Array "veto_events"
;*****************************************************************************
veto_events = lonarr(4)
for i = 0,1 do begin
 num_read,32,sch(9+i),long_bits
 long_bits = rotate(long_bits,2)
 for j = 0,1 do begin
  rhbyte = long_bits(8*j:8*j+7)
  lhbyte = long_bits(8*j+8:8*j+15)
  veto_events(2*i+j) = long(total([lhbyte,rhbyte]*dbyte_nums))
 endfor
endfor
idf_hdr.veto_events = veto_events
;*****************************************************************************
; Sch(11): Science mode id (MODE_ID), # of packets sent (PKTS_SENT),
; telemetry overflow flag (TLM_OVF_FLAG), and invalid livetime 
; flag (LT_INVALID). Once again this is in backwards.
;*****************************************************************************
num_read,32,sch(11),long_bits
long_bits = rotate(long_bits,2)
byte44 = long_bits(0:7)
byte45 = long_bits(8:15)
byte46 = long_bits(16:23)
byte47 = long_bits(24:31)
mode_id0 = string(byte(total(byte44*byte_nums))) 
mode_id1 = string(byte(total(byte45*byte_nums)))
idf_hdr.mode_id = strcompress(mode_id0 + mode_id1,/remove_all)
idf_hdr.pkts_sent = total(byte46*byte_nums)
idf_hdr.tlm_ovf_flag = long(byte47(0))
idf_hdr.lt_invalid = long(byte47(1))
;*****************************************************************************
; Thats all the science header data.
;*****************************************************************************
return
end
