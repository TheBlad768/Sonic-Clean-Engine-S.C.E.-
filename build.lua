#!/usr/bin/env lua

--------------
-- Settings --
--------------

-- Create the debug ROM.
local debug = false

---------------------
-- End of settings --
---------------------

-- Delete old files.
os.remove("Sonic.gen")

local common = require "AS.lua.common"

local compression = "kosinskiplus"

-- Assemble the ROM.
local message, abort = common.build_rom("Sonic", "Sonic", "", "-p=FF -z=0," .. compression .. ",Size_of_DAC_driver_guess,after", false, "https://github.com/sonicretro/skdisasm")

if message then
	exit_code = false
end

if abort then
	os.exit(exit_code, true)
end

-- Buld DEBUG ROM

if debug then
	local message, abort = common.build_rom("Sonic", "Sonic.Debug", "-D __DEBUG__ -OLIST Sonic.Debug.lst", "-p=FF -z=0," .. compression .. ",Size_of_DAC_driver_guess,after", false, "https://github.com/sonicretro/skdisasm")

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

os.execute(extra_tools.convsym .. " Sonic.lst RAM.asm -in as_lst -out asm -range FF0000 FFFFFF")

if debug then
	os.execute(extra_tools.convsym .. " Sonic.Debug.lst Sonic.Debug.gen -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a")

	os.execute(extra_tools.convsym .. " Sonic.Debug.lst RAM.asm -in as_lst -out asm -range FF0000 FFFFFF")
end

-- Correct the ROM's header with a proper checksum and end-of-ROM value.
common.fix_header("Sonic.gen")

if debug then
	common.fix_header("Sonic.Debug.gen")
end

-- copy ROM.
local os_name, arch_name = require "AS.lua.get_os_name".get_os_name()
local source = "Sonic.gen"
local destination = "_CD"

local command

if os_name == "Windows" then
    command = "copy " .. source .. " " .. destination
else
    command = "cp " .. source .. " " .. destination
end

os.execute(command)

if debug then
	local os_name, arch_name = require "AS.lua.get_os_name".get_os_name()
	local source = "Sonic.Debug.gen"
	local destination = "_CD"

	local command

	if os_name == "Windows" then
	    command = "copy " .. source .. " " .. destination
	else
	    command = "cp " .. source .. " " .. destination
	end

	os.execute(command)
end

os.exit(exit_code, false)
