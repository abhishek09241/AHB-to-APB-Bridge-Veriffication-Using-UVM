`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.01.2025 02:35:26
// Design Name: APB Master
// Module Name: APB_MASTER
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: APB Master implementation for read/write operations
// 
//////////////////////////////////////////////////////////////////////////////////

module APB_MASTER(
                    // Global signals
                    input  Presetn,           // Active-low reset
                    input  Pclk,              // Clock signal
                    
                    // Controller input
                    input [32:0] addr_temp,  // Address and write/read control
                    input [31:0] data_temp,  // Data to write
                    input [31:0] Prdata,     // Data read from the slave
                    input transfer,          // Transfer request signal
                    input Pready,            // Slave ready signal
                    
                    // Output signals
                    output reg Psel,              // Slave select
                    output reg [31:0] Paddr,      // Address to APB slave
                    output reg [31:0] Pdata,      // Data to write to the slave
                    output reg [31:0] rdata_temp, // Data read from the slave
                    output reg Pwrite,            // Write control signal
                    output reg Penable            // Enable signal
                    );
                    
// State definitions
reg [1:0] present_state, next_state;
parameter IDLE   = 2'b01;
parameter SETUP  = 2'b10;
parameter ENABLE = 2'b11;

// Sequential block for state transitions
always @(posedge Pclk or negedge Presetn) begin
  if (!Presetn)
    present_state <= IDLE;  // Reset to IDLE state
  else
    present_state <= next_state;
end

// Next-state logic
always @(*) begin
  case (present_state)
    IDLE: begin
      if (transfer)
        next_state = SETUP; // Transition to SETUP on transfer request
      else
        next_state = IDLE;
end
    SETUP: begin
    if (Pready)
      next_state = ENABLE; // Always go to ENABLE from SETUP
    else 
      next_state = SETUP;
    end
    ENABLE: begin
      if (Pready) begin
        if (transfer)
          next_state = SETUP; // Stay in transfer loop if transfer is active
        else
          next_state = IDLE;  // Return to IDLE if no transfer
        end else begin
          next_state = ENABLE;   // Wait in ENABLE until Pready is high
        end
      end
    default: next_state = IDLE;    // Default state is IDLE
  endcase
end

// Output logic for each state
always @(posedge Pclk or negedge Presetn) begin
  if (!Presetn) begin
  // Reset all outputs to default values
    Psel       <= 1'b0;
    Penable    <= 1'b0;
    Paddr      <= 32'b0;
    Pdata      <= 32'b0;
    rdata_temp <= 32'b0;
    Pwrite     <= 1'b0;
  end else begin
    case (present_state)
      IDLE: begin
        Psel    <= 1'b0;   // Slave is not selected
        Penable <= 1'b0;   // Disable transactions
      end
      SETUP: begin
        Psel    <= 1'b1;              // Select the slave
        Penable <= 1'b0;              // Disable transactions during setup
        Paddr   <= addr_temp[31:0];   // Set address from addr_temp
        Pwrite  <= addr_temp[32];     // Set write control from addr_temp[32]
      end
      ENABLE: begin
        Penable <= 1'b1;              // Enable transactions
        if (Pready) begin
          if (Pwrite) begin
            Pdata      <= data_temp;  // Write data to slave
            rdata_temp <= 32'b0;      // Clear read data
          end else begin
            rdata_temp <= Prdata;     // Capture read data from slave
            Pdata      <= 32'b0;      // Clear write data
          end
        end
      end
    endcase
  end
end

endmodule
