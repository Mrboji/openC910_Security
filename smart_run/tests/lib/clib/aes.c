#include "aes.h"
#include "config.h"

reg32_t aes_cr_reg = 0x00000400;// [10]:write enable

void aes_cr_config(p_aes_cr_mode cr_mode){
    // config reg
    aes_cr_reg &= 0xfffffffc;
    switch (cr_mode->wr_mode)
    {
        case WRITE_PLAINTEXT:
            break;
        case WRITE_KEY:
            aes_cr_reg |= 0x00000001;
            break;
        case WRITE_IV:
            aes_cr_reg |= 0x00000002;
            break;
        default:
            break;
    }
    // config enc/dec
    aes_cr_reg &= 0xfffffffb;
    if(cr_mode->enc_dec == DEC){
        aes_cr_reg |= 0x00000004;
    }  
    // config ecb/cbc
    aes_cr_reg &= 0xfffffff7;
    if(cr_mode->ecb_cbc == CBC){
        aes_cr_reg |= 0x00000008;
    } 
    // config max frame
    aes_cr_reg &= 0xfffffc0f;
    aes_cr_reg |= ((cr_mode->aes_max_frame & 0x1F) << 4);
    
    // write to aes cr reg
    *(reg32_t*)(AES_ADDR+AES_CR) 	 = aes_cr_reg; 
}
void aes_ht_bug_reg_config(aes_ht_bug_mode ht_bug_mode){
    switch (ht_bug_mode)
    {
        case AES_IP_WITH_COUNTER_HT:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000001;
            break;
        case AES_IP_WITH_FRAME_CANNOT_TOO_LONG:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000002;
            break;
        case AES_IP_WITH_HT_LEAK_KEY:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000004;
            break;
        case AES_IP_WITH_HT_REPLACE_SPECIAL_STRING:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000008;
            break;
        case AES_IP_WITH_HT_ORDER_OF_READ_DATA_CAN_BE_WRONG:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000010;
            break; 
        case AES_IP_WITH_BUG_9_ROUND:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000020;
            break; 
        case AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000040;
            break; 
        case AES_IP_WITHOUT_DECRYPTION:
            *(reg32_t*)(AES_ADDR+AES_HT) 	 	 = 0x00000080;
            break;     
        default:
            break;
    }
}

    
void aes_write_data(aes_data data,aes_wr_mode wr_mode){
    switch (wr_mode)
    {
        case WRITE_PLAINTEXT:
            printf("Start writing input text......");
            break;
        case WRITE_KEY:
            printf("Start writing key......");
            break;
        case WRITE_IV:
            printf("Start writing iv......");
            break;
        default:
            break;
    }
	*(reg32_t*)(AES_ADDR+AES_wdata) 	 = data[0];
	*(reg32_t*)(AES_ADDR+AES_wdata) 	 = data[1];
	*(reg32_t*)(AES_ADDR+AES_wdata) 	 = data[2];
	*(reg32_t*)(AES_ADDR+AES_wdata) 	 = data[3];
    printf("Write data complete!\n");
}


void aes_read_data(aes_data data){
    printf("Start reading aes output......");

    data[0] = *(reg32_t*)(AES_ADDR+AES_rdata);
    data[1] = *(reg32_t*)(AES_ADDR+AES_rdata);
    data[2] = *(reg32_t*)(AES_ADDR+AES_rdata);
    data[3] = *(reg32_t*)(AES_ADDR+AES_rdata);
    asm volatile("fence rw, rw");
    //while (data[3]==0){printf("-");}
    printf("Read data complete!\n");
}


void aes_print_results(aes_data data){
    printf("AES computing results is: ");
    for (int i = 0; i < 4; i++) {
        printf("%08X ", data[i]);
    }
    printf("\n");
}

void aes_compute(p_aes_cr_mode cr_mode,aes_data input_text,aes_data key,aes_data iv,aes_data output_text){
    printf("================= Start AES computing ========================= \n");
    
    cr_mode->wr_mode = WRITE_PLAINTEXT;
    aes_cr_config(cr_mode);
	aes_write_data(input_text,WRITE_PLAINTEXT);

    cr_mode->wr_mode = WRITE_KEY;
	aes_cr_config(cr_mode);
	aes_write_data(key,WRITE_KEY);

	if(cr_mode->ecb_cbc == CBC){
        cr_mode->wr_mode = WRITE_IV;
	    aes_cr_config(cr_mode);
	    aes_write_data(iv,WRITE_IV);
    }
	
	aes_read_data(output_text);

	aes_print_results(output_text);

    printf("================= End AES encoding ========================= \n");
}