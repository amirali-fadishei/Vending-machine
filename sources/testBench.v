module tb_MoneyInput;

    reg clock;
    reg reset;
    reg [3:0] money_type;
    wire [3:0] error;
    wire [15:0] total;
    wire [7:0] num_500;
    wire [7:0] num_1000;
    wire [7:0] num_2000;
    wire [7:0] num_5000;

    MoneyInput test (.clock(clock), .reset(reset), .money_type(money_type), .error(error), .total(total), .num_500(num_500), .num_1000(num_1000), .num_2000(num_2000), .num_5000(num_5000));
    always 
    begin
        #5 clock = ~clock;  
    end

    initial 
    begin
        clock = 0;
        reset = 0;
        money_type = 4'b0000;

        reset = 1;
        #10;
        reset = 0;

        $display("Test: Adding 500 coin");
        money_type = 4'b0001; 
        #10;
        $display("Total: %d, number of 500: %d", total, num_500);

        $display("Test: Adding 1000 coin");
        money_type = 4'b0010; 
        #10;
        $display("Total: %d, number of 1000: %d", total, num_1000);

        $display("Test: Adding 2000 coin");
        money_type = 4'b0100; 
        #10;
        $display("Total: %d, number of 2000: %d", total, num_2000);

        $display("Test: Adding 5000 cash");
        money_type = 4'b1000; 
        #10;
        $display("Total: %d, number of 5000: %d", total, num_5000);
        
        $display("Test: Invalid Money Type");
        money_type = 4'b1111; 
        #10;
        $display("Error: %b", error);
        
        $finish;
    end
endmodule