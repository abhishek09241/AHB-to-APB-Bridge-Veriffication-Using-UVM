`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2025 16:42:09
// Design Name: 
// Module Name: memory
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


module memory #(parameter DSIZE = 6,parameter ASIZE = 4,parameter DEPTH = 16)(        
    input       [DSIZE-1:0]   wdata,         
    input       [ASIZE-1:0]   waddr,
    input       [ASIZE-1:0]   raddr,  
    input                     wclk_en,
    input                     wfull,
    input                     wclk, 
    input                     rclk,
    input                     rclk_en,
    input                     rempty,
    output reg  [DSIZE-1:0]   rdata        
      );
      
     // localparam DEPTH = 1 << ASIZE;    //declaring memory locations 
      reg [DSIZE-1:0] mem [0:DEPTH-1];     // initating memory locations

        
        /// performing read operation
        always @(*) 
        begin
         if(rclk_en && !rempty)
           begin
              rdata<=mem[raddr];
           end
         else 
            begin       
               rdata<=0;
            end
        end
        
      
      /// performing write operation 
       always @(posedge wclk)
        begin
                if (wclk_en & !wfull)
                  begin
                      mem[waddr] <= wdata; // Write data
                      $display("mem= %0p,waddr=%h",mem,waddr);
                   end
        end
  endmodule     
