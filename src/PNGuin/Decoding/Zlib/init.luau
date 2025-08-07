--!strict
--!optimize 2

local PNGuin = script.Parent.Parent

local Parsing = PNGuin.Parsing
local BitStream = require(Parsing.BitStream)

local HuffmanTree = require(script.HuffmanTree)
local Parser = require(script.Parser)

type BitStream = BitStream.BitStream
type HuffmanTree = HuffmanTree.HuffmanTree
type Parser = Parser.Parser

local lenBase = {
	3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 
	35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258}

local lenExtra = {
	0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 
	3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0}

local distBase = {
	1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 
	257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577}

local distExtra = {
	0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 
	7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13}

local clenOrder = {16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15}

@native
local function buildDynamicTrees(stream: BitStream): (HuffmanTree, HuffmanTree)
	local hlit = stream:Bits(5) + 257
	local hdist = stream:Bits(5) + 1
	local hclen = stream:Bits(4) + 4

	local codeLens: {number} = table.create(19, 0)
	for i = 1, hclen do
		codeLens[clenOrder[i] + 1] = stream:Bits(3)
	end

	local clenTree = HuffmanTree.new(codeLens)

	local totalCodes = hlit + hdist
	local symLens = table.create(totalCodes, 0)

	local i = 1
	while i <= totalCodes do
		local sym = clenTree:Read(stream)
		local val = 0
		local rep = 1

		if sym <= 15 then
			val = sym
		elseif sym == 16 then
			rep = stream:Bits(2) + 3
			val = symLens[i - 1]
		elseif sym == 17 then
			rep = stream:Bits(3) + 3
			val = 0
		elseif sym == 18 then
			rep = stream:Bits(7) + 11
			val = 0
		end

		for _ = 1, rep do
			symLens[i] = val
			i += 1
		end
	end

	local litTree = HuffmanTree.new(
		table.move(symLens, 1, hlit, 1, table.create(hlit, 0))
	)
	local distTree = HuffmanTree.new(
		table.move(symLens, hlit + 1, totalCodes, 1, table.create(hdist, 0))
	)

	return litTree, distTree
end

@native
local function parseCompressed(self: Parser, litTree: HuffmanTree, distTree: HuffmanTree): ()
	local windowSize = self.windowSize
	local stream = self.stream

	while true do
		local sym = litTree:Read(stream)

		if sym == 256 then
			break
		elseif sym < 256 then
			self:ToOutput(sym)
			self:ToWindow(sym)
		else
			local idxLen = sym - 256
			local len = lenBase[idxLen] + stream:Bits(lenExtra[idxLen])

			local idxDist = distTree:Read(stream) + 1
			local dist = distBase[idxDist] + stream:Bits(distExtra[idxDist])

			local pos = (self.windowPos - dist) % windowSize

			local chunk = math.min(dist, len)
			if chunk > 0 then
				local val = self:ReadWindowBulk(pos, chunk)
				self:ToOutputBulk(val)
				self:ToWindowBulk(val)
			end

			if chunk >= len then continue end

			for i = chunk + 1, len do
				pos = (self.windowPos - dist) % windowSize
				local val = self:ReadWindow(pos)

				self:ToOutput(val)
				self:ToWindow(val)
			end
		end
	end
end

@native
local function parseBlocks(self: Parser): buffer
	local litFixed = HuffmanTree.newRepeat({0, 8, 144, 9, 256, 7, 280, 8, 288})
	local distFixed = HuffmanTree.newRepeat({0, 5, 32})

	local stream = self.stream

	while true do
		local read = stream:Bits(1 + 2)

		local final = read % 2^1
		local blockType = read // 2^1

		if blockType > 2 then
			error(string.format(
				"Invalid block type (%d)",
				blockType
			))
		elseif blockType == 0 then
			stream:Align()
			local len = stream:UInt(2 + 2) % 2^16

			local block = stream:String(len)
			self:ToOutputBulk(block)
			self:ToWindowBulk(block)
		else
			local litTree, distTree = litFixed, distFixed
			if blockType == 2 then
				litTree, distTree = buildDynamicTrees(stream)
			end

			parseCompressed(self, litTree, distTree)
		end

		if final == 1 then break end
	end

	return self:Finalize()
end

local Zlib = {}

@native
function Zlib.Decompress(data: buffer): buffer
	local clock = os.clock()
	local stream = BitStream.new(data)

	local cmf = stream:UInt(1)

	local compMethod = cmf % 2^4
	if compMethod ~= 8 then
		error(string.format(
			"Invalid Zlib compression method (%d): Only DEFLATE (8) is supported",
			compMethod
		))
	end

	local compInfo = (cmf // 2^4) % 2^4
	if compInfo > 7 then
		error(string.format(
			"Invalid Zlib window size: Expected <32KB, got %dKB",
			2^(compInfo + 8) // 1000
		))
	end

	local flg = stream:UInt(1)

	if (cmf * 2^8 + flg) % 31 ~= 0 then
		error("Invalid Zlib header: CMF+FLG checksum mismatch")
	end

	if (flg // 2^5) % 2^1 ~= 0 then
		error("Invalid Zlib header: preset dictionary is not supported")
	end

	return parseBlocks(
		Parser.new(stream, 2^(compInfo + 8))
	)
end

return Zlib