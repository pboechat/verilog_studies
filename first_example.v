module first_example(KEY, LEDR);
  input wire [1:0] KEY;
  output wire [9:0] LEDR;
  
  assign LEDR[0] = KEY[0] & KEY[1];
endmodule
