<div align="center">
	<a href="#"><img height="112" alt="PNGuin" src="assets/PNGuin.png"/></a>
</div>

## <p align="center"> A relatively fast PNG library written in Luau </p>

Lightweight, performant, and memory-efficient Luau implementation of the PNG image format.
<br>
\+ Compatible with [Lune](https://github.com/lune-org/lune)!

### What this library does:

<sup><sub><sub>🟢</sup></sub></sub>  Extracting all critical PNG chunks: `IHDR`, `PLTE` and `IDAT`

<sup><sub><sub>🟢</sup></sub></sub>  Decoding RGBA pixel data from PNGs of any bit depth and color type

<sup><sub><sub>🟢</sup></sub></sub>  Decoding simple transparency via the `tRNS` chunk

<sup><sub><sub>🟢</sup></sub></sub>  Modest error checking for invalid or corrupt PNG data

### What this library does...n't:

<sup><sub><sub>🔴</sup></sub></sub>  Encoding PNG data (planned)
 
<sup><sub><sub>🔴</sup></sub></sub>  Parsing chunks besides the ones listed above (planned)
 
<sup><sub><sub>🔴</sup></sub></sub>  Decoding interlaced PNGs (planned)
 
<sup><sub><sub>🔴</sup></sub></sub>  Decoding PNGs larger than ~1GB, this is due to [Luau buffer limitations](https://luau.org/library#buffer-library)

## Get Started

`.rbxm` binaries can be downloaded from [Releases](https://github.com/LiterallyWize/PNGuin/releases).

Alternatively, this can be installed as a [Wally](https://github.com/UpliftGames/wally) package with `wally install literallywize/pnguin`


### Usage Example:
```luau
local PNGuin = require(path.to.PNGuin)

local png -- Your PNG binary data

local pngInfo = PNGuin.Extract(png)
local pixelData, elapsed = pngInfo:DecodeRGBA()
```