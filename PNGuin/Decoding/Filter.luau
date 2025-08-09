--!strict
--!optimize 2

local PNGuin = script.Parent.Parent

local Types = require(PNGuin.Types)

type PNGInfo = Types.PNGInfo

local converters = {
	Truecolor = @native function(info: PNGInfo, data: buffer): buffer
		local dataLen = buffer.len(data)

		local tRNS = info.tRNS
		local bitDepth = info.bitDepth
		local hasAlpha = info.hasAlpha
		local channels = info.channels

		local tr, tg, tb = 0, 0, 0
		if tRNS then
			tr, tg, tb =
				bit32.byteswap(buffer.readu16(tRNS, 0)),
				bit32.byteswap(buffer.readu16(tRNS, 2)),
				bit32.byteswap(buffer.readu16(tRNS, 4))
		end

		local output = buffer.create(info.width * info.height * 4)
		local outputPos = 0

		if bitDepth == 16 then
			channels *= 2

			local pos = 0
			while pos < dataLen do
				local r, g, b, a =
					bit32.byteswap(buffer.readu16(data, pos) * 2^16),
					bit32.byteswap(buffer.readu16(data, pos + 2) * 2^16),
					bit32.byteswap(buffer.readu16(data, pos + 4) * 2^16),
					if hasAlpha then bit32.byteswap(buffer.readu16(data, pos + 6) * 2^16) else 0xFFFF

				if tRNS and r == tr and g == tg and b == tb then
					a = 0
				end

				pos += channels
				r, g, b, a = r // 2^8, g // 2^8, b // 2^8, a // 2^8

				buffer.writeu32(output, outputPos,
					(r) + (g * 2^8) + (b * 2^16) + (a * 2^24)
				)
				outputPos += 4
			end
		else
			local pos = 0
			while pos < dataLen do
				local r, g, b, a =
					buffer.readu8(data, pos),
					buffer.readu8(data, pos + 1),
					buffer.readu8(data, pos + 2),
					if hasAlpha then buffer.readu8(data, pos + 3) else 0xFF

				if tRNS and r == tr and g == tg and b == tb then
					a = 0
				end

				pos += channels

				buffer.writeu32(output, outputPos,
					(r) + (g * 2^8) + (b * 2^16) + (a * 2^24)
				)
				outputPos += 4
			end
		end

		return output
	end,

	Grayscale = @native function(info: PNGInfo, data: buffer): buffer
		local dataLen = buffer.len(data)

		local tRNS = info.tRNS
		local bitDepth = info.bitDepth
		local hasAlpha = info.hasAlpha
		local channels = info.channels

		local tv = if tRNS then bit32.byteswap(buffer.readu16(tRNS, 0)) else 0

		local output = buffer.create(info.width * info.height * 4)
		local outputPos = 0

		if bitDepth == 16 then
			channels *= 2

			local pos = 0
			while pos < dataLen do
				local v, a =
					bit32.byteswap(buffer.readu16(data, pos) * 2^16),
					if hasAlpha then bit32.byteswap(buffer.readu16(data, pos + 2) * 2^16) else 0xFFFF

				if tRNS and v == tv then
					a = 0
				end

				pos += channels
				v, a = v // 2^8, a // 2^8

				buffer.writeu32(output, outputPos,
					(v) + (v * 2^8) + (v * 2^16) + (a * 2^24)
				)
				outputPos += 4
			end
		elseif bitDepth == 8 then
			local pos = 0
			while pos < dataLen do
				local v, a =
					buffer.readu8(data, pos),
					if hasAlpha then buffer.readu8(data, pos + 1) else 0xFF

				if tRNS and v == tv then
					a = 0
				end

				pos += channels

				buffer.writeu32(output, outputPos,
					(v) + (v * 2^8) + (v * 2^16) + (a * 2^24)
				)
				outputPos += 4
			end
		else
			local depthPos = 2^bitDepth
			local subShift = 2^8 // depthPos
			local subScale = (2^8 - 1) / (depthPos - 1)
			
			local pos = 0
			while pos < dataLen do
				local byte = buffer.readu8(data, pos)
				pos += 1

				for _ = 1, 8 // bitDepth do
					-- This calculation is Pissing me off...
					-- I'm the original        Starwalker
					local v = (byte // subShift % depthPos * subScale + 0.5) // 1
					byte *= depthPos
					local a = 0xFF

					if tRNS and v == tv then
						a = 0
					end

					buffer.writeu32(output, outputPos,
						(v) + (v * 2^8) + (v * 2^16) + (a * 2^24)
					)
					outputPos += 4
				end
			end
		end

		return output
	end,

	Indexed = @native function(info: PNGInfo, data: buffer): buffer
		local dataLen = buffer.len(data)

		local PLTE = info.PLTE
		local tRNS = info.tRNS
		local tRNSLen = if tRNS then buffer.len(tRNS) else 0
		local bitDepth = info.bitDepth

		local output = buffer.create(info.width * info.height * 4)
		local outputPos = 0

		if bitDepth == 8 then
			local pos = 0
			while pos < dataLen do
				local entry = buffer.readu8(data, pos)
				pos += 1

				local index = entry * 3
				local r, g, b, a =
					buffer.readu8(PLTE, index),
					buffer.readu8(PLTE, index + 1),
					buffer.readu8(PLTE, index + 2),
					if tRNS and entry < tRNSLen then buffer.readu8(tRNS, entry) else 0xFF

				buffer.writeu32(output, outputPos,
					(r) + (g * 2^8) + (b * 2^16) + (a * 2^24)
				)
				outputPos += 4
			end
		else
			local depthPos = 2^bitDepth
			local subShift = 2^8 // depthPos

			local pos = 0
			while pos < dataLen do
				local byte = buffer.readu8(data, pos)
				pos += 1

				for _ = 1, 8 // bitDepth do
					local entry = byte // subShift % depthPos
					byte *= depthPos

					local index = entry * 3
					local r, g, b, a =
						buffer.readu8(PLTE, index),
						buffer.readu8(PLTE, index + 1),
						buffer.readu8(PLTE, index + 2),
						if tRNS and entry < tRNSLen then buffer.readu8(tRNS, entry) else 0xFF

					buffer.writeu32(output, outputPos,
						(r) + (g * 2^8) + (b * 2^16) + (a * 2^24)
					)
					outputPos += 4
				end
			end
		end

		return output
	end
}

local Filter = {}

@native
function Filter.Unfilter(info: PNGInfo, data: buffer): buffer
	local width = info.width
	local height = info.height

	local bytesPerPixel = math.max(info.bitDepth * info.channels // 8, 1)
	local rowWidth = math.ceil(width * info.bitDepth * info.channels / 8)

	local output = buffer.create(rowWidth * height)

	local byte = 0
	local pos = 0

	for y = 1, height do
		local filterType = buffer.readu8(data, byte)
		byte += 1

		for i = 1, rowWidth do
			local x = buffer.readu8(data, byte)
			byte += 1

			local a = if i > bytesPerPixel
				then buffer.readu8(output, pos - bytesPerPixel)
				else 0

			local b = if y > 1
				then buffer.readu8(output, pos - rowWidth)
				else 0

			local c = if y > 1 and i > bytesPerPixel
				then buffer.readu8(output, pos - rowWidth - bytesPerPixel)
				else 0

			local val = 0

			if filterType == 0 then
				val = x
			elseif filterType == 1 then
				val = x + a
			elseif filterType == 2 then
				val = x + b
			elseif filterType == 3 then
				val = x + (a + b) // 2
			elseif filterType == 4 then
				local p = a + b - c
				local pa = math.abs(p - a)
				local pb = math.abs(p - b)
				local pc = math.abs(p - c)

				local pr = 
					if pa <= pb and pa <= pc then a
					elseif pb <= pc then b
					else c

				val = x + pr
			else
				error(string.format(
					"Unknown filter type (%d)", filterType
				))
			end

			buffer.writeu8(output, pos, val % 256)
			pos += 1
		end
	end

	return converters[info.colorType](info, output)
end

return Filter