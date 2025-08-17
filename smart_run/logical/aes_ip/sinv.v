`timescale 1ns / 10ps
module sinv(a,q);
input [3:0] a;
output [3:0] q;

wire a0,a1,a2,a3;
wire [3:0] q;

wire tmpa;
assign a0=a[0];
assign a1=a[1];
assign a2=a[2];
assign a3=a[3];

assign tmpa=a1^a2^a3^a1&a2&a3;

assign q[0]=tmpa^a0^a0&a2^a1&a2^a0&a1&a2;
assign q[1]=a0&a1^a0&a2^a1&a2^a3^a1&a3^a0&a1&a3;
assign q[2]=a0&a1^a2^a0&a2^a3^a0&a3^a0&a2&a3;
assign q[3]=tmpa^a0&a3^a1&a3^a2&a3;

endmodule
