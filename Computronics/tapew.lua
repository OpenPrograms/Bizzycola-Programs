--tapew, use this to write to the tape
local component = require("component")
local shell = require("shell")
local args = shell.parse(...)

if #args<=0 then
  print("tapew, use this to write a file to the tape")
  print("Usage:")
  print("tapew <path/of/audio/file>")
  return
end

if not component.isAvailable("tape_drive") then
  io.stderr:write("This program requires a tape drive to write to.")
  return
end

local tape = component.tape_drive

local file = io.open(shell.resolve(args[1]), "rb")
local block = 1024

print("Writing...")

while true do
local bytes = file:read(block)
if not bytes then break end
tape.write(bytes)
end
file:close()

print("Done.")
