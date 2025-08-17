/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
//#include "stdio.h"
#include "datatype.h"
//#include "uart.h"
#include "stdio.h"
#include "aes.h"

// 0：without any bugs
// 1-8:
// AES_IP_WITH_COUNTER_HT,
// AES_IP_WITH_FRAME_CANNOT_TOO_LONG,
// AES_IP_WITH_HT_LEAK_KEY,
// AES_IP_WITH_HT_REPLACE_SPECIAL_STRING,
// AES_IP_WITH_HT_ORDER_OF_READ_DATA_CAN_BE_WRONG,
// AES_IP_WITH_BUG_9_ROUND,
// AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ,
// AES_IP_WITHOUT_DECRYPTION
#define TEST_OPTION 0 

// a722c4f3f7e63f1d849130fe195530dd
// 00 01 02 03 00 01 02 03 00 01 02 03 00 01 02 03
// 
aes_data aes_input  = {0x00010203, 0x00010203, 0x00010203, 0x00010203};
aes_data aes_key    = {0xa722c4f3, 0xf7e63f1d, 0x849130fe, 0x195530dd};
aes_data aes_outext = {0x8BAE8D2D, 0xEF9556DE, 0xADF366E3, 0x35A365BD};
//aes_data aes_iv     = {0xabcdef01, 0xabcdef01, 0xabcdef01, 0xabcdef01};
aes_data aes_output = {0}; 
int main (void)
{
	p_aes_cr_mode cr_mode;
	cr_mode->enc_dec = ENC;
	cr_mode->ecb_cbc = ECB;
	cr_mode->aes_max_frame = 0x10;
	#if TEST_OPTION == 0
		aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
	#elif TEST_OPTION == 1
		aes_ht_bug_reg_config(AES_IP_WITH_COUNTER_HT);
		// 3rd trig
		for(int i=1;i<=4;i++){
			printf("AES enc No.%d times\n",i);
			aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
		}
	#elif TEST_OPTION == 2
		aes_ht_bug_reg_config(AES_IP_WITH_FRAME_CANNOT_TOO_LONG);
		// 3rd trig
		for(int i=1;i<=4;i++){
			printf("AES enc No.%d times\n",i);
			aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
		}
	#elif TEST_OPTION == 3
		aes_ht_bug_reg_config(AES_IP_WITH_HT_LEAK_KEY);
		// 3rd trig
		for(int i=1;i<=4;i++){
			printf("AES enc No.%d times\n",i);
			aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
		}
	#elif TEST_OPTION == 4
		aes_ht_bug_reg_config(AES_IP_WITH_HT_REPLACE_SPECIAL_STRING);
		// 2nd trig
		for(int i=1;i<=3;i++){
			printf("AES enc No.%d times\n",i);
			aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
		}
	#elif TEST_OPTION == 5
		aes_ht_bug_reg_config(AES_IP_WITH_HT_ORDER_OF_READ_DATA_CAN_BE_WRONG);
		// 3rd trig
		for(int i=1;i<=4;i++){
			printf("AES enc No.%d times\n",i);
			aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
		}
	#elif TEST_OPTION == 6
		aes_ht_bug_reg_config(AES_IP_WITH_BUG_9_ROUND);
		// direct trig
		for(int i=1;i<=1;i++){
			printf("AES enc No.%d times\n",i);
			aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
		}
	#elif TEST_OPTION == 7
		aes_ht_bug_reg_config(AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ);
		for(int i=1;i<=4;i++){
			printf("AES enc No.%d times\n",i);
			aes_compute(cr_mode,aes_input,aes_key,0,aes_output);
		}
	#elif TEST_OPTION == 8
		cr_mode->enc_dec = DEC;
		aes_compute(cr_mode,aes_outext,aes_key,0,aes_output);
		// show dec fail
		aes_ht_bug_reg_config(AES_IP_WITHOUT_DECRYPTION);
		aes_compute(cr_mode,aes_outext,aes_key,0,aes_output);
	#endif

  	return 0;
}
