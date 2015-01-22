import math

g = 1.6		# freefall acceleration, m/(s*s)
R = 1738000 # planet radius, m
c = 3660	# reactive gas speed, m/s
LS = 3600	# ship's time limit, s
A = 29.4	# ship's max acceleration, m/(s*s)
Ms = 2250	# ship's empty mass, kg
Mf = 3500	# ship's fuel mass, kg
Lx = 1		# orbital/coord mode switch

r = R + 100	# distance between ship & planet center, m

h = r - R		# distance between ship & planet surface, m

a = 0
alpha = 0
t = 0 

v = 0 # ship's horisontal speed, m/s
u = 0 # ship's vertical speed, m/s

L = 0 # distance passed by ship, m
x = 0 # ship's current coord

gamma = 0 # angle of deflection from vertical
dt = 1 # time per tick, s

def render():
	print "timestamp: ", t, "height: ", h, "length: ", L
	
def calculate():
	global R
	global r
	global g
	global v
	global u
	global gamma
	global alpha
	global L
	global x
	global t
	global h
	
	ay = a * math.cos(alpha) - math.pow(R / r, 2) * g + v * v / r
	ax = a * math.sin(alpha) - u * v / r
	
	u_new = u + ay * t
	v_new = v + ax * t
	r_new = r + ((u_new + u) / 2) * t
	gamma_new = gamma + (v_new + v) * t * 90 / (math.pi * r)
	h = r_new - R
	x = 2 * math.pi * R * gamma / 360
	L_new = L + (v_new + v) * (t / 2)
	
	u = u_new
	v = v_new
	r = r_new
	gamma = gamma_new
	L = L_new
	print "ay = ", ay, "ax = ", ax
	print "u = ", u, "v = ", v
	print "L =", L, "x = ", x
	print "r = ", r, "h = ", h

while h >= 0:
	render()
	
	a = 1
	alpha = 0
	t += dt
	if a < 0 or a > A or t <= 0:
		print "Something is wrong"
	
	dm = a * (Ms + Mf) * t / c
	
	if dm < Mf:
		dm = Mf
		a = dm * c / ((Ms + Mf) * t)
	
	calculate()

while h != 0:
	t = math.fabs(h * t) / (2* h)
	calculate()
