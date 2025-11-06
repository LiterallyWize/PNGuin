local process = require("@lune/process")

local INIT_PATH = "src/init.luau"

local BUNDLE_PATH = "bin/PNGuin.luau"
local RBXM_PATH = "bin/PNGuin.rbxm"

local function buildPesde()
	local result = process.exec("darklua", {"process", INIT_PATH, BUNDLE_PATH})
	assert(result.ok, result.stderr)
end

local function buildRBXM()
	local result = process.exec("rojo", {"build", "--output", RBXM_PATH})
	assert(result.ok, result.stderr)
end

local clock = os.clock()

buildPesde()
buildRBXM()

print(string.format("Build completed in %.2fs", os.clock() - clock))