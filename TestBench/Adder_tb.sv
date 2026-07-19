
module Adder_tb #(
    parameter WIDTH = 4
)(
    Adder_if.TEST adderif
);
    logic [WIDTH:0] temp_sum;
    logic [WIDTH-1:0] exp_s;
    logic exp_c_out;
    
    always @(*) begin : golden_model_adder
        temp_sum = (adderif.in_x + adderif.in_y + adderif.carry_in);

        exp_s = temp_sum[WIDTH-1:0];
        exp_c_out = temp_sum[WIDTH];
    end


    task exp;
        if(adderif.out_s !== exp_s || adderif.carry_out !== exp_c_out) begin
            $display("Error at a time : %0d, X : %b (%d), Y : %b (%d), Carry-in : %b",
                $time,
                adderif.in_x,
                adderif.in_x,
                adderif.in_y,
                adderif.in_y,
                adderif.carry_in
            );

            if(adderif.out_s !== exp_s) begin
                $display("Sum : %b (%d)",
                    adderif.out_s,
                    adderif.out_s
                );

                $display("And should be : %b (%d)", exp_s, exp_s);
            end

            if(adderif.carry_out !== exp_c_out) begin
                $display("Carry-out : %b", adderif.carry_out);
                $display("And should be : %b", exp_c_out);

            end
            $finish;
        end

        if(WIDTH <= 32) begin
            $display("Time : %0d, X : %b (%d), Y : %b (%d), Carry-in : %b, Sum : %b (%d), Carry-out : %b", 
                        $time,
                        adderif.in_x,
                        adderif.in_x,
                        adderif.in_y,
                        adderif.in_y,
                        adderif.carry_in, 
                        adderif.out_s, 
                        adderif.out_s, 
                        adderif.carry_out );
        end 
        else begin
            $display("Time : %0d, X : %d, Y : %d, Carry-in : %b, Sum : %d, Carry-out : %b", 
                        $time,
                        adderif.in_x,
                        adderif.in_y,
                        adderif.carry_in,
                        adderif.out_s,
                        adderif.carry_out 
            );
        end


    endtask

    initial begin
        adderif.in_x = 'b0;
        adderif.in_y = 'b0;
        adderif.carry_in = 1'b0;

        #25;

        repeat (200) begin
            adderif.in_x = $urandom;
            adderif.in_y = $urandom;
            adderif.carry_in = $urandom_range(0,1);
            
            #25;

            exp();

        end

        $display("Test Passed");
        $finish;
    end


endmodule