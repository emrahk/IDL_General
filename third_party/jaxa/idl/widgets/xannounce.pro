; $Id: xannounce.pro,v 1.1 1993/04/02 19:57:52 idl Exp $

pro xannounce_event, ev
  WIDGET_CONTROL, ev.top, /DESTROY
end







pro xannounce_kill

  COMMON xdemo_blk, xdemo_base
  COMMON xannounce_blk, id, base

  if XREGISTERED('XAnnounce', /NOSHOW) then WIDGET_CONTROL, /DESTROY, base

end







pro xannounce, source, text, group=group, just_reg=just_reg

  COMMON xdemo_blk, xdemo_base
  COMMON xannounce_blk, id, base

  not_present = not XREGISTERED('XAnnounce')

;  WIDGET_INFO, version=v

  if (not_present) then begin		; Create it
      ; Use the XDEMO as the group leader
      if (XREGISTERED('xdemo')) then grp=xdemo_base $
      else if (not KEYWORD_SET(group)) then grp=0L else grp = group
      base = WIDGET_BASE(title='XAnnounce', /column, group=grp, $
		xoffset=300, yoffset=300)
      button = WIDGET_BUTTON(base, value='Dismiss')
      label = WIDGET_TEXT(base, ysize=4, xsize=24, value = $
	[ 'XAnnounce is used by various IDL widget applications to', $
	  'send messages to the user. If you press the DISMISS button,', $
	  'it will be removed from the screen until the next message.', $
	  'You can also leave it on the screen.'])
      ID = WIDGET_TEXT(base, /SCROLL, xsize=80, ysize=10)
      WIDGET_CONTROL, base, /REALIZE
  endif

  WIDGET_CONTROL, ID, /APPEND, $
	SET_VALUE = [ systime(0)+ ':  Message from '+source, text,  ' ', ' ']

  if (not_present) then begin
    XMANAGER, 'XAnnounce', base, just_reg=keyword_set(just_reg)
  endif
end
