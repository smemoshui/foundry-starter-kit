from scipy.special import betaincinv

alpha = 3
beta = 3
precision = 1000
denominator = 1e4

numerators = []
denominators = []

for x in range(0, precision, 1):
    x /= precision
    y = betaincinv(alpha, beta, x)

        # 拆分为分子和分母
    x_int = int(x * precision)
    y_numerator = int(y * denominator)
    y_denominator = int(denominator)
    numerators.append(y_numerator)
    denominators.append(y_denominator)

print(numerators)
print(denominators)
    