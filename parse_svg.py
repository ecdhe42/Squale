import xml.etree.ElementTree as ET

tree = ET.parse('temps_pourri.svg')
root = tree.getroot()

elts = root[0]
nb_elts = len(elts)

x1_arr = []
x2_arr = []
y1_arr = []
y2_arr = []
dx_arr = []
dy_arr = []
cmd_arr = []
color_arr = []

for elt in elts[1:]:
    x1 = round(float(elt.get('x1')))
    x2 = round(float(elt.get('x2')))
    y1 = round(float(elt.get('y1')))
    y2 = round(float(elt.get('y2')))
    
    cmd = 0x11
    if x1 > x2:
        cmd |= 2
        dx = x1-x2
    else:
        dx = x2-x1
    
    if y1 > y2:
        cmd |= 4
        dy = y1-y2
    else:
        dy = y2-y1

    x1_arr.append('$'+hex(x1)[2:])
    x2_arr.append('$'+hex(x2)[2:])
    y1_arr.append('$'+hex(y1)[2:])
    y2_arr.append('$'+hex(y2)[2:])
    dx_arr.append('$'+hex(dx)[2:])
    dy_arr.append('$'+hex(dy)[2:])
    cmd_arr.append('$'+hex(cmd)[2:])
    if len(color_arr) < 4:
        color_arr.append('$1')
    else:
        color_arr.append('$6')

print('LINE_X1')
print('    FCB ' + ','.join(x1_arr))
print('LINE_X2')
print('    FCB ' + ','.join(x2_arr))
print('LINE_Y1')
print('    FCB ' + ','.join(y1_arr))
print('LINE_Y2')
print('    FCB ' + ','.join(y2_arr))
print('LINE_DX')
print('    FCB ' + ','.join(dx_arr))
print('LINE_DY')
print('    FCB ' + ','.join(dy_arr))
print('LINE_CMD')
print('    FCB ' + ','.join(cmd_arr))
print('LINE_COLOR')
print('    FCB ' + ','.join(color_arr))

print()
print(len(cmd_arr), "vectors")
