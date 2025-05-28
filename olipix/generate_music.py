notes = {
    "D3": [0xF3,0x05],
    "F3": [0x01,0x05],
    "A3": [0xF9,0x03],
    "A2": [0xF2,0x07],
    "C3": [0xAE,0x06],
    "E3": [0x4D,0x05],
    "G3": [0x75,0x04],
    "D2": [0xE7,0x0B],
    "F2": [0x02,0x0A]
}

partition = [
    'D3', 'F3', 'D3', 'F3', 'A3', 'F3', 'D3', 'F3',
    'D3', 'F3', 'D3', 'F3', 'A3', 'F3', 'D3', 'F3',

    'A2', 'C3', 'A2', 'C3', 'E3', 'C3', 'A2', 'C3',
    'A2', 'C3', 'A2', 'C3', 'E3', 'C3', 'A2', 'C3',

    'C3', 'E3', 'C3', 'E3', 'G3', 'E3', 'C3', 'E3',
    'C3', 'E3', 'C3', 'E3', 'G3', 'E3', 'C3', 'E3',

    'D2', 'F2', 'D2', 'F2', 'A2', 'F2', 'D2', 'F2',
    'D2', 'F2', 'D2', 'F2', 'A2', 'F2', 'D2', 'F2'
    ]

def parse():
    for note in partition:
        pitchA = notes[note]
        val = int((pitchA[1]*256 + pitchA[0])/2)
        pitchB = [0xFF, 0x0F]
        pitchC = [0,0]
        volA = 10
        volB = 10
        volC = 0
        noise = 0
        filters = 0xF8
        envelope = 19
        duration = [0, 0xA7]
        regs  = pitchA + pitchB + pitchC + [noise] + [filters] + [volA] + [volB] + [volC] + duration + [envelope]
        regs_str = ['${:02X}'.format(reg) for reg in regs]
        print('    FCB ' + ','.join(regs_str))

parse()
