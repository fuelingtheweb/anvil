#!/usr/bin/env python3
"""Parses every .lua under a folder with Hammerspoon's own Lua (LuaSkin), as
macOS has no luac. Nothing is run. A syntax error reloading takes down every
layer, so pre-push stops one here.

Exits 0 when all parse, 1 with each error printed, 2 without Hammerspoon.
"""

import ctypes
import os
import pathlib
import sys

LUASKIN = "/Applications/Hammerspoon.app/Contents/Frameworks/LuaSkin.framework/LuaSkin"


def main(folder: str) -> int:
    try:
        lua = ctypes.CDLL(LUASKIN)
    except OSError:
        return 2
    lua.luaL_newstate.restype = ctypes.c_void_p
    lua.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
    lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
    lua.lua_tolstring.restype = ctypes.c_char_p
    lua.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]

    # From inside it: Lua cuts a long path short in its messages.
    os.chdir(folder)
    state = lua.luaL_newstate()
    failed = 0
    for path in sorted(pathlib.Path().rglob("*.lua")):
        if lua.luaL_loadfilex(state, str(path).encode(), None):
            print(lua.lua_tolstring(state, -1, None).decode(errors="replace"))
            failed += 1
        lua.lua_settop(state, 0)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
