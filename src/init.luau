--!strict
--!native
--!optimize 2

local Types = require("@self/Types")
local ChunkStream = require("@self/Parsing/ChunkStream")
local ByteStream = require("@self/Parsing/ByteStream")
local Zlib = require("@self/Decoding/Zlib")
local Filter = require("@self/Decoding/Filter")

type PNGInfo = Types.PNGInfo

local PNGuin = {}

local function DecodeRGBA(self: PNGInfo): (buffer, number)
	local clock = os.clock()

	local filtered = Zlib.Decompress(self.IDAT)
	local pixelData = Filter.Unfilter(self, filtered)

	return pixelData, os.clock() - clock
end

--[=[
	Parses PNG data into `PNGInfo`

	### Example Usage:
	```lua
	local png -- Your PNG binary data

	local pngInfo = PNGuin.Extract(png)
	local pixelData, elapsed = pngInfo:DecodeRGBA()
	```

	@within PNGuin
	@function Extract

	@param input -- PNG binary data as a `buffer` or `string`

	@return PNGInfo -- Extracted information
]=]
function PNGuin.Extract(input: buffer | string): PNGInfo
	local info: PNGInfo = {
		IDAT = buffer.create(0),
		PLTE = buffer.create(0),
		tRNS = nil,

		width = 0,
		height = 0,

		bitDepth = 8,
		colorType = "Truecolor",
		hasAlpha = true,
		channels = 6,

		DecodeRGBA = DecodeRGBA
	}

	local data = if typeof(input) == "buffer" then input
		else buffer.fromstring(input)

	local stream = ByteStream.new(data)
	local chunkStream = ChunkStream.new(info, stream)

	local signature = stream:String(8)
	if signature ~= "\137PNG\r\n\26\n" then
		error("Invalid PNG signature")
	end

	while true do
		if stream.pos + 8 > stream.len then
			error("IEND chunk not found")
		end

		local chunkLen = stream:UInt(4, true)
		local chunkType = stream:String(4)

		if chunkType == "IEND" then break end
		chunkStream:Read(chunkType, chunkLen)
		stream.pos += 4
	end

	return info
end

return PNGuin