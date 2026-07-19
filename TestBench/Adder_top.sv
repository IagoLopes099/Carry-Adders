
module Adder_top;
    
    localparam WIDTH_TOP = 4; // modify if you want more bits adder

    Adder_if #( .WIDTH(WIDTH_TOP) ) inter (); // interface

    // in this section, if you want to see a specific test for specific DUT, 
    // you need (or not) to comment the others DUTs
    // otherwise you will see MANY MANY lines of tests LOL.

    // DUT for test
    /*
    generic_adder #( .WIDTH(WIDTH_TOP) ) fa ( // generic adder (fa = full adder)
        .a(inter.in_a), 
        .b(inter.in_b),
        .cin(inter.carry_in),
        .s(inter.out_s),
        .cout(inter.carry_out)
    );
    */

    // DUT Carry-Ripple Adder
    carry_ripple_adder #( .WIDTH(WIDTH_TOP) ) CRA (
        .in_a(inter.in_a),
        .in_b(inter.in_b),
        .in_cin(inter.carry_in),
        .out_sum(inter.out_s),
        .out_cout(inter.carry_out)
    ); 

    // DUT Switched Carry-Ripple Adder
    // DUT Carry-Skip Adder
    // DUT Carry-Lookahead Adder
    // DUT Prefix Adder
    // DUT Carry-Select Adder
    // DUT Carry-Save Adder


    Adder_tb #( .WIDTH(WIDTH_TOP) ) tb (inter); // TestBench

endmodule