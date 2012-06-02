FUNCTION EXIST, var
;
siz=size(var)
if siz(1) eq 0 then exfl=0 else exfl=1

return,exfl
end
