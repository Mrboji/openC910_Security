`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/10 15:31:34
// Design Name: 
// Module Name: sbox_in_GF16_with_only_affine
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


module sbox_in_GF16_with_only_affine(
    input   [7:0]   input_of_inv_and_affine_in_GF16,
    output  [7:0]   output_of_inv_and_affine_in_GF16
    );
    
    wire    [7:0]       w0;
    
    inversion_GF16      u_inversion_GF16(
    .input_data         (input_of_inv_and_affine_in_GF16),
    .output_data        (w0)
    );
    
    affine_mapping      u_affine_mapping(
    .input_data         (w0),
    .output_data        (output_of_inv_and_affine_in_GF16) 
    );
    
    
endmodule
