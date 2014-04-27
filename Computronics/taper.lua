--taper, rewinds the tape.
--Authors: Bizzycola and Vexatos

local component = require("component")
local tape = component.tape_drive

if not tape.isReady() then
  io.stderr:write("The tape drive does not contain a tape.")
  return
end

tape.seek(-tape.getSize())
tape.stop()
