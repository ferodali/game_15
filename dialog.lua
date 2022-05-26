local android = require 'android'

local MAIN = android.new()

function MAIN.create(me, arg)
  local vbox
  vbox = me:vbox{
    scrollable = true,
    me:button('3', function() MAIN.RESULT = 3; me.a:finish() end),
    me:button('4', function() MAIN.RESULT = 4; me.a:finish() end),
    me:button('5', function() MAIN.RESULT = 5; me.a:finish() end),
    me:button('6', function() MAIN.RESULT = 6; me.a:finish() end),
    me:button('7', function() MAIN.RESULT = 7; me.a:finish() end),
    me:button('8', function() MAIN.RESULT = 8; me.a:finish() end),
  }

  local allView
  allView = me:vbox{
    me:textView('Pick a size of puzzle'),
    vbox
  }
  return allView
end

return MAIN
