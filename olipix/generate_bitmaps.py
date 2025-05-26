for i in range(1, 19):
    with open("olipix" + str(i) + ".c", "r") as f:
        lines = f.readlines()

    print('BITMAP_OLIPIX' + str(i))
    status = 0
    for line in lines:
        if line == '{\n':
            status = 1
            continue
        elif line == '};\n':
            status = 2
            continue
        if status == 1:
            line = line[1:-1].replace('0x', '$')
            if line.endswith(','):
                line = line[:-1]
            print('    FCB ' + line)
