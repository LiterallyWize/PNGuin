--!strict
--!optimize 2

local PNGuin = script.Parent.Parent

local Parsing = PNGuin.Parsing
local BitStream = require(Parsing.BitStream)

type BitStream = BitStream.BitStream

export type Parser = {
	_output: buffer,
	_outputPos: number,
	_outputChunks: {buffer},

	window: buffer,
	windowPos: number,
	windowSize: number,

	stream: BitStream,

	ToOutput: (self: Parser, val: number) -> (),
	ToOutputBulk: (self: Parser, val: string) -> (),
	ToWindow: (self: Parser, val: number) -> (),
	ToWindowBulk: (self: Parser, val: string) -> (),
	ReadWindow: (self: Parser, pos: number) -> number,
	ReadWindowBulk: (self: Parser, pos: number, len: number) -> string,

	Finalize: (self: Parser) -> buffer
}

@native
local function ToOutput(self: Parser, val: number): ()
	local output = self._output
	local outputPos = self._outputPos
	local windowSize = self.windowSize

	buffer.writeu8(output, outputPos, val)

	if outputPos + 1 == windowSize then
		local outputChunks = self._outputChunks
		table.insert(outputChunks, output)

		local outputNew = buffer.create(windowSize)
		self._output = outputNew
		self._outputPos = 0
	else
		self._outputPos += 1
	end
end

@native
local function ToOutputBulk(self: Parser, val: string): ()
	local output = self._output
	local outputPos = self._outputPos
	local windowSize = self.windowSize

	local len = #val

	if outputPos + len >= windowSize then
		local split = windowSize - outputPos
		buffer.writestring(output, outputPos, val, split)

		local outputChunks = self._outputChunks
		table.insert(outputChunks, output)

		local outputNew = buffer.create(windowSize)
		self._output = outputNew

		buffer.writestring(outputNew, 0, val:sub(split + 1), len - split)
		self._outputPos = len - split
	else
		buffer.writestring(output, outputPos, val, len)
		self._outputPos += len
	end
end

@native
local function ToWindow(self: Parser, val: number): ()
	local window = self.window
	local windowPos = self.windowPos
	local windowSize = self.windowSize

	buffer.writeu8(window, windowPos, val)
	if windowPos + 1 == windowSize then
		self.windowPos = 0
	else
		self.windowPos += 1
	end
end

@native
local function ToWindowBulk(self: Parser, val: string): ()
	local window = self.window
	local windowPos = self.windowPos
	local windowSize = self.windowSize

	local len = #val

	if windowPos + len >= windowSize then
		local split = windowSize - windowPos

		buffer.writestring(window, windowPos, val, split)
		buffer.writestring(window, 0, val:sub(split + 1), len - split)
		self.windowPos = len - split
	else
		buffer.writestring(window, windowPos, val, len)
		self.windowPos += len
	end
end

@native
local function ReadWindow(self: Parser, pos: number): number
	return buffer.readu8(self.window, pos)
end

@native
local function ReadWindowBulk(self: Parser, pos: number, len: number): string
	local window = self.window
	local windowSize = self.windowSize

	if pos + len > windowSize then
		local split = windowSize - pos

		return buffer.readstring(window, pos, split)
			.. buffer.readstring(window, 0, len - split)
	else
		return buffer.readstring(self.window, pos, len)
	end
end

@native
local function Finalize(self: Parser): buffer
	local output = self._output
	local outputPos = self._outputPos
	local outputChunks = self._outputChunks
	local windowSize = self.windowSize

	local result = buffer.create(#outputChunks * windowSize + outputPos)
	for i, chunk in outputChunks do
		buffer.copy(result, (i - 1) * windowSize, chunk, 0, windowSize)
	end

	if outputPos > 0 then
		buffer.copy(result, #outputChunks * windowSize, output, 0, outputPos)
	end

	return result
end

local Parser = {}

function Parser.new(stream: BitStream, windowSize: number): Parser
	return {
		_output = buffer.create(windowSize),
		_outputPos = 0,
		_outputChunks = {},

		window = buffer.create(windowSize),
		windowPos = 0,
		windowSize = windowSize,

		stream = stream,

		ToOutput = ToOutput,
		ToOutputBulk = ToOutputBulk,
		ToWindow = ToWindow,
		ToWindowBulk = ToWindowBulk,
		ReadWindow = ReadWindow,
		ReadWindowBulk = ReadWindowBulk,

		Finalize = Finalize
	}
end

return Parser