--!strict
--!optimize 2

local PNGuin = script.Parent.Parent.Parent

local Parsing = PNGuin.Parsing
local BitStream = require(Parsing.BitStream)

type BitStream = BitStream.BitStream

type HuffmanNode = {
	[number]: HuffmanNode
} & {sym: number?}

export type HuffmanTree = {
	root: HuffmanNode,

	Read: (self: HuffmanTree, stream: BitStream) -> number
}

@native
local function Read(self: HuffmanTree, stream: BitStream): number
	local cur = self.root

	local pos = 0
	local chunk = stream:Bits(8)

	while true do
		local sym = cur.sym
		if sym then
			local shift = stream.offset - (8 - pos)
			stream.pos += shift // 8
			stream.offset = shift % 8
			return sym
		end

		cur = cur[bit32.extract(chunk, pos, 1)]
		if not cur then
			error("Invalid huffman code")
		end

		pos += 1
		if pos > 7 then
			pos = 0
			chunk = stream:Bits(8)
		end
	end
end

local HuffmanTree = {}

@native
function HuffmanTree.new(info: {number}): HuffmanTree
	local maxLen = 0
	local lenCount: {number} = {}

	for i, len in info do
		if len > 0 then
			lenCount[len] = (lenCount[len] or 0) + 1
			if len > maxLen then maxLen = len end
		end
	end

	local nextCode = table.create(maxLen, 0)

	local code = 0
	for len = 1, maxLen do
		code = (code + (lenCount[len - 1] or 0)) * 2^1
		nextCode[len] = code
	end

	local root: HuffmanNode = {}

	for sym, len in info do
		if len > 0 then
			local cur = nextCode[len]
			nextCode[len] += 1

			local node = root
			for i = len - 1, 0, -1 do
				local bit = bit32.extract(cur, i, 1)

				if not node[bit] then node[bit] = {} end
				node = node[bit]
			end

			node.sym = sym - 1
		end
	end

	return {
		root = root,

		Read = Read
	}
end

@native
function HuffmanTree.newRepeat(info: {number}): HuffmanTree
	local newInfo: {number} = {}

	for i = 1, #info - 2, 2 do
		local idxStart = info[i]
		local len = info[i + 1]
		local idxEnd = info[i + 2]

		for _ = idxStart, idxEnd - 1 do
			table.insert(newInfo, len)
		end
	end

	return HuffmanTree.new(newInfo)
end

return HuffmanTree