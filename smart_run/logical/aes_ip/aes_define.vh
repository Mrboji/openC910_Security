        `define ALL_CASE                    1
        `define USE_SMALLER_KEY_EXPANSION   1
        

    //////////////////////////////////////////////////
	//used for insert HTs
	/////////////////////////////////////////////////

    //`define AES_IP_WITH_COUNTER_HT      1                             //correct
	//HT1

	//`define AES_IP_WITH_HT_REPLACE_SPECIAL_STRING 1                   //correct
	//HT2

	//`define AES_IP_WITH_FRAME_CANNOT_TOO_LONG     1                   //correct
	//HT3

    //`define AES_IP_WITH_HT_LEAK_KEY     1                             //correct
	//HT4

	//`define AES_IP_WITH_BUG_DOS         1                             //correct
    //bug1

	//`define AES_IP_WITH_BUG_9_ROUND     1                             //correct
	//bug2

    //`define AES_IP_WITHOUT_DECRYPTION  1                              //correct
	//bug3

    `define AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ 1               //correct
    //bug4

	//`define AES_IP_WITH_HT_OUTPUT_CANNOT_ERASE_WHEN_RESET 1           //correct
	//bug5

    //`define AES_IP_WITH_HT_ORDER_OF_READ_DATA_CAN_BE_WRONG 1          //correct
	//bug6


    `define  C_S00_AXI_ID_WIDTH	     		8
	`define  C_S00_AXI_DATA_WIDTH	 		128
	`define  C_S00_AXI_ADDR_WIDTH	 		40
	`define  C_S00_AXI_AWUSER_WIDTH	 		0
	`define  C_S00_AXI_ARUSER_WIDTH	 		0
	`define  C_S00_AXI_WUSER_WIDTH	 		0
	`define  C_S00_AXI_RUSER_WIDTH	 		0
	`define  C_S00_AXI_BUSER_WIDTH	 		0
	`define  C_S00_AXI_AWLEN_WIDTH	 		8
	`define  C_S00_AXI_AWSIZE_WIDTH	 		3
	`define  C_S00_AXI_AWBURST_WIDTH	 	2
	`define  C_S00_AXI_AWCACHE_WIDTH	 	4
	`define  C_S00_AXI_AWPROT_WIDTH	 		3
	`define  C_S00_AXI_AWQOS_WIDTH	 		4
	`define  C_S00_AXI_AWREGION_WIDTH 		4
	`define  C_S00_AXI_BRESP_WIDTH   		2		
	`define  ERROR_SIGNAL_WIDTH      		5
	
	//////////////////////////////////////////////////
	//used for SPC
	/////////////////////////////////////////////////
	`define SPC_ADDR_WIDTH          14	
	`define ERROR_LOG_WIDTH         15
		
		
	//////////////////////////////////////////////////
	//used for timer_in_SPC
	/////////////////////////////////////////////////
	`define TRIGGER_NUMBER          300
	
	//////////////////////////////////////////////////
	//used for error log
	/////////////////////////////////////////////////  
	`define THRESHOLD_MIDDLE_ERROR  3
	`define THRESHOLD_LOW_ERROR     8

	//////////////////////////////////////////////////
	//used for simulation
	///////////////////////////////////////////////// 
	   //`define simulation_DOS                          1
	   //`define simulation_immediate_result_leakage     1
	   //`define simulation_counter_HT                   1
