field_modulus = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
desired_curve_order = 52435875175126190479447740508185965837690552500527637822603658699938581184513

Fp = GF(field_modulus)

E = EllipticCurve(Fp, [0, 4])

E_order = E.order()
assert E_order % desired_curve_order == 0
assert desired_curve_order.is_prime() is True
E_cofactor = E_order // desired_curve_order
Fr = GF(desired_curve_order)

R.<T> = PolynomialRing(Fp)
if not Fp(-1).is_square():
    print("# -1 is non-residue")
    non_residue = -1
    F2.<u> = Fp.extension(T^2-non_residue, 'u')
    for j in range(1,4):
        if not (u+j).is_square():
            quadratic_non_residue = u+j
            F12_equation = (T^6 - j)^2 - non_residue
            u_to_w = T^6 - j
            w_to_u = T + j
            break
else:
    print("Unknown")

# F12.<w> = Fp.extension(F12_equation)
# E12 = EllipticCurve(F12, [PARAM_A4, PARAM_A6])

E2 = EllipticCurve(F2, [0, 4 * quadratic_non_residue])

E2_order = E2.order()
assert E2_order % desired_curve_order == 0
E2_cofactor = E2_order // desired_curve_order

# find the s*G_1
G1 = E(0x0F99F411A5F6C484EC5CAD7B9F9C0F01A3D2BB73759BB95567F1FE4910331D32B95ED87E36681230273C9A6677BE3A69, 0x12978C5E13A226B039CE22A0F4961D329747F0B78350988DAB4C1263455C826418A667CA97AC55576228FC7AA77D33E5)
s_G1 = E(0x16C2385B2093CC3EDBC0F2257E8F23E98E775F8F6628767E5F4FC0E495285B95B1505F487102FE083E65DC8E9E3A9181, 0x0F4B73F63C6FD1F924EAE2982426FC94FBD03FCEE12D9FB01BAF52BE1246A14C53C152D64ED312494A2BC32C4A3E7F9A)

factor(E_order)
# 3 * 11^2 * 10177^2 * 859267^2 * 52437899^2 * 52435875175126190479447740508185965837690552500527637822603658699938581184513
factor(G1.order())
# 3 * 11 * 10177 * 859267 * 52437899 * 52435875175126190479447740508185965837690552500527637822603658699938581184513
# When the order of the subgroup can be factorized into smaller 
# prime numbers, the elements in the subgroup can easily be calculated 
# to the corresponding scalar elements by efficient algorithm: 
# [Pohlig–Hellman algorithm](https://en.wikipedia.org/wiki/Pohlig%E2%80%93Hellman_algorithm), 
# that is, cracking DLP.

# There are too many elements in the subgroup of G1, which is not 
# conducive to solving the elliptic curve discrete logarithm problem. 
# Now we need to eliminate the only large prime numbers 5243...4513(r) 
# in G1 order, see https://hackmd.io/@liquan/HJDvEvR5T

# r*G1's order will be $3 * 11 * 10177 * 859267 * 52437899$

r_G1 = desired_curve_order * G1
r_s_G1 = desired_curve_order * s_G1
# r*s*G1 must be in the subgroup generated by r*G1, as r*s*G1 = s*(r*G1)

factor(r_G1.order())
# 3 * 11 * 10177 * 859267 * 52437899

n_1 = 3 * 11 * 10177 * 859267 * 52437899
# 15132376222941642753

# We can use the sage's built-in discrete_log() function, which implements Pohlig–Hellman
discrete_log(r_s_G1,r_G1,operation='+')
# s_1 = 2335387132884273659
# s = 2335387132884273659 + k_1 * n_1
# If we try a brute force search now, the results will be poor because n_1 is small. Let's try to do the same thing with G_2


factor(E2_cofactor)
# 13^2 * 23^2 * 2713 * 11953 * 262069 * 402096035359507321594726366720466575392706800671181159425656785868777272553337714697862511267018014931937703598282857976535744623203249
# This is the cofactor of E2, not the order of E2.

