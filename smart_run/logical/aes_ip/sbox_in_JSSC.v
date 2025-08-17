`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/21 11:14:35
// Design Name: 
// Module Name: sbox_in_JSSC
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

module sbox_in_JSSC(
    input       [`SBOX_INPUT_WIDTH-1:0]       input_data,
    input                                     mode,             //1'b0 means encryption,1'b1 means decryption
    
    output      [`SBOX_INPUT_WIDTH-1:0]       output_data   
    );
    
    wire        [`SBOX_INPUT_WIDTH-1:0]      w0,w1,w2,w3;
    
    assign w1           = mode ? w0 : input_data;
    assign output_data  = mode ? w2 : w3;
    
    inversion_GF16      u_inversion_GF16(
    .input_data         (w1),
    .output_data        (w2)
    );
    
    invaffine_mapping   u_invaffine_mapping(
    .input_data         (input_data),
    .output_data        (w0) 
    );
    
    affine_mapping      u_affine_mapping(
    .input_data         (w2),
    .output_data        (w3) 
    );
    
    
endmodule
