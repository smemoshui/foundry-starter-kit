from scipy.special import betaincinv

alpha = 1
beta = 2
precision = 100

numerators = []
denominators = []

for x in range(0, precision, 1):
    x /= precision
    y = betaincinv(alpha, beta, x)

        # 拆分为分子和分母
    x_int = int(x * precision)
    y_numerator = int(y * 1e6)
    y_denominator = int(1e6)
    numerators.append(y_numerator)
    denominators.append(y_denominator)

print(numerators)
print(denominators)
    