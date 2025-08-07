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

	DecodeRGBA: (self: PNGInfo) -> (buffer, number)
}

export type ColorType = "Truecolor" | "Grayscale" | "Indexed"

return {}