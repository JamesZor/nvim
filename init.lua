require "user.option"
require "user.keymaps"
require "user.plugins"
require "user.colourscheme"
require "user.cmp"
require "user.lsp"
require "user.telescope"
require "user.treesitter"
require "user.vimtex"
require "user.toggleterm"
require "user.comment"
require("user.molten")

--require "user.conda"
--
-- Add all possible Lua paths
package.path = package.path .. 
    ";/usr/share/lua/5.1/?.lua;" ..
    "/usr/share/lua/5.1/?/init.lua;" ..
    "/usr/lib/lua/5.1/?.lua;" ..
    "/usr/lib/lua/5.1/?/init.lua;" ..
    "~/.luarocks/share/lua/5.1/?.lua;" ..
    "~/.luarocks/share/lua/5.1/?/init.lua"

package.cpath = package.cpath .. 
    ";/usr/lib/lua/5.1/?.so;" ..
    "/usr/lib/lua/5.1/loadall.so;" ..
    "~/.luarocks/lib/lua/5.1/?.so"
