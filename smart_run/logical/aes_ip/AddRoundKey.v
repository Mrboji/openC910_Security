`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/12 15:35:14
// Design Name: 
// Module Name: AddRoundKey
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

`define data_width 32

module AddRoundKey(
    input  [`data_width-1:0] input_data,
    input  [`data_width-1:0] round_key,
    output [`data_width-1:0] output_data
    );
    
    assign output_data = input_data ^ round_key;
   
endmodule
