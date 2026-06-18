#include <stdint.h>
#include <stdio.h>

typedef uint64_t fe64[4];

/* mask63 = 2^63 - 1, required external symbol referenced by gf_p25519_mul.s */
const uint64_t mask63 = 0x7fffffffffffffffULL;

void gfp25519mul(fe64 z, const fe64 x, const fe64 y);
void gfp25519reduce(fe64 z);

static void print_hex(const char *name, const fe64 v) {
    /* big-endian display: limb 3 down to limb 0 */
    printf("%s = 0x", name);
    for (int i = 3; i >= 0; i--) printf("%016lx", v[i]);
    printf("\n");
}

static void run_test(const char *label, const fe64 x, const fe64 y) {
    fe64 z;
    gfp25519mul(z, x, y);
    printf("=== %s ===\n", label);
    print_hex("x", x);
    print_hex("y", y);
    print_hex("z (mul)   ", z);
    gfp25519reduce(z);
    print_hex("z (reduce)", z);
    printf("\n");
}

int main(void) {
    /* test 1: mul output in [0, p) - already canonical, reduce is a no-op */
    fe64 x1 = {
        0xdeadbeefcafebabeULL,
        0x1234567890abcdefULL,
        0xfedcba9876543210ULL,
        0x0fedcba987654321ULL
    };
    fe64 y1 = {
        0x0123456789abcdefULL,
        0xfedcba9876543210ULL,
        0x5555555555555555ULL,
        0x6666666666666666ULL
    };
    run_test("normal", x1, y1);

    /* test 2: mul output in [2^255, 2^255 + 2^11) - reduce folds -p, output < 2^255
       x = y = 2^256 - 1, x*y = 37^2 = 1369 = 0x559 (mod p)
       mul output = 2^255 + 1350 (bit 255 = 1), reduce -> 0x559 (canonical) */
    fe64 x2 = {
        0xffffffffffffffffULL,
        0xffffffffffffffffULL,
        0xffffffffffffffffULL,
        0xffffffffffffffffULL
    };
    fe64 y2 = {
        0xffffffffffffffffULL,
        0xffffffffffffffffULL,
        0xffffffffffffffffULL,
        0xffffffffffffffffULL
    };
    run_test("non-canonical, reduce CAN fix (canonical = 0x559)", x2, y2);

    /* test 3: mul output in [p, 2^255) - one of the 19 missed values, reduce CANNOT fix
       x = y = p - 1, x*y = (-1)^2 = 1 (mod p)
       mul output = p + 1 = 2^255 - 18 (bit 255 = 0), reduce no-op, output stays p + 1 */
    fe64 x3 = {
        0xffffffffffffffecULL,
        0xffffffffffffffffULL,
        0xffffffffffffffffULL,
        0x7fffffffffffffffULL
    };
    fe64 y3 = {
        0xffffffffffffffecULL,
        0xffffffffffffffffULL,
        0xffffffffffffffffULL,
        0x7fffffffffffffffULL
    };
    run_test("non-canonical, reduce CANNOT fix (canonical = 0x1)", x3, y3);

    return 0;
}
