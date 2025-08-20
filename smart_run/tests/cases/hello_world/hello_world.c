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
#include "uart.h"
#include "stdio.h"
#define UART0_ADDR  0x10015000
#define AES_ADDR  	0x20000000

//#define AES_clr		0x0014
#define AES_clr		0x0110

#define AES_CR		0x0210

//#define AES_wdata	0x0214
#define AES_wdata	0x0220

//#define AES_rdata	0x0304
#define AES_rdata	0x0310	
reg32_t  AES_output[4]={0}; //unsigned long long	AES_output;
int main (void)
{

    //------------------------------------------------
    //   --------------------------------------------------------
    //   setup uart
    //   --------------------------------------------------------

	// uart_cfig.baudrate = BAUD;       // any integer value is allowed
	// uart_cfig.parity = PARITY_NONE;     // PARITY_NONE / PARITY_ODD / PARITY_EVEN
	// uart_cfig.stopbit = STOPBIT_1;      // STOPBIT_1 / STOPBIT_2
	// uart_cfig.wordsize = WORDSIZE_8;    // from WORDSIZE_5 to WORDSIZE_8
	// uart_cfig.txmode = ENABLE;          // ENABLE or DISABLE

	// // open UART device with id = 0 (UART0)
	// ck_uart_open(&uart0, 0);

	// // initialize uart using uart_cfig structure
	// ck_uart_init(&uart0, &uart_cfig);

	printf("AB\n");
	
	/* ----------------------------------- AES ---------------------------------- */
  	//reg32_t  AES_output[4]={0}; //unsigned long long	AES_output;

	*(reg64_t*)(AES_ADDR+AES_CR) 	 	 = 0x00000518;	//config
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x12153524;	//input text
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x12153524;	//input text
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x12153524;	//input text
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x12153524;	//input text

	//write key
	*(reg64_t*)(AES_ADDR+AES_CR) 	 	 = 0x00000519;	//config
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x00010203;	//key
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x00010203;	//key
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x00010203;	//key
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0x00010203;	//key

	//write IV
	*(reg64_t*)(AES_ADDR+AES_CR) 	 	 = 0x0000051a;	//config
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0xabcdef01;	//IV
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0xabcdef01;	//IV
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0xabcdef01;	//IV
	*(reg64_t*)(AES_ADDR+AES_wdata) 	 = 0xabcdef01;	//IV
	
  	printf("computing");
    // while(*(reg64_t*)(AES_ADDR+AES_rdata)==0){
	// 	printf(".");
	// }

    //AES have done,read output text
    AES_output[0] = *(reg32_t*)(AES_ADDR+AES_rdata);
	  asm volatile("fence rw, rw");
    // AES_output[1] = *(reg64_t*)(AES_ADDR+AES_rdata);
    // AES_output[2] = *(reg64_t*)(AES_ADDR+AES_rdata);
    // AES_output[3] = *(reg64_t*)(AES_ADDR+AES_rdata);
    printf("\nwaiting for results");
    while (AES_output[0]==0)
    {
      /* code */
      printf("-");
    }
	
    // printf("\n");
    printf("out:%x\n",AES_output[0]);
	  //ck_uart_close(&uart0);
	//while(1);
  return 0;
}
