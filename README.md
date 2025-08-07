<p align="center"> <img width="660" height="115" alt="PNGuin" src="https://github.com/user-attachments/assets/abfd8903-b8b0-490d-b29b-933d272b8ef6"/> </p>

## <p align="center"> *A reasonably fast PNG library, written for Roblox.* </p>

This is a lightweight Luau implementation of the PNG file format, built for performance and memory efficiency.
<br> *Please note that this library was made in Roblox, and will not run in a standalone Luau runtime by itself.*

.RBXM binaries can be found in [Releases](https://github.com/LiterallyWize/PNGuin/releases).
<br> The library can also be synced into Roblox Studio using [Rojo](https://github.com/rojo-rbx/rojo).

#

### What this library does:

<sup><sub><sub>🟢</sup></sub></sub>  Extracting all critical PNG chunks: `IHDR`, `PLTE` and `IDAT`

<sup><sub><sub>🟢</sup></sub></sub>  Decoding RGBA pixel data from PNGs of any bit depth and color type

<sup><sub><sub>🟢</sup></sub></sub>  Decoding simple transparency via the `tRNS` chunk

<sup><sub><sub>🟢</sup></sub></sub>  Modest error checking for invalid or corrupt PNG data

### What this library does...n't:

<sup><sub><sub>🔴</sup></sub></sub>  Encoding PNG data *(planned)*
 
<sup><sub><sub>🔴</sup></sub></sub>  Parsing chunks besides the ones listed above *(planned)*
 
<sup><sub><sub>🔴</sup></sub></sub>  Decoding interlaced PNGs *(in progress)*
 
<sup><sub><sub>🔴</sup></sub></sub>  Decoding PNGs larger than ~1GB, this is due to [Luau buffer limitations](https://luau.org/library#buffer-library)

#

### Usage Example:
```luau
local PNGuin = require(ReplicatedStorage.PNGuin)

-- A buffer or string containing your PNG file data
-- For example, this can be obtained from StudioService:PromptImportFile()
local image

-- Extract PNG metadata into PNGInfo (width, height, bitDepth, etc.)
local pngInfo = PNGuin.Extract(image)
print(pngInfo.width, pngInfo.height)

-- Decode PNGInfo into a buffer containing 32-bpp RGBA pixel data
-- This buffer can be written directly into an EditableImage to display the PNG
local pixelData = pngInfo:DecodeRGBA()
```

#

###### This project was not built using [Rojo](https://github.com/rojo-rbx/rojo), I have never used [Rojo](https://github.com/rojo-rbx/rojo), and I do not understand [Rojo](https://github.com/rojo-rbx/rojo). <br> However, I went out of my way to structure this repository for [Rojo](https://github.com/rojo-rbx/rojo) users. If you notice a compatibility issue with this project and [Rojo](https://github.com/rojo-rbx/rojo), please open an issue.
