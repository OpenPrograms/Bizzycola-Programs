--tapel, labels the tape(doesn't take spaces yet, sorry)
local component = require("component")
local tape = component.tape_drive

local args = {...}
if #args < 1 then
  print("Usage:")
  print("tapel <label>")
else
  tape.setLabel(args[1])
end
