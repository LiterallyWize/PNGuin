--!strict
--!optimize 2

local Types = require(script.Types)

local Parsing = script.Parsing
local ChunkStream = require(Parsing.ChunkStream)
local ByteStream = require(Parsing.ByteStream)

local Decoding = script.Decoding
local Zlib = require(Decoding.Zlib)
local Filter = require(Decoding.Filter)

type PNGInfo = Types.PNGInfo

local PNGuin = {}

-- Decodes IDAT chunks from PNGInfo.
-- Returns a buffer of RGBA color data, and time spent decoding.
@native
local function DecodeRGBA(self: PNGInfo): (buffer, number)
	local clock = os.clock()

	local filtered = Zlib.Decompress(self.IDAT)
	local data = Filter.Unfilter(self, filtered)

	return data, os.clock() - clock
end

-- Extracts metadata and IDAT chunks from PNG data.
-- Returns PNGInfo.
@native
function PNGuin.Extract(data: buffer | string): PNGInfo
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

	local data: buffer = if typeof(data) == "string"
		then buffer.fromstring(data)
		else data

	local stream = ByteStream.new(data)
	local chunks = ChunkStream.new(info, stream)

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
		chunks:Read(chunkType, chunkLen)
		stream.pos += 4
	end

	return info
end

return PNGuin