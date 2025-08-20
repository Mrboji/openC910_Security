`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/27 11:49:57
// Design Name: 
// Module Name: scaling_factors
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

`define	 MIXCOLUMN_WIDTH				8

module scaling_factors(
    input   [`MIXCOLUMN_WIDTH-1:0]  s,
    
    output  [`MIXCOLUMN_WIDTH-1:0]  output_data_2a,
    output  [`MIXCOLUMN_WIDTH-1:0]  output_data_2b,
    output  [`MIXCOLUMN_WIDTH-1:0]  output_data_49,
    output  [`MIXCOLUMN_WIDTH-1:0]  output_data_a
    );
    
    wire    w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,w21,w22,w23,w24,w25,w26,w27,w28,w29,w30,w31,w32,w33,w34,w35,w36,w37,w38,w39;
    
    assign  w0  =   s[5] ^ s[7];
    assign  w1  =   s[0] ^ s[2];
    assign  w2  =   s[1] ^ s[3];
    assign  w3  =   s[4] ^ s[6];
    assign  w4  =   s[3] ^ s[5];
    assign  w5  =   s[0] ^ s[6];
    assign  w6  =   s[1] ^ s[7];
    assign  w7  =   s[2] ^ s[7];
    assign  w21 =   s[0] ^ s[1];
    assign  w23 =   s[2] ^ s[5];
    assign  w24 =   s[4] ^ s[5];
    assign  w25 =   s[0] ^ s[3];
    assign  w34 =   s[2] ^ s[4];
    
    assign  w8  =   s[6] ^ w0  ;
    assign  w9  =   w0   ^ w1  ;
    assign  w10 =   w1   ^ w2  ;
    assign  w11 =   s[2] ^ w2  ;
    assign  w12 =   w2   ^ w3  ;
    assign  w13 =   w3   ^ s[7];
    assign  w14 =   w4   ^ w5  ;
    assign  w15 =   w6   ^ s[6];
    assign  w16 =   s[4] ^ w7  ;
    assign  w17 =   w8   ^ w10 ;
    assign  w18 =   w9   ^ s[3];
    assign  w19 =   w11  ^ w13 ;
    assign  w20 =   w0   ^ w3  ;
    assign  w22 =   w1   ^ s[3];
    assign  w26 =   w0   ^ w21 ;
    assign  w27 =   w20  ^ s[2];
    assign  w28 =   w8   ^ s[3];
    assign  w29 =   w13  ^ s[0];
    assign  w30 =   w3   ^ w23 ; 
    assign  w31 =   w7   ^ s[3];
    assign  w32 =   w25  ^ s[4];
    assign  w33 =   w24  ^ s[1];
    assign  w35 =   w5   ^ s[3];
    assign  w36 =   w4   ^ s[4];
    assign  w37 =   w12  ^ s[7];
    assign  w38 =   w14  ^ w7  ;
    assign  w39 =   w12  ^ s[0];
    
    
    assign  output_data_2a[0] = w12;
    assign  output_data_2a[1] = w17;
    assign  output_data_2a[2] = w19;
    assign  output_data_2a[3] = w18;
    assign  output_data_2a[4] = w4;
    assign  output_data_2a[5] = w14;
    assign  output_data_2a[6] = w15;
    assign  output_data_2a[7] = w16;
    
    assign  output_data_a[0] =  w2;
    assign  output_data_a[1] =  w10;
    assign  output_data_a[2] =  w11;
    assign  output_data_a[3] =  w22;
    assign  output_data_a[4] =  w0;
    assign  output_data_a[5] =  w20;
    assign  output_data_a[6] =  w8;
    assign  output_data_a[7] =  w13;
    
    assign  output_data_49[0] = w26;
    assign  output_data_49[1] = w27;
    assign  output_data_49[2] = w28;
    assign  output_data_49[3] = w29;
    assign  output_data_49[4] = w30;
    assign  output_data_49[5] = w31;
    assign  output_data_49[6] = w32;
    assign  output_data_49[7] = w33;
    
    assign  output_data_2b[0] = w39;
    assign  output_data_2b[1] = w38;
    assign  output_data_2b[2] = w37;
    assign  output_data_2b[3] = w9;
    assign  output_data_2b[4] = w36;
    assign  output_data_2b[5] = w35;
    assign  output_data_2b[6] = w6;
    assign  output_data_2b[7] = w34;
    
endmodule
