import sys
n = len(sys.argv)
if n < 2:
    print("Usage: " + sys.argv[0] + " [Binary file]")
    quit()

filename = sys.argv[1]

with open("bootloader.BIN", "rb") as f:
    data_boot = f.read()

with open(filename, "rb") as f:
    data = f.read()

padding0 = 256 - len(data_boot)
padding1 = 32768 - 256 - len(data)
data_rom = data_boot + (b'\xff' * padding0) + data + (b'\xff' * padding1)

last_period_index = filename.rfind(".")
rom_filename = filename[:last_period_index] + ".rom"

with open(rom_filename, "wb") as f:
    f.write(data_rom)
