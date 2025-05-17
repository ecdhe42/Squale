import xml.etree.ElementTree as ET

tree = ET.parse('temps_pourri.svg')
root = tree.getroot()

elts = root[0]
nb_elts = len(elts)

x1_arr = []
#x2_arr = []
y1_arr = []
#y2_arr = []
dx_arr = []
dy_arr = []
cmd_arr = []

x1_e_arr = []
y1_e_arr = []
dx_e_arr = []
dy_e_arr = []
cmd_e_arr = []

x1_m_arr = []
y1_m_arr = []
dx_m_arr = []
dy_m_arr = []
cmd_m_arr = []

color_arr = []

x1_arr_nb = []
x2_arr_nb = []
y1_arr_nb = []
y2_arr_nb = []
#dx_arr_nb = []
#dy_arr_nb = []

i = 1
for elt in elts[1:]:
    x1 = round(float(elt.get('x1')))
    x2 = round(float(elt.get('x2')))
    y1 = round(float(elt.get('y1')))
    y2 = round(float(elt.get('y2')))

#    print('  <line stroke="#000" fill="none" x2="{}" y2="{}" x1="{}" y1="{}" id="svg_{}" stroke-linejoin="undefined" stroke-linecap="undefined"/>'.format(x2, y2, x1, y1, i))
    i += 1
    
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
#    x2_arr.append('$'+hex(x2)[2:])
    y1_arr.append('$'+hex(y1)[2:])
#    y2_arr.append('$'+hex(y2)[2:])
    dx_arr.append('$'+hex(dx)[2:])
    dy_arr.append('$'+hex(dy)[2:])
    cmd_arr.append('$'+hex(cmd)[2:])

    x1_arr_nb.append(x1)
    x2_arr_nb.append(x2)
    y1_arr_nb.append(y1)
    y2_arr_nb.append(y2)
#    dx_arr_nb.append(dx)
#    dy_arr_nb.append(dy)

    if len(color_arr) < 4:
        color_arr.append('$1')
    else:
        color_arr.append('$6')

def get_segment(left, right):
    get_segment_enemy(left, right)
    get_segment_missile(left, right)

def get_segment_enemy(left, right):
    if (x1_arr_nb[left] != x1_arr_nb[right]) and (y1_arr_nb[left] != y1_arr_nb[right]):
        print("ERROR", left, right)
    if x1_arr_nb[left] == x1_arr_nb[right]:
        scale = (y2_arr_nb[left] - y2_arr_nb[right]) / (y1_arr_nb[left] - y1_arr_nb[right])
    else:
        scale = (x2_arr_nb[left] - x2_arr_nb[right]) / (x1_arr_nb[left] - x1_arr_nb[right])
#    print("Scale:", scale)

    for i in range(50):
        x1 = round(x1_arr_nb[left] + i*(x2_arr_nb[left] - x1_arr_nb[left]) / 58.0)
        x2 = round(x1_arr_nb[right] + (i+8)*(x2_arr_nb[right] - x1_arr_nb[right]) / 58.0)

        y1 = round(y1_arr_nb[left] + i*(y2_arr_nb[left] - y1_arr_nb[left]) / 58.0)
        y2 = round(y1_arr_nb[right] + (i+8)*(y2_arr_nb[right] - y1_arr_nb[right]) / 58.0)

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

        x1_e_arr.append('$'+hex(x1)[2:])
#        x2_arr.append('$'+hex(x2)[2:])
        y1_e_arr.append('$'+hex(y1)[2:])
#        y2_arr.append('$'+hex(y2)[2:])
        dx_e_arr.append('$'+hex(dx)[2:])
        dy_e_arr.append('$'+hex(dy)[2:])
        cmd_e_arr.append('$'+hex(cmd)[2:])

        x1 = round(x1_arr_nb[right] + i*(x2_arr_nb[right] - x1_arr_nb[right]) / 58.0)
        x2 = round(x1_arr_nb[left] + (i+8)*(x2_arr_nb[left] - x1_arr_nb[left]) / 58.0)

        y1 = round(y1_arr_nb[right] + i*(y2_arr_nb[right] - y1_arr_nb[right]) / 58.0)
        y2 = round(y1_arr_nb[left] + (i+8)*(y2_arr_nb[left] - y1_arr_nb[left]) / 58.0)

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

        x1_e_arr.append('$'+hex(x1)[2:])
#        x2_arr.append('$'+hex(x2)[2:])
        y1_e_arr.append('$'+hex(y1)[2:])
#        y2_arr.append('$'+hex(y2)[2:])
        dx_e_arr.append('$'+hex(dx)[2:])
        dy_e_arr.append('$'+hex(dy)[2:])
        cmd_e_arr.append('$'+hex(cmd)[2:])

