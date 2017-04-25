;+
; Project     : HESSI
;
; Name        : HTML_TAGS
;
; Purpose     : include file for useful HTML tags
;
; Category    : HTML
;
; Syntax      : IDL>@html_tags
;
; Inputs      : None
;
; Outputs     : None
;
; Keywords    : None
;
; History     : 11-Aug-1999,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

;-- useful HTML tags

hr='<hr noshade>'
bold='<b>' & ebold='</b>'
br='<br>'
pr='<p>'
tr='<tr>'
space=' &nbsp '
opening='<html><body bgcolor="white">'
closing='</body></html>'
style0='<style type="text/css">'
style1='<!--'
style2='A {color:blue;text-decoration:none; '
style3='font-family: arial, helvetica,times, sans-serif}'
style4='// -->
style5='</style>'
style=[style0,style1,style2+style3,style4,style5]
meta=['<meta http-equiv="Expires" content="-1">',$
      '<meta http-equiv="Pragma" content="no-cache">',$
      '<meta http-equiv="Cache-Control" content="no-cache">']

