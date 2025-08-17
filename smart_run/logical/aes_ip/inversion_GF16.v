`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 09:01:44
// Design Name: 
// Module Name: inversion_GF16
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

`define	 SBOX_INPUT_WIDTH				8

module inversion_GF16(
    input   [`SBOX_INPUT_WIDTH-1:0] input_data,
    
    output  [`SBOX_INPUT_WIDTH-1:0] output_data
    );
    
    wire    [3:0]   sh,sl;
    wire    [3:0]   w0,w1,w2,w3,w4;
    wire    [3:0]   outh,outl;
    
    assign  sh  =   input_data[7:4];
    assign  sl  =   input_data[3:0];
    assign  w1  =   sh ^ sl;
    assign  w3  =   w0 ^ w2;
    assign  output_data = {outh,outl};
    
    
    square_with_multi_constant      u_square_with_multi_constant(
    .input_data     (sh),
    .output_data    (w0)
    );
    
    smulti                          u0_smulti(
    .a              (sl),
    .b              (w1),
    .q              (w2)
    );
    
    smulti                          u1_smulti(
    .a              (w4),
    .b              (sh),
    .q              (outh)
    );
    
    smulti                          u2_smulti(
    .a              (w4),
    .b              (w1),
    .q              (outl)
    );
    
    ////////////////////////////////////////////////////////////////////////
    //          关于求逆运算是否在JSSC所示的架构中依旧适用，存疑          //
    ////////////////////////////////////////////////////////////////////////
     sinv                           u_sinv(
     .a             (w3),
     .q             (w4)
     );
    
    
    
    
    
    
    
endmodule
