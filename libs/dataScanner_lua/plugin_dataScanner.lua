local Library = require "CoronaLibrary"

-- Create stub library for simulator
local lib = Library:new{ name='plugin.dataScanner', publisherId='com.platopus' }
-- Default implementations
local function defaultFunction()
	print( "WARNING: The '" .. lib.name .. "' library is not available on this platform." )
end

lib.show = defaultFunction
lib.hide = defaultFunction
lib.startScaning = defaultFunction
lib.stopScaning = defaultFunction


-- Return an instance
return lib
