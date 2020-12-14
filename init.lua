hs.window.animationDuration = 0

function wf()
  local w = hs.window.focusedWindow()
  local a = w:application()
  local s = w:screen()
  local f = s:frame()
  return w,f
end

function intpart(x, w, slices, idx)
  local slice_size = w / slices
  local lo, hi = x, x+slice_size
  for i=2,idx do
    lo = hi
    hi = hi + slice_size
  end
  if idx == slices then
    hi = x + w
  end
  return lo, hi-lo
end

function fpart(f, xslices, xidx, yslices, yidx)
  f.x, f.w = intpart(f.x, f.w, xslices, xidx)
  f.y, f.h = intpart(f.y, f.h, yslices, yidx)
end

function push_window(xs, xi, ys, yi)
  return function()
    local w,f = wf()
    fpart(f,xs,xi,ys,yi)
    --hs.alert.show(w:application())
    w:setFrame(f)
  end
end

function cmd_l()
  local should_deselect = false
  local app = hs.application.frontmostApplication()
  local x = app:getMenuItems()
  for k,v in pairs(x) do
    if v.AXTitle == "Edit" then
      for k,v in pairs(v.AXChildren[1]) do
        if v.AXTitle:sub(1,4) == "Copy" and v.AXEnabled == 1 then
          should_deselect = true
        end
      end
    end
  end
  local junk = hs.pasteboard.getContents()
  local delay = 000
  if should_deselect then
    hs.eventtap.keyStroke({"cmd","alt"}, "a", delay)
  end
  hs.eventtap.keyStroke({"cmd","alt"},  "c", delay)
  hs.eventtap.keyStroke({"cmd","shift"},"g", delay)
  hs.eventtap.keyStroke({"cmd"},        "v", delay)
  hs.timer.doAfter(0.22, function()
    hs.pasteboard.setContents(junk)
  end)
end

hs.hotkey.bind({"alt"}, "right", push_window(2,2,1,1))
hs.hotkey.bind({"alt"}, "left", push_window(2,1,1,1))
hs.hotkey.bind({"alt"}, "up", push_window(1,1,2,1))
hs.hotkey.bind({"alt"}, "down", push_window(1,1,2,2))
hs.hotkey.bind({"alt"}, "1", push_window(2,1,2,1))
hs.hotkey.bind({"alt"}, "2", push_window(2,2,2,1))
hs.hotkey.bind({"alt"}, "3", push_window(2,1,2,2))
hs.hotkey.bind({"alt"}, "4", push_window(2,2,2,2))
hs.hotkey.bind({"alt"}, "v", push_window(1,1,1,1))
local cmd_l_binding = hs.hotkey.bind({"cmd"}, "l", cmd_l)

appWatcher = hs.application.watcher.new(function(appname, event, app)
  if appname == "Finder" then
    if event == hs.application.watcher.activated then
      cmd_l_binding:enable()
    elseif event == hs.application.watcher.deactivated then
      cmd_l_binding:disable()
    end
  end
end)
appWatcher:start()
if hs.application.frontmostApplication():name() ~= "Finder" then
  cmd_l_binding:disable()
end

reloadWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
