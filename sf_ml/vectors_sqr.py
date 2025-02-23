import numpy as np
import time

# Large NumPy array
v = np.random.rand(10**6)

# Timing v ** 2
start = time.time()
v ** 2
print("Exponentiation (**):", time.time() - start)

# Timing v * v
start = time.time()
v * v
print("Multiplication (*):", time.time() - start)

# Timing np.square(v)
start = time.time()
np.square(v)
print("np.square:", time.time() - start)

# 4. То же про скалярное произведение

import numpy as np
import time

N = 1000  # Matrix size for 2D operations
M = 10**6  # Size for 1D dot product test

# Generate random data
A = np.random.rand(N, N)
B = np.random.rand(N, N)

v1 = np.random.rand(M)
v2 = np.random.rand(M)

# @ operator
start = time.time()
A @ B
print("@ operator:", time.time() - start)

# np.dot(A, B)
start = time.time()
np.dot(A, B)
print("np.dot:", time.time() - start)

# A.dot(B)
start = time.time()
A.dot(B)
print("A.dot(B):", time.time() - start)

# np.einsum('ij,jk->ik', A, B)
start = time.time()
np.einsum('ij,jk->ik', A, B)
print("np.einsum:", time.time() - start)

# np.tensordot(A, B, axes=1)
start = time.time()
np.tensordot(A, B, axes=1)
print("np.tensordot:", time.time() - start)

# Python list comprehension (1D dot product)
start = time.time()
sum(i * j for i, j in zip(v1, v2))
print("Python list comprehension (1D):", time.time() - start)