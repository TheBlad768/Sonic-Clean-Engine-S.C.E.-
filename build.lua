#!/usr/bin/env lua

--------------
-- Settings --
--------------

-- Create the debug ROM.
local debug = false

---------------------
-- End of settings --
---------------------

local common = require "AS.lua.common"

local compression = "kosinskiplus"

-- Assemble the ROM.
local message, abort = common.build_rom("Sonic", "Sonic", "", "-p=FF -z=0," .. compression .. ",Size_of_Snd_driver_guess,after", false, "https://github.com/sonicretro/skdisasm")

if message then
	exit_code = false
end

if abort then
	os.exit(exit_code, true)
end

-- Buld DEBUG ROM

if debug then
	local message, abort = common.build_rom("Sonic", "Sonic.Debug", "-D __DEBUG__ -OLIST Sonic.Debug.lst", "-p=FF -z=0," .. compression .. ",Size_of_Snd_driver_guess,after", false, "https://github.com/sonicretro/skdisasm")

	if message then
		exit_code = false
	end

	if abort then
		os.exit(exit_code, true)
	end
end

-- Append symbol table to the ROM.
local extra_tools = common.find_tools("debug symbol generator", "https://github.com/vladikcomper/md-modules", "https://github.com/sonicretro/skdisasm", "convsym")

if not extra_tools then
	os.exit(false)
end

os.execute(extra_tools.convsym .. " Sonic.lst Sonic.gen -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a")

if debug then
	os.execute(extra_tools.convsym .. " Sonic.Debug.lst Sonic.Debug.gen -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a")
end

-- Correct the ROM's header with a proper checksum and end-of-ROM value.
common.fix_header("Sonic.gen")

if debug then
	common.fix_header("Sonic.Debug.gen")
end

os.exit(exit_code, false)
