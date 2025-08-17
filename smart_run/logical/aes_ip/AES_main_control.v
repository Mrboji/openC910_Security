`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/12 16:22:30
// Design Name: 
// Module Name: AES_main_control
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
`define count_cycle_width 2
//`define count_cycle_number_width 5
`define data_width 32


//`include "C:\Vivado\DongZhaojie\test_graduation_project\aes_define.vh"
module AES_main_control(
    input                               clk,
    input                               rst_n,
    input   [`count_cycle_width-1:0]    count_cycle,
    input                               mode,
    input                               input_round,   
    input                               last_round,
    input                               done_round,
    input                               idle_round,
    input   [`data_width-1:0]           input_data,
    input   [`data_width-1:0]           round_key,
    
    
    `ifdef AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ
    output [`data_width-1:0]            intermediate_data,
    `endif
    
    output  [`data_width-1:0]           output_data                       
    );
    
    wire    [`data_width-1:0]          w0,w1,w2,w3,w4,w5,w6,w7,w8,w9; 
    wire    [`data_width-1:0]          input_data_after_mapping;
    wire    [`data_width-1:0]          output_data_after_invmapping;
//    wire    [`data_width-1:0]          round_key_in_GF16;
    
    assign  w2  =   (mode & input_round) ? input_data_after_mapping : w1;
    assign  w4  =   mode ? w3 : w2;
    assign  w6  =   input_round ? input_data_after_mapping : (last_round ? w2 : w5);
    assign  w7  =   (input_round | last_round) ? w3 : w5;
    assign  w9 =   mode ? w7 : w8;
    assign  output_data = done_round ? output_data_after_invmapping : 'b0;
    
    `ifdef AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ
    assign  intermediate_data = w1;
    `endif
    
    ////////////////////////////////////////////////////////////////////////////////
    //                            transfer into GF16                              // 
    ////////////////////////////////////////////////////////////////////////////////  
    map_to_GF16     u0_map_to_GF16(
    .input_data                         (input_data[07:00]),
    .output_data_in_GF16                (input_data_after_mapping[07:00])
    );
    
    map_to_GF16     u1_map_to_GF16(
    .input_data                         (input_data[15:08]),
    .output_data_in_GF16                (input_data_after_mapping[15:08])
    );
    
    map_to_GF16     u2_map_to_GF16(
    .input_data                         (input_data[23:16]),
    .output_data_in_GF16                (input_data_after_mapping[23:16])
    );
    
    map_to_GF16     u3_map_to_GF16(
    .input_data                         (input_data[31:24]),
    .output_data_in_GF16                (input_data_after_mapping[31:24])
    );
    
    ////////////////////////////////////////////////////////////////////////////////////
    //              tips:或许可以把同构映射部分合并在密钥生成模块中                   //
    ////////////////////////////////////////////////////////////////////////////////////
    /*
    map_to_GF16     u4_map_to_GF16(
    .input_data                         (round_key[07:00]),
    .output_data_in_GF16                (round_key_in_GF16[07:00])
    );
    
    map_to_GF16     u5_map_to_GF16(
    .input_data                         (round_key[15:08]),
    .output_data_in_GF16                (round_key_in_GF16[15:08])
    );
    
    map_to_GF16     u6_map_to_GF16(
    .input_data                         (round_key[23:16]),
    .output_data_in_GF16                (round_key_in_GF16[23:16])
    );
    
    map_to_GF16     u7_map_to_GF16(
    .input_data                         (round_key[31:24]),
    .output_data_in_GF16                (round_key_in_GF16[31:24])
    );
    */
    ////////////////////////////////////////////////////////////////////////////////
    
    sbox_in_JSSC        u0_sbox(
    .input_data                    (w0[07:00]),
    .mode                              (mode),                       
    .output_data                   (w1[07:00])
    );
    
    sbox_in_JSSC        u1_sbox(
    .input_data                    (w0[15:08]),
    .mode                              (mode),                       
    .output_data                   (w1[15:08])
    ); 
    
    sbox_in_JSSC        u2_sbox(
    .input_data                    (w0[23:16]),
    .mode                              (mode),                       
    .output_data                   (w1[23:16])
    ); 
    
    sbox_in_JSSC        u3_sbox(
    .input_data                    (w0[31:24]),
    .mode                              (mode),                       
    .output_data                   (w1[31:24])
    ); 
    
    AddRoundKey     u0_AddRoundKey(
    .input_data                        (w2),
    .round_key                         (round_key),
    .output_data                       (w3)
    ); 
    
    mixcolumn_in_GF16    u_mixcolumn(
    .input_mixcolumn                   (w4),
    .mode                              (mode),                       
    .output_mixcolumn                  (w5)
    );
    
    AddRoundKey     u1_AddRoundKey(
    .input_data                        (w6),
    .round_key                         (round_key),
    .output_data                       (w8)
    ); 
    
    register_and_shiftrows_module   u_register_and_shiftrows_module(
    .clk                               (clk),
    .rst_n                             (rst_n),
    .mode                              (mode),                    
    .done_round                        (done_round),              
    .count_cycle                       (count_cycle),        
    //.input_round                       (input_round),       
    .idle_round                        (idle_round),     
    .input_data                        (w9),
    .output_data                       (w0)
    ); 
    
    ////////////////////////////////////////////////////////////////////////////////
    //                           transfer out of GF16                             // 
    //////////////////////////////////////////////////////////////////////////////// 
    invmap_to_GF16      u0_invmap_to_GF16(
    .input_data_in_GF16                 (w0[07:00]),
    .output_data_in_GF256               (output_data_after_invmapping[07:00])
    );
    
    invmap_to_GF16      u1_invmap_to_GF16(
    .input_data_in_GF16                 (w0[15:08]),
    .output_data_in_GF256               (output_data_after_invmapping[15:08])
    );
    
    invmap_to_GF16      u2_invmap_to_GF16(
    .input_data_in_GF16                 (w0[23:16]),
    .output_data_in_GF256               (output_data_after_invmapping[23:16])
    );
    
    invmap_to_GF16      u3_invmap_to_GF16(
    .input_data_in_GF16                 (w0[31:24]),
    .output_data_in_GF256               (output_data_after_invmapping[31:24])
    );
    //////////////////////////////////////////////////////////////////////////////// 
    
endmodule
