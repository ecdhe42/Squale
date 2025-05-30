lines_idx = []

offset = 0

for i in range(1, 19):
    with open("olipix" + str(i) + ".c", "r") as f:
        lines = f.readlines()

    print('BITMAP_OLIPIX' + str(i))
    status = 0
    data = []
#    lines_idx.append(data)
    for line in lines:
        if line == '{\n':
            status = 1
            continue
        elif line == '};\n':
            status = 2
            continue
        if status == 1:
            data += [int(val[2:], 16) for val in line.strip().strip(',').split(',')]
            line = line[1:-1].replace('0x', '$')
            if line.endswith(','):
                line = line[:-1]
            print('    FCB ' + line)

    idx = 1
    nb_lines = data[0] - 1
    line = 0
    frame_idx = []
    lines_idx.append(frame_idx)
    while line <= nb_lines:
        line += 1
        nb_vectors = data[idx]
        frame_idx.append(idx+offset)
        idx += 1
        while nb_vectors > 0:
            nb_vectors -= 1
            val = data[idx]
            idx += 1
            if val & 0xF0 == 0:
                idx += 1

    offset += len(data)


#for frame, indices in enumerate(lines_idx):
#    print('BITMAP_IDX' + str(frame+1))
#    for i in range(0, len(indices), 16):
#        row = ['{:04X}'.format(val) for val in indices[i:i+16]]
#        row = ['$'+val[0:2]+',$'+val[2:4] for val in row]
#        print('    FCB ' + ','.join(row))
