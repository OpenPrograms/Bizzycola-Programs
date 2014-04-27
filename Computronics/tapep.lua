--tapep, plays the tape, pointless now because yo can do it on the tape drive, but here anyway.
local component = require("component")
local tape = component.tape_drive
while true do
  if tape.seek(-1000000) < 1 then
    break
  end
end
tape.play()
