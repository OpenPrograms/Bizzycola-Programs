--tapep, rewinds and plays the tape, pauses playing drives. Use tapep -p to play the tape without rewinding it before
--Author: Bizzycola and Vexatos

local component = require("component")
local shell = require("shell")
local args, options = shell.parse(...)

if not component.isAvailable("tape_drive") then
  io.stderr:write("This program requires a tape drive to write to.")
  return
end

local tape = component.tape_drive

if not tape.isReady() then
  io.stderr:write("The tape drive does not contain a tape.")
  return
end

if tape.getState == "PLAYING" then
  tape.stop()
else
  if not options.p then
    tape.seek(-tape.getSize())
  end
  tape.play()
end