# So we run into some trouble, there two large prime factor in E2's order
# bp = 402096035359507321594726366720466575392706800671181159425656785868777272553337714697862511267018014931937703598282857976535744623203249
# we need to eliminate both of them, r, bp.

bp = 402096035359507321594726366720466575392706800671181159425656785868777272553337714697862511267018014931937703598282857976535744623203249

G2_x = F2(0x1173F10AD9F2DBEE8B6C0BB2624B05D72EEC87925F5C3633E2C000E699A580B842D3F35AF1BE77517C86AEBCA1130AE4 + 0x0434043A97DA28EF7100AE559167FC613F057B85451476ABABB27CFF0238A32831A0B4D14BA83C4F97247C8AC339841F*u)
G2_y = F2(0x0BEBEC70446CB91BB3D4DC5C8412915E99D612D8807C950AB06BC41583F528FDA9F42EC0FE7CD2991638187EF44258D3+0x19528E3B5C90C73A7092BB9AFDC73F86C838F551CCD9DBBA5CC6244CF76AB3372193DBE5B62383FAAE728728D4C1E649*u)
G2 = E2(G2_x,G2_y)

s_G2 = E2(0x165830F15309C878BFE6DD55697860B8823C1AFBDADCC2EF3CD52B56D4956C05A099D52FE4545816830C525F5484A5FA+0x179E34EB67D9D2DD32B224CDBA57D4BB7CF562B4A3E33382E88F33882D91663B14738B6772BF53A24653CE1DD2BFE2FA*u, 0x150598FC4225B44437EC604204BE06A2040FD295A28230B789214B1B12BF9C9DAE6F3759447FD195E92E2B42E03B5006+0x12E23B19E117418C568D4FF05B7824E5B54673C3C08D8BCD6D8D107955287A2B075100A51C81EBA44BF5A1ABAD4764A8*u)
# G2.order() run too long to get the result, therefore, we need to 
# calculate it by hand, according to [Lagrange's theorem](https://en.wikipedia.org/wiki/Lagrange%27s_theorem_(group_theory))
# G2.order() 

factors = []
for i11 in [1,13,13*13]:
    for j11 in [1,23,23*23]:
        for k11 in [1,2713]:
            for l11 in [1,11953]:
                for m11 in [1,262069]:
                    for n11 in [1,bp]:
                        for o11 in [1, desired_curve_order]:
                            factors.append(i11*j11*k11*l11*m11*n11*o11)
factors.sort()
for i in factors:
    if i*G2 == E2(0):
        order = i
        print(i)
        break

# 53576194808460553217203172723474824808344883275353018929305633902963132938098184426089150766896967993227272192442055963012237813401673323498414509448806171002635876817216134661849632732818260738617639084599158761113588926055983
factor(order/desired_curve_order)
# 13 * 23 * 2713 * 11953 * 262069 * 402096035359507321594726366720466575392706800671181159425656785868777272553337714697862511267018014931937703598282857976535744623203249
    
# the G2's order = 13 * 23 * 2713 * 11953 * 262069 * bp * desired_curve_order

bp_r_G2 = bp * desired_curve_order * G2
bp_r_s_G2 = bp * desired_curve_order * s_G2

# bp_r_G2.order() runs too long to get result.

for i in factors:
    if i*bp_r_G2 == E2(0):
        order = i
        print(i)
        break
# 2541052003438559
factor(order)
# 13 * 23 * 2713 * 11953 * 262069
# 
# the order of bp_r_G2 is 13 * 23 * 2713 * 11953 * 262069
n_2 = 13 * 23 * 2713 * 11953 * 262069
 

discrete_log(bp_r_s_G2, bp_r_G2, 13 * 23 * 2713 * 11953 * 262069, operation='+')
# s_2 = 712318409117070

# s = s_2 + k_2 * n_2

s_1 = 2335387132884273659
s_2 = 712318409117070
n_1 = 15132376222941642753
n_2 = 2541052003438559
crt([s_1, s_2], [n_1, n_2])
# s = 5592216610550884993006174526481245
n_1*n_2