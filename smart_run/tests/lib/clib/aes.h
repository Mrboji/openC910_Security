#include "datatype.h"


// AES BASE ADDR
#define AES_ADDR  	0x20000000
// clear
#define AES_clr		0x0110
// control reg
#define AES_CR		0x0210
// write data
#define AES_wdata	0x0220
// read data
#define AES_rdata	0x0310
// ht bug config
#define AES_HT	    0x0260

typedef enum {
    WRITE_PLAINTEXT,
    WRITE_KEY,
    WRITE_IV
} aes_wr_mode;

typedef enum {
    ENC,
    DEC
} aes_enc_dec;

typedef enum {
    ECB,
    CBC
} aes_ecb_cbc;

typedef struct {
    aes_wr_mode wr_mode;
    aes_enc_dec enc_dec;
    aes_ecb_cbc ecb_cbc;
    char aes_max_frame;
} aes_cr_mode, *p_aes_cr_mode;

typedef enum {
    AES_IP_WITH_COUNTER_HT,
    AES_IP_WITH_FRAME_CANNOT_TOO_LONG,
    AES_IP_WITH_HT_LEAK_KEY,
    AES_IP_WITH_HT_REPLACE_SPECIAL_STRING,
    AES_IP_WITH_HT_ORDER_OF_READ_DATA_CAN_BE_WRONG,
    AES_IP_WITH_BUG_9_ROUND,
    AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ,
    AES_IP_WITHOUT_DECRYPTION
}aes_ht_bug_mode;
// aes data:input_text key iv output_text
typedef reg32_t aes_data[4];

void aes_cr_config(p_aes_cr_mode cr_mode);
void aes_ht_bug_reg_config(aes_ht_bug_mode ht_bug_mode);
void aes_write_data(aes_data data,aes_wr_mode wr_mode);
void aes_read_data(aes_data data);
void aes_print_results(aes_data data);
void aes_compute(p_aes_cr_mode cr_mode,aes_data input_text,aes_data key,aes_data iv,aes_data output_text);

extern reg32_t aes_cr_reg;