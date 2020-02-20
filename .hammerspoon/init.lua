-------------------------------------------------------------------------------
-- Dual-purpose the ctrl key as both escape (when pressed and released) and as
-- a regular ctrl (when pressed along with another key).

send_escape = false
last_mods = {}

control_key_handler = function()
  send_escape = false
end

control_key_timer = hs.timer.delayed.new(0.15, control_key_handler)

control_handler = function(evt)
  local new_mods = evt:getFlags()
  if last_mods["ctrl"] == new_mods["ctrl"] then
    return false
  end
  if not last_mods["ctrl"] then
    last_mods = new_mods
    send_escape = true
    control_key_timer:start()
  else
    if send_escape then
      hs.eventtap.keyStroke({}, "ESCAPE")
    end
    last_mods = new_mods
    control_key_timer:stop()
  end
  return false
end

control_tap = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, control_handler)
control_tap:start()

other_handler = function(evt)
  send_escape = false
  return false
end

other_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, other_handler)
other_tap:start()

-------------------------------------------------------------------------------
-- Fix ctrl-6 in Terminal.app for Vim.

ctrl_6_handler = function()
    hs.eventtap.keyStroke({'ctrl', 'shift'}, '6', 0)
end

hs.hotkey.bind({'ctrl'}, '6', nil, ctrl_6_handler)

-------------------------------------------------------------------------------
-- Add menubar item to enable/disable sleep.
caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setTitle("c[#]")
    else
        caffeine:setTitle("c[_]")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

-------------------------------------------------------------------------------
-- hs.caffeinate.watcher.screensaverDidStart

function screensaverActivatedCallback(etype)
    if
            etype == hs.caffeinate.watcher.screensaverDidStart or
            etype == hs.caffeinate.watcher.screensDidSleep or
            etype == hs.caffeinate.watcher.screensDidLock or
            etype == hs.caffeinate.watcher.systemWillSleep then
        os.execute("ssh-add -D")
    end
end

screensaverWatcher = hs.caffeinate.watcher.new(screensaverActivatedCallback)
screensaverWatcher:start()
