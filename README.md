<p align="center"> <img width="660" height="115" alt="PNGuin" src="https://github.com/user-attachments/assets/abfd8903-b8b0-490d-b29b-933d272b8ef6"/> </p>

## <p align="center"> *A reasonably fast and lightweight PNG library, written for Roblox.* </p>

This is a Luau implementation of the PNG file format, built for speed and minimal memory usage.
<br> *Please note that this project was made in Roblox, and will not run in standalone Luau by itself.*

### What this library does:

<sup><sub><sub>🟢</sup></sub></sub>  Extracting all critical PNG chunks; `IHDR`, `PLTE` and `IDAT`

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
-- wait where's the example
```

#

###### This project was not built using [Rojo](https://github.com/rojo-rbx/rojo), I have never used [Rojo](https://github.com/rojo-rbx/rojo), and I do not understand [Rojo](https://github.com/rojo-rbx/rojo). <br> However, I went out of my way to structure this repository for [Rojo](https://github.com/rojo-rbx/rojo) users. If you notice a compatibility issue with this project and [Rojo](https://github.com/rojo-rbx/rojo), please open an issue.
