local helpers = require('test.functional.helpers')(after_each)

local Screen = require('test.functional.ui.screen')
local call = helpers.call
local clear = helpers.clear
local feed = helpers.feed
local feed_command = helpers.feed_command
local funcs = helpers.funcs
local meths = helpers.meths
local eq = helpers.eq
local exec = helpers.exec

describe('visual line mode', function()
  local screen

  it('redraws properly after scrolling with matchparen loaded and scrolloff=1', function()
    clear{args={'-u', 'NORC'}}
    screen = Screen.new(30, 7)
    screen:attach()
    screen:set_default_attr_ids({
      [1] = {bold = true},
      [2] = {background = Screen.colors.LightGrey},
    })

    eq(1, meths.get_var('loaded_matchparen'))
    feed_command('set scrolloff=1')
    funcs.setline(1, {'a', 'b', 'c', 'd', 'e', '', '{', '}', '{', 'f', 'g', '}'})
    call('cursor', 5, 1)

    feed('V<c-d><c-d>')
    screen:expect([[
      {2:{}                             |
      {2:}}                             |
      {2:{}                             |
      {2:f}                             |
      ^g                             |
      }                             |
      {1:-- VISUAL LINE --}             |
    ]])
  end)
end)

describe('visual block mode', function()
  it('shows selection correctly with virtualedit=block', function()
    clear()
    local screen = Screen.new(30, 7)
    screen:set_default_attr_ids({
      [1] = {bold = true},  -- ModeMsg
      [2] = {background = Screen.colors.LightGrey},  -- Visual
      [3] = {foreground = Screen.colors.Blue, bold = true}  -- NonText
    })
    screen:attach()

    exec([[
      call setline(1, ['aaaaaa', 'bbbb', 'cc'])
      set virtualedit=block
      normal G
    ]])

    feed('<C-V>gg$')
    screen:expect([[
      {2:aaaaaa}^                        |
      {2:bbbb   }                       |
      {2:cc     }                       |
      {3:~                             }|
      {3:~                             }|
      {3:~                             }|
      {1:-- VISUAL BLOCK --}            |
    ]])

    feed('<Esc>gg<C-V>G$')
    screen:expect([[
      {2:aaaaaa }                       |
      {2:bbbb   }                       |
      {2:cc}^ {2:    }                       |
      {3:~                             }|
      {3:~                             }|
      {3:~                             }|
      {1:-- VISUAL BLOCK --}            |
    ]])
  end)
end)
