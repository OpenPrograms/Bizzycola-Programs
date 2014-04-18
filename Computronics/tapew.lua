--tapew, use this to write to the tape
local component = require("component")
local tape = component.tape_drive
local shell = require("shell")
local args = shell.parse(...)

if #args<=0 then
  print("Usage:")
  print("tapew <path/of/audio/file>")
  return
end

local file = io.open(shell.resolve(args[1]), "rb")
local block = 1024
while true do
  local bytes = file:read(block)
  if not bytes then break end
  tape.write(bytes)
end
