`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.01.2025 03:03:12
// Design Name: 
// Module Name: tb_APB_MASTER
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


module tb_APB_MASTER;
// Global signals
reg Presetn;
reg Pclk;

//  Controller input
reg [32:0] addr_temp;
reg [31:0] data_temp;
reg [31:0] Prdata;
reg transfer;
reg Pready;

wire Psel;
wire [31:0] Paddr;
wire [31:0] Pdata;
wire [31:0] rdata_temp;
wire Pwrite;
wire Penable;

// Instantiate the DUT (Device Under Test)
APB_MASTER DUT (
    .Presetn(Presetn),
    .Pclk(Pclk),
    .addr_temp(addr_temp),
    .data_temp(data_temp),
    .Prdata(Prdata),
    .transfer(transfer),
    .Pready(Pready),
    .Psel(Psel),
    .Paddr(Paddr),
    .Pdata(Pdata),
    .rdata_temp(rdata_temp),
    .Pwrite(Pwrite),
    .Penable(Penable)
);

// Clock generation
initial begin
  Pclk = 0;
  forever #5 Pclk = ~Pclk;  // Generate a clock with a period of 10ns
end

// Test sequence
initial begin
  // Initialize inputs
  Presetn = 0;
  addr_temp = 33'b0;
  data_temp = 32'b0;
  Prdata = 32'b0;
  transfer = 0;
  Pready = 0;
    
  // Apply reset
  #10 Presetn = 1;
    
  // Test 1: Write operation
  #10 transfer = 1;                     // Begin transfer
  addr_temp = {1'b1, 32'hA000_0000};    // Set write operation and address
  data_temp = 32'hDEADBEEF;             // Data to write
  Pready = 1;                           // Set Pready high (slave ready)

  // Wait for one transfer cycle
  #20 transfer = 0;                     // End transfer

  // Test 2: Read operation
  #10 transfer = 1;                     // Begin transfer
  addr_temp = {1'b0, 32'hA000_0004};    // Set read operation and address
  Prdata = 32'h12345678;                // Data available from slave
  Pready = 1;                           // Set Pready high (slave ready)

  // Wait for one transfer cycle
  #20 transfer = 0;                     // End transfer

  // Test 3: No transfer
  #10 transfer = 0;                     // No transfer signal
  addr_temp = 33'b0;                    // Clear address
  data_temp = 32'b0;                    // Clear data

  // End simulation
  #50 $finish;
end

// Monitor outputs for debugging
initial begin
  $monitor("Time = %0t | Presetn = %b | Pclk = %b | transfer = %b | Psel = %b | Paddr = 0x%h | Pdata = 0x%h | rdata_temp = 0x%h | Pwrite = %b | Penable = %b", 
  $time, Presetn, Pclk, transfer, Psel, Paddr, Pdata, rdata_temp, Pwrite, Penable);
end

endmodule
