--tapep, rewinds and plays the tape.
--Author: Bizzycola

local component = require("component")
local tape = component.tape_drive
while true do
  if tape.seek(-1000000) < 1 then
    break
  end
end
tape.play()
