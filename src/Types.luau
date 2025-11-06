--!strict
--!optimize 2

export type PNGInfo = {
	IDAT: buffer,
	PLTE: buffer,
	tRNS: buffer?,

	width: number,
	height: number,

	bitDepth: number,
	colorType: ColorType,
	hasAlpha: boolean,
	channels: number,

	--[=[
		Decodes IDAT chunks into (RGBA) pixel data

		@within PNGInfo

		@return buffer -- Pixel data
		@return number -- Time taken to decode in seconds
	]=]
	DecodeRGBA: (self: PNGInfo) -> (buffer, number)
}

export type ColorType = "Truecolor" | "Grayscale" | "Indexed"

return {}