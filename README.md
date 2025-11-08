<div align="center">
	<a href="#"><img height="112" alt="PNGuin" src="https://raw.githubusercontent.com/LiterallyWize/PNGuin/refs/heads/main/assets/PNGuin.png"/></a>
</div>

<h2 align="center">
	<p>A relatively fast, pure Luau PNG library</p>
	<div>
		<a href="https://github.com/LiterallyWize/PNGuin/releases/latest"><img alt="GitHub Release"
			src="https://img.shields.io/github/v/release/LiterallyWize/PNGuin?style=flat&logo=robloxstudio&logoColor=ffffff&labelColor=5e81e0&color=4556a8"/>
		</a>
		<a href="https://github.com/LiterallyWize/PNGuin/wiki"><img alt="GitHub Wiki"
			src="https://img.shields.io/badge/wiki-wiki?style=flat&logo=gitbook&logoColor=ffffff&labelColor=5e81e0&color=4556a8"/>
		</a>
		<a href="https://github.com/LiterallyWize/PNGuin/blob/main/LICENSE"><img alt="GitHub License"
			src="https://img.shields.io/github/license/LiterallyWize/PNGuin?style=flat&labelColor=5e81e0"/>
		</a>
	</div>
	<p></p>
</h2>

Lightweight, performant, and memory-efficient Luau implementation of the PNG image format!

### What this library does:

<sup><sub><sub>🟢</sup></sub></sub>  Extracting all critical PNG chunks: `IHDR`, `PLTE` and `IDAT`

<sup><sub><sub>🟢</sup></sub></sub>  Decoding RGBA pixel data from PNGs of any bit depth and color type

<sup><sub><sub>🟢</sup></sub></sub>  Decoding simple transparency via the `tRNS` chunk

<sup><sub><sub>🟢</sup></sub></sub>  Modest error checking for invalid or corrupt PNG data

### What this library does...n't:

<sup><sub><sub>🔴</sup></sub></sub>  Encoding PNG data (planned)
 
<sup><sub><sub>🔴</sup></sub></sub>  Parsing chunks besides the ones listed above (planned)
 
<sup><sub><sub>🔴</sup></sub></sub>  Decoding interlaced PNGs (planned)
 
<sup><sub><sub>🔴</sup></sub></sub>  Decoding PNGs larger than ~1GB, this is due to [**Luau buffer limitations**](https://luau.org/library#buffer-library)

## Installation

### Using Roblox
`.rbxm` binaries can be downloaded and imported directly from the [**Releases**](https://github.com/LiterallyWize/PNGuin/releases/latest) page.

### Using [pesde](https://github.com/pesde-pkg/pesde)
[**PNGuin is available as a pesde package**](https://pesde.dev/packages/literallywize/pnguin), and can be installed using the following commands:
```bash
pesde add literallywize/pnguin
pesde install
```

#

### Documentation can be found on the [wiki](https://github.com/LiterallyWize/PNGuin/wiki)! <sub><a href="#"><img src="https://cdn.discordapp.com/emojis/1273196227814621224.webp?size=44" height="28" alt="loopThumbsUp" title="loopThumbsUp"/></a></sub>