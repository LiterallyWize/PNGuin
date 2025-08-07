<p align="center"> <img width="660" height="115" alt="PNGuin" src="https://github.com/user-attachments/assets/abfd8903-b8b0-490d-b29b-933d272b8ef6"/> </p>

## <p align="center"> *A reasonably fast and lightweight PNG decoder, written for Roblox.* </p>

This is a Luau implementation of the PNG file format made in Roblox, built for speed and minimal memory usage.

### What this library *does* do:
- Extracting **IHDR**, **PLTE**, **tRNS** and **IDAT** chunks from PNG data
- Decoding RGBA pixel data from PNGs of any bit depth and color type, including **simple transparency (tRNS)**
- Modest error checking for invalid PNG data

### What this library (currently) *doesn't* do:
- Encoding PNG data
- Decoding interlaced PNGs (being worked on)
- Decoding chunks and metadata outside of those listed above
- Decoding PNGs larger than 1GB in size before or after decompression ([Luau buffers have a size limit](https://luau.org/library#buffer-library))
