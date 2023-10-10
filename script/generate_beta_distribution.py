from scipy.special import betaincinv
from scipy.stats import beta as B

alpha = 3
beta = 3
precision = 1000
denominator = 1e4

numerators = []
denominators = []

def calculte(alpha, beta, randomWord):
    randomWord = randomWord % precision
    randomWord = randomWord * 1.0 / precision
    y = betaincinv(alpha, beta, x)
    y_numerator = int(y * denominator)
    y_denominator = int(denominator)
    return y_numerator, y_denominator

for x in range(0, precision + 1, 1):
    x /= precision
    y = betaincinv(alpha, beta, x)

    # 拆分为分子和分母
    y_numerator = int(y * denominator)
    y_denominator = int(denominator)
    numerators.append(y_numerator)
    denominators.append(y_denominator)
print(numerators)

# truncated_means = []
# for numerator in numerators:
#     end = numerator * 1.0 / denominator
#     if end == 0:
#         truncated_means.append(0)
#         continue
#     t_mean = B(alpha, beta, loc=0, scale=1).expect(lb=0,ub=end,conditional=True)
#     t_mean_int = int(t_mean * denominator)
#     truncated_means.append(t_mean_int)
# print(truncated_means)
    