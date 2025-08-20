`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/21 23:07:58
// Design Name: 
// Module Name: AES_IP_for_NICE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      top design for CBC and ECB mode
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// �ر�ע�⣬һ��ģʽֻ���ڸ�λ��ʱ������Ǹ����µ�IV��key��mode_of_encryption_or_decryptionʱ�����л�����һ��ģʽ

//`include "C:\Vivado\DongZhaojie\test_graduation_project\aes_define.vh"

module AES_IP_with_ECB_CBC_mode(
    input               clk,
    input               rst_n,
    input               start,                              //start signal only continue 1 cycle
    input   [31:0]      input_text,
    input   [31:0]      key,
    input   [31:0]      IV,
    //input   [1:0]       key_width,                          //2'b00 means 128bit,2'b01 means 192bit,2'b11 means 256bit
    //only use 128bit key width
    input               mode_of_encryption_or_decryption,   //1'b0 means encryption, 1'b1 means decryption
    input               mode_of_ECB_or_CBC,                 //1'b0 means ECB, 1'b1 means CBC
    
    input bug_9_round_en,

    `ifdef AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ
    output  [31:0]            intermediate_data,
    `endif
    
    output              done,
    output  [31:0]      output_text    
    );
 
 //----------------------------------------------------------------
 //second version 2021/12/06
 //----------------------------------------------------------------
 wire                start_posedge;
 wire   [31:00]      w0,w1,w2,w3,w4,w5,w6;
 wire   [31:00]      output_text_of_AES;
 wire   [31:00]      key_to_AES;
 
 reg                 start_reg0, start_reg1;
 reg                 mode_reg,mode_ECB_CBC_reg;
 reg    [127:00]     key_reg;
 reg    [255:00]     input_text_reg;
 reg    [127:00]     output_text_reg;
 reg    [127:00]     IV_reg;
 reg                 IV_equal, key_equal, mode_equal, mode_ECB_CBC_equal;           //1'b1 means equal to last computation
 reg    [1:0]        text_counter;
 reg    [2:0]        compare_counter; 

 assign key_to_AES  = key_reg[31:00];
 assign output_text = w3;
 
 assign w0 = (IV_equal && key_equal && mode_equal && mode_ECB_CBC_equal) ? input_text_reg[31:00] ^ w4 : input_text_reg[31:00] ^ IV_reg[31:00];
 assign w1 = (IV_equal && key_equal && mode_equal && mode_ECB_CBC_equal) ? output_text_of_AES ^ w5 : output_text_of_AES ^ w6;
 assign w2 = (mode_ECB_CBC_reg==1'b1 && mode_reg==1'b0) ? w0 : input_text_reg[31:00];
 assign w3 = (mode_ECB_CBC_reg==1'b1 && mode_reg==1'b1) ? w1 : output_text_of_AES;
     
 assign w4 = (compare_counter==3'd2) ? output_text_reg[127:096] : 
             (compare_counter==3'd3) ? output_text_reg[095:064] :
             (compare_counter==3'd4) ? output_text_reg[063:032] : output_text_reg[031:000];
 assign w5 = (text_counter==2'd0) ? input_text_reg[255:224] :
             (text_counter==2'd1) ? input_text_reg[223:192] :
             (text_counter==2'd2) ? input_text_reg[191:160] : input_text_reg[159:128];
 assign w6 = (text_counter==2'd0) ? IV_reg[127:096] :
             (text_counter==2'd1) ? IV_reg[095:064] :
             (text_counter==2'd2) ? IV_reg[063:032] : IV_reg[031:000];
             
    /////////////////////////////////////////////////////////////
    //                     start_posedge                       //
    /////////////////////////////////////////////////////////////
    assign  start_posedge = start_reg0 & ~start_reg1;
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            start_reg0  <=  1'b0;
            start_reg1  <=  1'b0;
        end
        else begin
            start_reg0  <=  start;
            start_reg1  <=  start_reg0;
        end
    end
    ///////////////////////////////////////////////////////////// 
    
 //----------------------------------------------------------------
 //store input and output signals
 //----------------------------------------------------------------
 always  @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        {IV_reg,key_reg,input_text_reg} <= 'b0;
    else if(compare_counter != 'b0) begin
        IV_reg  <= {IV_reg[96:00],IV};
        key_reg <= {key_reg[96:00],key};
        input_text_reg <= {input_text_reg[223:00],input_text};
    end 
 end
 
 always  @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mode_reg    <=  1'b0;
        mode_ECB_CBC_reg <= 1'b0; 
    end
    else if(start_posedge) begin
        mode_reg    <=  mode_of_encryption_or_decryption;
        mode_ECB_CBC_reg <= mode_of_ECB_or_CBC;
    end
 end  
 
 always  @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        output_text_reg    <=  'b0;
    else if(done)
        output_text_reg    <=  {output_text_reg[95:00],output_text_of_AES};
 end
 
 //----------------------------------------------------------------
 //generate IV_equal, key_equal, mode_equal signal
 //----------------------------------------------------------------
 always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)  
            compare_counter  <=    3'b0;
        else if(compare_counter == 3'd4)
            compare_counter  <=    3'b0;
        else if((start==1'b1 && compare_counter==3'b0) || compare_counter != 3'd0)
            compare_counter  <=    compare_counter + 1'b1;
        else
            compare_counter  <=    compare_counter;
    end
 
 always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            IV_equal    <= 1'b1;
            key_equal   <= 1'b1;
            mode_equal  <= 1'b1;
            mode_ECB_CBC_equal <= 1'b1;
        end
        else if(start) begin
            IV_equal    <= 1'b1;
            key_equal   <= 1'b1;
            mode_equal  <= 1'b1;
            mode_ECB_CBC_equal <= 1'b1;
        end
        else begin
            case(compare_counter)
                3'b0:   begin
                    IV_equal    <= IV_equal;
                    key_equal   <= key_equal;
                    mode_equal  <= mode_equal; 
                    mode_ECB_CBC_equal <= mode_ECB_CBC_equal;
                end
                3'b1: begin
                    IV_equal    <= IV_equal   & (IV_reg[127:96] == IV);
                    key_equal   <= key_equal  & (key_reg[127:96] == key);
                    mode_equal  <= mode_reg == mode_of_encryption_or_decryption;
                    mode_ECB_CBC_equal <= mode_ECB_CBC_reg == mode_of_ECB_or_CBC;
                end
                default: begin
                    IV_equal    <= IV_equal   & (IV_reg[127:96] == IV);
                    key_equal   <= key_equal  & (key_reg[127:96] == key);
                    mode_equal  <= mode_equal;
                    mode_ECB_CBC_equal <= mode_ECB_CBC_equal;
                end
            endcase
        end
 end
 
 //----------------------------------------------------------------
 //generate text_counter
 //----------------------------------------------------------------
 always  @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        text_counter <= 2'b0;
    else if(done)                                   //done signal will continue 4 cycles
        text_counter <= text_counter + 1'b1;
 end
  //----------------------------------------------------------------
  //instance
  //----------------------------------------------------------------
 
 AES_IP_top_design_by_dong   u_AES_IP_top_design_by_dong(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .start                  (start_posedge),                      //start signal would be high for 1 cycle,early than input_text and key
    .input_text             (w2),
    .input_key              (key_to_AES),
    
    // `ifndef  AES_IP_WITHOUT_DECRYPTION 
    // .mode                   (),                         //0 means encryption, 1 means decryption
    // `else
    .mode                   (mode_reg),
    //`endif
    .bug_9_round_en         (bug_9_round_en),
    .key_width              (2'b00),                            //2'b00 means 128bit, 2'b01 means 192bit, 2'b10 means 256bit
    
    `ifdef AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ
    .intermediate_data      (intermediate_data),
    `endif
    
    .done                   (done),
    .output_text            (output_text_of_AES)
    );
 
 
 //----------------------------------------------------------------
 //first version 2021/06/21
 //----------------------------------------------------------------
 /*   
    wire                start_posedge;
    wire    [31:0]      w0,w1,w2,input_key;    
    wire    [31:0]      output_text_of_AES;
    
    reg                 start_reg0, start_reg1;
    reg     [63:0]      plaintext_reg;
    reg     [255:0]     chiphertext_reg;                // ����һ�ֵ�����
    reg     [127:0]     outputtext_reg;
    reg     [3:0]       key_counter;                    //choose input_key
    reg     [2:0]       text_counter;
    
    assign  w0          =   (mode_of_encryption_or_decryption==1'b0 && mode_of_ECB_or_CBC==1'b1) ? plaintext_reg[63:32] ^w2 : plaintext_reg[63:32];
    assign  w1          =   text_counter==3'd0 ? chiphertext_reg[255:224] : text_counter==3'd1 ? chiphertext_reg[223:192] : text_counter==3'd2 ? chiphertext_reg[191:160] : text_counter==3'd3 ? chiphertext_reg[159:128] : chiphertext_reg[255:224];
    assign  w2          =   text_counter==3'd2 ? outputtext_reg[127:096] : text_counter==3'd3 ? outputtext_reg[095:064] : text_counter==3'd4 ? outputtext_reg[063:032] : text_counter==3'd5 ? outputtext_reg[031:000] : outputtext_reg[127:096];
    assign  output_text =   (mode_of_encryption_or_decryption==1'b1 && mode_of_ECB_or_CBC==1'b1) ? w1 ^  output_text_of_AES : output_text_of_AES;     
    /////////////////////////////////////////////////////////////
    //                     start_posedge                       //
    /////////////////////////////////////////////////////////////
    assign  start_posedge = start_reg0 & ~start_reg1;
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            start_reg0  <=  1'b0;
            start_reg1  <=  1'b0;
        end
        else begin
            start_reg0  <=  start;
            start_reg1  <=  start_reg0;
        end
    end
    /////////////////////////////////////////////////////////////   
    
    /////////////////////////////////////////////////////////////
    //                     text_counter                        //
    /////////////////////////////////////////////////////////////
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)  
            text_counter  <=    3'b0;
        else if(text_counter==3'd5)
            text_counter  <=    3'b0;
        else if((start|done) && text_counter=='b0 || text_counter!=3'd0)
            text_counter  <=    text_counter + 1'b1;
        else
            text_counter  <=    text_counter;
    end
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            plaintext_reg   <=  'b0;
            chiphertext_reg <=  'b0;
        end
        else  begin
            plaintext_reg   <=  {plaintext_reg[31:0],input_text};
            if(start) 
                chiphertext_reg <=  {chiphertext_reg[224:0],input_text};    
             else
                chiphertext_reg <=  chiphertext_reg;
        end
    end
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            outputtext_reg  <=  'b0;
        else if(done)
            outputtext_reg  <=  {outputtext_reg[95:00],output_text_of_AES};
        else
            outputtext_reg  <=  outputtext_reg;
    end
    
    ////////////////////////////////////////////////////////////////////////////
    //                          key to input_key                              //
    ////////////////////////////////////////////////////////////////////////////
    assign  input_key   =   key_counter==4'd1 ? key[255:224] :               //��Կ���32λ
                            key_counter==4'd2 ? key[223:192] :
                            key_counter==4'd3 ? key[191:160] :
                            key_counter==4'd4 ? key[159:128] :
                            key_counter==4'd5 ? key[127:096] :
                            key_counter==4'd6 ? key[095:064] :
                            key_counter==4'd7 ? key[063:032] :
                            key_counter==4'd8 ? key[031:000] : 32'b0;
                            
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)  
            key_counter <=  4'b0;
        else if(key_counter==4'd8)
            key_counter <=  4'b0;
        else if((start_posedge && key_counter==4'd0) || key_counter != 4'd0 )
            key_counter <=  key_counter + 1'b1;
        else
            key_counter <=  key_counter;
    end
    
    AES_IP_top_design_by_dong   u_AES_IP_top_design_by_dong(
    .clk                    (clk),
    .rst_n                  (rst_n),
    .start                  (start_posedge),                      //start signal would be high for 1 cycle,early than input_text and key
    .input_text             (w0),
    .input_key              (input_key),
    .mode                   (mode_of_encryption_or_decryption),                       //0 means encryption, 1 means decryption
    .key_width              (key_width),                  //2'b00 means 128bit, 2'b01 means 192bit, 2'b10 means 256bit
    
    .done                   (done),
    .output_text            (output_text_of_AES)
    );
 */   
endmodule
