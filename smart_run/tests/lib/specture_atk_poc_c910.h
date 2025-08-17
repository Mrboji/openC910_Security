#define ATTACK_SAME_ROUNDS 3
#define SECRET_SZ 2
#define CACHE_HIT_THRESHOLD 80
#define L1_BLOCK_SZ_BYTES 64
#include "datatype.h"

/* -------------------------------------------------------------------------- */
/*                               global varibles                              */
/* -------------------------------------------------------------------------- */

/* ------------------------------ victim array ------------------------------ */
uint64_t array1_sz = 6;
uint8_t unused0[1024];
uint64_t *p_array1_sz = &array1_sz;
uint8_t unused1[64];
uint8_t array1[6] = {0};
uint8_t unused2[64];
/* ----------------------------- attacker array ----------------------------- */
uint8_t array2[256 * L1_BLOCK_SZ_BYTES];
uint8_t unused3[64];
uint8_t *p_array2 = array2;
uint8_t unused4[64];

/* ------------------------------- secret data ------------------------------ */
char *secret = "AB";
uint8_t unused5[64];
/* ------------------------- temp for read atk_array ------------------------ */
uint64_t temp = 1;