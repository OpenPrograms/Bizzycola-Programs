--tapew, use this to write to the tape
local component = require("component")
local tape = component.tape_drive
 
 
local file = io.open("/mnt/230/audio", "rb") --change '230' to your drives 3 letters, change 'audio' to the name of the file
local block = 1024
while true do
        local bytes = file:read(block)
        if not bytes then break end
        tape.write(bytes)
end