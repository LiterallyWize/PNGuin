local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")

local PESDE_CONFIG_PATH = "pesde.toml"

local function writeVersion(version: string)
	local data = fs.readFile(PESDE_CONFIG_PATH)
	local config: {version: string} = serde.decode("toml", data)
	config.version = version

	fs.writeFile(PESDE_CONFIG_PATH, serde.encode("toml", config, true))
end

if #process.args == 0 then
	error("No version provided")
end

local version = process.args[1]
writeVersion(version)

print(string.format("Version updated to %s", version))

-- 1axen my goat