PPI = require("ppi")
ppi = PPI.Load("aedf0cb0be5bf045860d54b7")

soundvolume=30
musicvolume=30
volid=1
priorarea="none"
currentarea="none"
rooms={}
dir=world.GetInfo(67)
print(dir)
cl={}

function getconfig(cn)
for c=1,#cl do
if cl[c].name==cn then
return cl[c].value
end
end
print("error: Unable to locate "..cn.." in config list.")
end



if tonumber(areamusic)~=nil then
ppi.stop(areamusic)

end
areamusic=0

cl={
{name="areamusic",value="on",desc="Toggles area music.",values={"on","off"}}
}
cl[2]={name="areanotify",desc="Enables or disables notifications for area changes.",value="on",values={"on","off"}}




function saverooms()
roomfile=io.open(dir.."/data/rooms.txt","w+b")

for r=1,#rooms do
roomstr=""
roomstr=rooms[r].name.."\r\n"..rooms[r].exits.."\r\n"..rooms[r].area.."\r\n"

roomfile:write(roomstr)
end
roomfile:close()
print("rooms saved")
end


function split(str, delimitor)
substrings = {}
temp = ""
for c in str:gmatch(".") do
if c == delimitor then
table.insert(substrings, temp)
temp = ""
else
temp = temp..c
end
end
if #temp then
table.insert(substrings, temp)
end
return substrings
end

function stringToTable(str)
return split(str:gsub("%s+", ""), ",")
end

function tableContains(t, a)
for i=1, #t do
if t[i] == a then
return true
end
end
return false
end

function compareTables(a, b)
if not (#a == #b) then
return false
end
for i=1, #a do
if not tableContains(b, a[i]) then
return false
end
end
return true
end

function match_room(name, exits, index)
if name==rooms[index].name and compareTables(stringToTable(exits), stringToTable(rooms[index].exits)) then
return true
end
return false
end


function loadrooms()
temp=1
tempt={}
for line in io.lines(dir.."/data/rooms.txt") do

tempt[#tempt+1]=line
temp=temp+1
if temp>3 then
rooms[#rooms+1]={name=tempt[1],exits=tempt[2],area=tempt[3]}
temp=1
tempt={}
end
end
end




function playsound(snd)
return ppi.play(dir.."sounds/"..snd,0,0,soundvolume)

end

function playloop(snd)
return ppi.play(dir.."sounds/area music/"..snd,1,0,musicvolume)

end

function channelsound(snd)
if io.open(dir.."sounds/channels/"..snd..".ogg", "r") then
playsound("channels/"..snd..".ogg")
else
playsound("channels/global.ogg")
end
end

function stopsound(snd)
if tonumber(snd)~=nil then
ppi.stop(snd)
end
end


function setarea(areaname)
if priorarea==areaname then
return
else
areamusic=stopsound(areamusic)
if getconfig("areamusic")=="on" then
areamusic=playloop(areaname..".ogg")
end

currentarea=areaname
if getconfig("areanotify")=="on" then
print("Entering "..currentarea..".")
end
end
end


function vt()
if volid==1 then
print("Changing area music volume, current value "..musicvolume..".")
volid=2
else
print("Changing global sound volume, current value "..soundvolume..".")
volid=1
end
end

function setvol(id)
if id==1 then
if volid==1 then
if soundvolume+5>100 then
print("error: Volume can not exceed 100.")
return
end
soundvolume=soundvolume+5
playsound("appears locked.ogg")
end
if volid==2 then
if musicvolume+5>100 then
print("error: volume can not exceed 100.")
return
end
musicvolume=musicvolume+5
ppi.play(dir.."sounds/appears locked.ogg",0,0,musicvolume)

end
end
if id==2 then
if volid==1 then
if soundvolume-5<0 then
print("error: muted.")
return
end
soundvolume=soundvolume-5
playsound("appears locked.ogg")
end
if volid==2 then
if musicvolume-5<0 then
print("error: muted.")
return
end
musicvolume=musicvolume-5
ppi.play(dir.."sounds/appears locked.ogg",0,0,musicvolume)
end
end

end



Accelerator("f10","vt")
Accelerator("f11","volup")
Accelerator("f12","voldown")

function saveconfig()
cfile=io.open(dir.."data/config.txt","w+b")
for c=1,#cl do
cfile:write(cl[c].value)
if c<#cl then
cfile:write("\r\n")
end
end
cfile:close()

cfile=io.open(dir.."data/vol.txt","w+b")
cfile:write(soundvolume.."\r\n"..musicvolume)
cfile:close()
end

function loadconfig()
c=1
for line in io.lines(dir.."data/config.txt") do
cl[c].value=line
c=c+1
end


a=1

for line in io.lines(dir.."data/vol.txt") do
if a==1 then
soundvolume=tonumber(line)
end
if a==2 then
musicvolume=tonumber(line)
end
a=a+1
end
end

loadrooms()
loadconfig()

print("Setup successfull.")

function ExecuteNoStack(cmd)
local s = GetOption("enable_command_stack")
SetOption("enable_command_stack", 0)
Execute(cmd)
SetOption("enable_command_stack", s)
end
