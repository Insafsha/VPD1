from math import sin

f = open('sin.csv', 'w')
for val in range(100):
    t = 0.1 * val
    y = sin(2 * t)
    f.write("{} {}\n".format(t, y))
f.close()
