--!strict
--!optimize 2

export type ByteStream = {
	data: buffer,
	len: number,
	pos: number,

	UInt: (self: ByteStream, width: number, big: boolean?) -> number,
	String: (self: ByteStream, length: number) -> string,
}

local readMap = {
	[1] = buffer.readu8,
	[2] = buffer.readu16,
	[4] = buffer.readu32
}

@native
local function UInt(self: ByteStream, width: number, big: boolean?): number
	local num = readMap[width](self.data, self.pos)
	self.pos += width

	if big and width > 1 then
		return bit32.byteswap(bit32.lshift(num, (4 - width) * 8))
	end

	return num
end

@native
local function String(self: ByteStream, length: number): string
	local str = buffer.readstring(self.data, self.pos, length)
	self.pos += length
	return str
end

local ByteStream = {}

function ByteStream.new(data: buffer): ByteStream
	return {
		data = data,
		len = buffer.len(data),
		pos = 0,

		UInt = UInt,
		String = String
	}
end

return ByteStream