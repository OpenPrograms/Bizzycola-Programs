--tapel, labels the tape(doesn't take spaces yet, sorry)
--Author: Bizzycola and Vexatos

local component = require("component")

if not component.isAvailable("tape_drive") then
  io.stderr:write("This program requires a tape drive to run.")
  return
end

local tape = component.tape_drive

if not tape.isReady() then
  io.stderr:write("The tape drive does not contain a tape.")
  return
end

local args = {...}
if #args < 1 then
  print("Usage:")
  print("tapel <label>")
else
  tape.setLabel(args[1])
end
