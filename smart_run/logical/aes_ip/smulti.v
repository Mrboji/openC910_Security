`timescale 1ns / 10ps
module smulti(a,b,q);
input [3:0] a,b;
output [3:0] q;

wire [3:0] a,b;
wire [3:0] q;
wire tmpa,tmpb;

assign tmpa=a[0]^a[3];
assign tmpb=a[2]^a[3];

assign q[0]=a[0]&b[0]^a[3]&b[1]^a[2]&b[2]^a[1]&b[3];
assign q[1]=a[1]&b[0]^tmpa&b[1]^tmpb&b[2]^(a[1]^a[2])&b[3];
assign q[2]=a[2]&b[0]^a[1]&b[1]^tmpa&b[2]^tmpb&b[3];
assign q[3]=a[3]&b[0]^a[2]&b[1]^a[1]&b[2]^tmpa&b[3];

endmodule
