--!strict
--!optimize 2

export type BitStream = {
	data: buffer,
	len: number,
	pos: number,
	offset: number,

	Bits: (self: BitStream, width: number) -> number,
	UInt: (self: BitStream, width: number) -> number,
	String: (self: BitStream, length: number) -> string,
	Align: (self: BitStream) -> ()
}

local readMap = {
	[1] = buffer.readu8,
	[2] = buffer.readu16,
	[4] = buffer.readu32
}

@native
local function Bits(self: BitStream, width: number): number
	if width == 0 then return 0 end

	local offset = self.offset
	local shift = offset + width

	local num = bit32.extract(buffer.readu32(self.data, self.pos), offset, width)
	self.pos += shift // 8
	self.offset = shift % 8
	return num
end

@native
local function UInt(self: BitStream, width: number): number
	if width == 0 then return 0 end

	local num = readMap[width](self.data, self.pos)
	self.pos += width
	return num
end

@native
local function String(self: BitStream, length: number): string
	local str = buffer.readstring(self.data, self.pos, length)
	self.pos += length
	return str
end

@native
local function Align(self: BitStream): ()
	if self.offset > 0 then
		self.pos += 1
		self.offset = 0
	end
end

local BitStream = {}

function BitStream.new(data: buffer): BitStream
	return {
		data = data,
		len = buffer.len(data),
		pos = 0,
		offset = 0,

		Bits = Bits,
		UInt = UInt,
		String = String,
		Align = Align
	}
end

return BitStream