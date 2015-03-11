--
-- tests/actions/vstudio/vc2010/test_user_file.lua
-- Verify handling of empty and non-empty .user files for VC'201x.
-- Copyright (c) 2015 Jason Perkins and the Premake project
--

	local suite = test.declare("vstudio_vs2010_user_file")
	local vc2010 = premake.vstudio.vc2010
	local project = premake.project


--
-- Setup
--

	local sln

	function suite.setup()
		_ACTION = "vs2010"
		sln = test.createsolution()
	end

	local function prepare()
		local prj = test.getproject(sln, 1)
		vc2010.generateUser(prj)
	end


--
-- If no debugger settings have been specified, then the .user
-- file should not be written at all.
--

	function suite.noOutput_onNoSettings()
		prepare()
		test.isemptycapture()
	end


--
-- If a debugger setting has been specified, output.
--

	function suite.doesOutput_onDebugSettings()
		debugcommand "bin/emulator.exe"
		prepare()
		test.hasoutput()
	end