def get_segment_missile(left, right):
    for i in range(49,-1,-1):
        x1 = (x1_arr_nb[left] + i*(x2_arr_nb[left] - x1_arr_nb[left]) / 58.0)
        x2 = (x1_arr_nb[right] + (i+8)*(x2_arr_nb[right] - x1_arr_nb[right]) / 58.0)

        y1 = (y1_arr_nb[left] + i*(y2_arr_nb[left] - y1_arr_nb[left]) / 58.0)
        y2 = (y1_arr_nb[right] + (i+8)*(y2_arr_nb[right] - y1_arr_nb[right]) / 58.0)

        x1 = round((x1+x2)/2.0) + (1 if x1 > x2 else -1)
        y1 = round((y1+y2)/2.0) + (1 if y1 > y2 else -1)
        x2 = round(x2)
        y2 = round(y2)

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

        x1_m_arr.append('$'+hex(x1)[2:])
#        x2_arr.append('$'+hex(x2)[2:])
        y1_m_arr.append('$'+hex(y1)[2:])
#        y2_arr.append('$'+hex(y2)[2:])
        dx_m_arr.append('$'+hex(dx)[2:])
        dy_m_arr.append('$'+hex(dy)[2:])
        cmd_m_arr.append('$'+hex(cmd)[2:])

        x1 = round(x1_arr_nb[right] + i*(x2_arr_nb[right] - x1_arr_nb[right]) / 58.0)
        x2 = round(x1_arr_nb[left] + (i+8)*(x2_arr_nb[left] - x1_arr_nb[left]) / 58.0)

        y1 = round(y1_arr_nb[right] + i*(y2_arr_nb[right] - y1_arr_nb[right]) / 58.0)
        y2 = round(y1_arr_nb[left] + (i+8)*(y2_arr_nb[left] - y1_arr_nb[left]) / 58.0)

        x1 = round((x1+x2)/2.0) + (1 if x1 > x2 else -1)
        y1 = round((y1+y2)/2.0) + (1 if y1 > y2 else -1)
        x2 = round(x2)
        y2 = round(y2)

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

        x1_m_arr.append('$'+hex(x1)[2:])
#        x2_arr.append('$'+hex(x2)[2:])
        y1_m_arr.append('$'+hex(y1)[2:])
#        y2_arr.append('$'+hex(y2)[2:])
        dx_m_arr.append('$'+hex(dx)[2:])
        dy_m_arr.append('$'+hex(dy)[2:])
        cmd_m_arr.append('$'+hex(cmd)[2:])

get_segment(0, 3)
get_segment(3, 6)
get_segment(6, 9)
get_segment(9, 12)
get_segment(12, 15)
get_segment(15, 18)
get_segment(18, 21)
get_segment(21, 24)
get_segment(24, 27)
get_segment(27, 30)
get_segment(30, 33)
get_segment(33, 36)
get_segment(36, 39)
get_segment(39, 42)
get_segment(42, 45)
get_segment(45, 0)

def print_array(label, a):
    print(label)
    for idx in range(0, len(a), 40):
        idx_last = min(idx+40, len(a))
        print('    FCB ' + ','.join(a[idx:idx_last]))

print_array('LINE_X1', x1_arr)
print_array('LINE_Y1', y1_arr)
print_array('LINE_DX', dx_arr)
print_array('LINE_DY', dy_arr)
print_array('LINE_CMD', cmd_arr)
print_array('LINE_COLOR', color_arr)

print_array('LINE_ENEMY_X1', x1_e_arr)
print_array('LINE_ENEMY_Y1', y1_e_arr)
print_array('LINE_ENEMY_DX', dx_e_arr)
print_array('LINE_ENEMY_DY', dy_e_arr)
print_array('LINE_ENEMY_CMD', cmd_e_arr)

print_array('LINE_MISSILE_X1', x1_m_arr)
print_array('LINE_MISSILE_Y1', y1_m_arr)
print_array('LINE_MISSILE_DX', dx_m_arr)
print_array('LINE_MISSILE_DY', dy_m_arr)
print_array('LINE_MISSILE_CMD', cmd_m_arr)

#print('LINE_X1')
#print('    FCB ' + ','.join(x1_arr))
#print('LINE_X2')
#print('    FCB ' + ','.join(x2_arr))
#print('LINE_Y1')
#print('    FCB ' + ','.join(y1_arr))
#print('LINE_Y2')
#print('    FCB ' + ','.join(y2_arr))
#print('LINE_DX')
#print('    FCB ' + ','.join(dx_arr))
#print('LINE_DY')
#print('    FCB ' + ','.join(dy_arr))
#print('LINE_CMD')
#print('    FCB ' + ','.join(cmd_arr))
#print('LINE_COLOR')
#print('    FCB ' + ','.join(color_arr))

#print()
#print(len(elts)-1, "vectors")
