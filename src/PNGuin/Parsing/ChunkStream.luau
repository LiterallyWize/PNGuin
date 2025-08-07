--!strict
--!optimize 2

local PNGuin = script.Parent.Parent

local Types = require(PNGuin.Types)

local Parsing = PNGuin.Parsing
local ByteStream = require(Parsing.ByteStream)

type PNGInfo = Types.PNGInfo
type ColorType = Types.ColorType
type ByteStream = ByteStream.ByteStream

export type ChunkStream = {
	info: PNGInfo,
	stream: ByteStream,

	Read: (self: ChunkStream, chunkType: string, length: number) -> ()
}

local bitDepthMap = {
	[0] = {1, 2, 4, 8, 16},
	[2] = {8, 16},
	[3] = {1, 2, 4, 8},
	[4] = {8, 16},
	[6] = {8, 16},
}

local chunks = {
	IHDR = @native function(self: ChunkStream, chunkLen: number): ()
		if chunkLen ~= 13 then 
			error(string.format(
				"Invalid IHDR chunk length: Expected 13 bytes, got %d",
				chunkLen
			))
		end

		local info = self.info
		local stream = self.stream

		local width = stream:UInt(4, true)
		local height = stream:UInt(4, true)
		if width == 0 or height == 0 then
			error("Invalid image dimensions")
		end

		local bitDepth = stream:UInt(1)
		local colorSpace = stream:UInt(1)
		if not bitDepthMap[colorSpace] then
			error("Invalid color space")
		elseif not table.find(bitDepthMap[colorSpace], bitDepth) then
			error("Invalid bit depth")
		end

		local colorType: ColorType =
			if colorSpace % 4 == 0 then "Grayscale"
			elseif colorSpace == 3 then "Indexed"
			else "Truecolor"

		local hasAlpha = colorSpace > 3

		local channels = 1
		if colorType == "Truecolor" then channels += 2 end
		if hasAlpha then channels += 1 end

		local compMethod = stream:UInt(1)
		if compMethod > 0 then
			error(string.format(
				"Invalid compression method (%d): Only DEFLATE (0) is supported",
				compMethod
			))
		end

		local filterMethod = stream:UInt(1)
		if filterMethod > 0 then
			error(string.format(
				"Invalid filter method (%d): Only adaptive filtering (0) is supported",
				filterMethod
			))
		end

		local interlacing = stream:UInt(1)
		if interlacing > 0 then
			error("Interlacing is not supported")
		end

		info.width = width
		info.height = height

		info.bitDepth = bitDepth
		info.colorType = colorType
		info.hasAlpha = hasAlpha
		info.channels = channels
	end,

	PLTE = @native function(self: ChunkStream, chunkLen: number): ()
		if chunkLen % 3 ~= 0 then 
			error(string.format(
				"Invalid PLTE chunk length: %d is not divisible by 3",
				chunkLen
			))
		end

		local info = self.info
		local stream = self.stream

		info.PLTE = buffer.fromstring(stream:String(chunkLen))
	end,

	tRNS = @native function(self: ChunkStream, chunkLen: number): ()
		local info = self.info
		local stream = self.stream

		info.tRNS = buffer.fromstring(stream:String(chunkLen))
	end,

	IDAT = @native function(self: ChunkStream, chunkLen: number): ()
		local info = self.info
		local stream = self.stream

		local IDAT: {string} = {stream:String(chunkLen)}

		while true do
			stream.pos += 4

			local length = stream:UInt(4, true)
			if stream:String(4) ~= "IDAT" then
				stream.pos -= 12
			break end

			table.insert(IDAT, stream:String(length))
		end

		info.IDAT = buffer.fromstring(table.concat(IDAT))
	end,
}

@native
local function Read(self: ChunkStream, chunkType: string, chunkLen: number): ()
	local func = chunks[chunkType]
	if not func then
		self.stream.pos += chunkLen
	else func(self, chunkLen) end
end

local ChunkStream = {}

function ChunkStream.new(info: PNGInfo, stream: ByteStream): ChunkStream
	return {
		info = info,
		stream = stream,

		Read = Read
	}
end

return ChunkStream