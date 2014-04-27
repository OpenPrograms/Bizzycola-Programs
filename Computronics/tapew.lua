--tapew, use this to write to the tape
--Authors: Bizzycola and Vexatos

local component = require("component")
local shell = require("shell")
local term = require("term")
local args,options = shell.parse(...)

if #args<=0 then
  print("tapew, use this to write a file to the tape")
  print("Usage:")
  print("'tapew <path/of/audio/file>' to write from a file")
  print("'tapew -o <URL>' to write from a URL")
  return
end

if not component.isAvailable("tape_drive") then
  io.stderr:write("This program requires a tape drive to write to.")
  return
end

local tape = component.tape_drive
local block = 1024

if not tape.isReady() then
  io.stderr:write("The tape drive does not contain a tape.")
  return
end

tape.stop()
tape.seek(-tape.getSize())
tape.stop() --Just making sure

local file,msg
local bytery = 0 --For the progress indicator
if options.o then

  local url = string.gsub(args[1],"https?://","",1)
  local domain = string.gsub(url,"/.*","",1)
  print("Domain: "..domain)
  local path = string.gsub(url,".-/","/",1)
  print("Path: "..path)

  if not component.isAvailable("internet") then
  io.stderr:write("This program requires an internet card to run.")
  return
  end

  local internet = require("internet")
  file = internet.open(domain, 80)
  file:setTimeout(10)
  local start = false
  
  print("Writing...")

  file:write("GET "..path.." HTTP/1.1\r\nHost: "..domain.."\r\nConnection: close\r\n\r\n")
  repeat
    local bytes = file:read(block)
    if string.find(bytes,"\r\n\r\n") then
      bytes = string.gsub(bytes,".-\r\n\r\n","",1)
      if not bytes then break end
      bytery = bytery + #bytes
      tape.write(bytes)
      start = true
    end
  until start == true
else
  local path = shell.resolve(args[1])
  print("Path: "..path)
  file,msg = io.open(shell.resolve(path), "rb")
  if not file then
    print("Error: "..msg)
    return
  end
  print("Writing...")
end

local _,y = term.getCursor()
while true do
  local bytes = file:read(block)
  term.setCursor(1,y)
  if (not bytes) or bytes == "" then break end
  bytery = bytery + #bytes
  term.write("Read "..tostring(bytery).." bytes...")
  tape.write(bytes)
end
file:close()

term.setCursor(1,y+1)
print("Done.")
