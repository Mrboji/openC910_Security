`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/27 08:42:02
// Design Name: 
// Module Name: mixcolumn_in_GF16
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//`include "aes_ip_defines.v"

`define	 AES_MAIN_PATH_WIDTH				32

module mixcolumn_in_GF16(
    input   [`AES_MAIN_PATH_WIDTH-1:0]  input_mixcolumn,
    input                                  mode,
    
    output  [`AES_MAIN_PATH_WIDTH-1:0]  output_mixcolumn
    );
    
    wire    [7:0]       s0,s1,s2,s3;
    wire    [7:0]       s0a2,s0b2,s049,s0a1;
    wire    [7:0]       s1a2,s1b2,s149,s1a1;
    wire    [7:0]       s2a2,s2b2,s249,s2a1;
    wire    [7:0]       s3a2,s3b2,s349,s3a1;
    
    wire    [7:0]       w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17;
  
//////////////////////////////////////////////////////////////////////////////////  
//    还需要好好思考一下，这里S0-s3是应该如何分配？？看图中似乎s0反而是最高位   //
//////////////////////////////////////////////////////////////////////////////////
    
/*
    assign  s0  =   input_mixcolumn[07:00];
    assign  s1  =   input_mixcolumn[15:08];
    assign  s2  =   input_mixcolumn[23:16];
    assign  s3  =   input_mixcolumn[31:24];
*/ 
    assign  s0  =   input_mixcolumn[31:24];
    assign  s1  =   input_mixcolumn[23:16];
    assign  s2  =   input_mixcolumn[15:08];
    assign  s3  =   input_mixcolumn[07:00];
//////////////////////////////////////////////////////////////////////////////////

    assign  w0  =   s0  ^   s1;
    assign  w1  =   s1  ^   s2;
    assign  w2  =   s2  ^   s3;
    assign  w3  =   s3  ^   s0;
    
    assign  w4  =   s0b2^   s1a2;
    assign  w5  =   s1b2^   s2a2;
    assign  w6  =   s2b2^   s3a2;
    assign  w7  =   s3b2^   s0a2;
    
    assign  w8  =   s0a1^   s149;
    assign  w9  =   s1a1^   s049;
    assign  w10 =   s2a1^   s349;
    assign  w11 =   s3a1^   s249;
    
    assign  w12 =   w4  ^   w2  ;
    assign  w13 =   w5  ^   w3  ;
    assign  w14 =   w6  ^   w0  ;
    assign  w15 =   w7  ^   w1  ;
    
    assign  w16 =   {8{mode}} & (w8 ^ w10);
    assign  w17 =   {8{mode}} & (w9 ^ w11);
    
    assign  output_mixcolumn[31:24] =  w12 ^ w16;
    assign  output_mixcolumn[23:16] =  w13 ^ w17;
    assign  output_mixcolumn[15:08] =  w14 ^ w16;
    assign  output_mixcolumn[07:00] =  w15 ^ w17;
    
    scaling_factors     u0_scaling_factors(
    .s                  (s0),
    .output_data_2a     (s0a2),
    .output_data_2b     (s0b2),
    .output_data_49     (s049),
    .output_data_a      (s0a1)
    );
    
    scaling_factors     u1_scaling_factors(
    .s                  (s1),
    .output_data_2a     (s1a2),
    .output_data_2b     (s1b2),
    .output_data_49     (s149),
    .output_data_a      (s1a1)
    );
    
    scaling_factors     u2_scaling_factors(
    .s                  (s2),
    .output_data_2a     (s2a2),
    .output_data_2b     (s2b2),
    .output_data_49     (s249),
    .output_data_a      (s2a1)
    );
    
    scaling_factors     u3_scaling_factors(
    .s                  (s3),
    .output_data_2a     (s3a2),
    .output_data_2b     (s3b2),
    .output_data_49     (s349),
    .output_data_a      (s3a1)
    );
    
endmodule
