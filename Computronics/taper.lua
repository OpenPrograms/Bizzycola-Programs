--taper, rewinds the tape.
--Authors: Bizzycola and Vexatos

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

tape.seek(-tape.getSize())
tape.stop()
