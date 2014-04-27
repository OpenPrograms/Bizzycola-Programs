--tapew, use this to write to the tape
--Authors: Bizzycola and Vexatos

local component = require("component")
local fs = require("filesystem")
local shell = require("shell")
local term = require("term")
local args,options = shell.parse(...)

if #args<=0 then
  print("tapew, use this to write a file to the tape")
  print("Usage:")
  print("'tapew <path/of/audio/file>' to write from a file")
  print("'tapew -o <URL>' to write from a URL")
  print("Other options:")
  print("'--address=<address>' to use a specific tape drive")
  return
end

if not component.isAvailable("tape_drive") then
  io.stderr:write("This program requires a tape drive to write to.")
  return
end

--Credits to gamax92 for this
local tape
if options.address then
  if type(options.address) ~= "string" then
    io.stderr:write("'address' may only be a string.")
    return
  end
  local fulladdr = component.get(options.address)
  if fulladdr == nil then
    io.stderr:write("No component at this address.")
    return
  end
  if component.type(fulladdr) ~= "tape_drive" then
    io.stderr:write("No tape drive at this address.")
    return
  end
  tape = component.proxy(fulladdr)
else
  tape = component.tape_drive
end
--End of gamax92's part

if not tape.isReady() then
  io.stderr:write("The tape drive does not contain a tape.")
  return
end

tape.stop()
tape.seek(-tape.getSize())
tape.stop() --Just making sure

local file,msg
local block = 1024 --How much to read at a time
local bytery = 0 --For the progress indicator
local filesize = tape.getSize()
local _,y = term.getCursor()

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
    if string.match(bytes,"Content%-Length: (.-)\r\n") then
      filesize = tonumber(string.match(bytes,"Content%-Length: (%d-)\r\n"))
    end
    if string.find(bytes,"\r\n\r\n") then
      bytes = string.gsub(bytes,".-\r\n\r\n","",1)
      if not bytes then break end
      term.setCursor(1,y)
      bytery = bytery + #bytes
      term.write("Read "..tostring(bytery).." bytes...")
      tape.write(bytes)
      start = true
    elseif string.find(bytes,"\r\n?$") then
      local old = bytes
      bytes = file:read(block)
      local match = old..bytes
      if string.find(match,"\r\n\r\n") then
        bytes = string.gsub(match,".-\r\n\r\n","",1)
        if not bytes then break end
        term.setCursor(1,y)
        bytery = bytery + #bytes
        term.write("Read "..tostring(bytery).." bytes...")
        tape.write(bytes)
        start = true
      end
    end
  until start == true
else
  local path = shell.resolve(args[1])
  filesize = fs.size(path)
  print("Path: "..path)
  file,msg = io.open(shell.resolve(path), "rb")
  if not file then
    io.stderr:write("Error: "..msg)
    return
  end
  print("Writing...")
end

if filesize > tape.getSize() then
  io.stderr:write("Error: File is too large for tape, shortening file")
  filesize = tape.getSize()
end

while true do
  local bytes = file:read(math.min(block,filesize-bytery))
  if (not bytes) or bytes == "" then break end
  term.setCursor(1,y)
  bytery = bytery + #bytes
  term.write("Read "..tostring(bytery).." of "..tostring(filesize).." bytes...")
  tape.write(bytes)
end
file:close()

print("\nDone.")
