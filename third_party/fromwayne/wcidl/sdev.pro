function sdev, data

w=moment(data,/double,/nan,sdev=sd)
sd=double(sd)

return,sd
end
