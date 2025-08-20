`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/16 10:38:23
// Design Name: 
// Module Name: rcon
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
//`define RCON_USE_LOOK_UP_TABLE   1'b0
//`define RCON_USE_VALUE_OPERATION 1'b1

module rcon(
    input     [3:0]     key_expand_round_number,
    output  reg  [7:0]  rcon
    );


/////////////////////////////////////////////////////////////////////////////////
//                              original code                                  //
/////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////// 
//                     using   value   operation                               //
/////////////////////////////////////////////////////////////////////////////////
/*
`ifdef  RCON_USE_VALUE_OPERATION        
    
    assign  rcon   =    key_expand_round_number[3] ? (8'h1b << key_expand_round_number[0]) : (8'h01 << key_expand_round_number);
    
///////////////////////////////////////////////////////////////////////////////// 
//                         using   look  up  table                             //
///////////////////////////////////////////////////////////////////////////////// 
`else
    reg     rcon;
    
    always  @(*) begin
        case(key_expand_round_number)
            4'd0:   rcon  <= 8'h01;
            4'd1:   rcon  <= 8'h02;
            4'd2:   rcon  <= 8'h04;
            4'd3:   rcon  <= 8'h08;
            4'd4:   rcon  <= 8'h10;
            4'd5:   rcon  <= 8'h20;
            4'd6:   rcon  <= 8'h40;
            4'd7:   rcon  <= 8'h80;
            4'd8:   rcon  <= 8'h1b;
            4'd9:   rcon  <= 8'h36;
        default:    rcon  <= 8'h00;
        endcase
    end   
    
`endif  
*/
 
 
/////////////////////////////////////////////////////////////////////////////////
//                              current code in GF(16)                         //
/////////////////////////////////////////////////////////////////////////////////  
    
    always  @(*) begin
        case(key_expand_round_number)
            4'd0:   rcon  = 8'h01;
            4'd1:   rcon  = 8'h2b;
            4'd2:   rcon  = 8'h43;
            4'd3:   rcon  = 8'h49;
            4'd4:   rcon  = 8'h3b;
            4'd5:   rcon  = 8'hd6;
            4'd6:   rcon  = 8'h33;
            4'd7:   rcon  = 8'he1;
            4'd8:   rcon  = 8'h58;
            4'd9:   rcon  = 8'h85;
        default:    rcon  = 8'h00;
        endcase
    end 
    

endmodule
