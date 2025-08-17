`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/26 10:45:20
// Design Name: 
// Module Name: square_with_multi_constant
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


module square_with_multi_constant(
    input   [3:0]   input_data,
    
    output  [3:0]   output_data
    );
    
    wire    tmp1, tmp2;
    
    assign tmp1         =   input_data[0] ^ input_data[1];
    assign tmp2         =   input_data[2] ^ input_data[3];
    assign output_data  =   {tmp1 ^ tmp2, tmp2, tmp1 ^ input_data[2], input_data[0] ^ input_data[3]};
    
endmodule
