local process = require("@lune/process")

local BUILD_DIR = "build"

local clock = os.clock()
process.exec("rojo", {"build", "--output", `{BUILD_DIR}/PNGuin.rbxm`})

print(string.format("Build completed in %.2f seconds", os.clock() - clock))