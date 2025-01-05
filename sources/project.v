module Counter(input clock, input reset, input enable, output reg [7:0] number);

    always @(posedge clock or posedge reset) 
    begin
        if (reset) 
        begin
            number <= 8'b0;
        end 
        else if (enable) 
        begin
            number <= number + 1;
        end
    end

endmodule


module MoneyInput(input clock, input reset, input [3:0] money_type, output reg [3:0] error, output reg [15:0] total, output reg [7:0] num_500, output reg [7:0] num_1000, output reg [7:0] num_2000, output reg [7:0] num_5000);

    wire [7:0] coin_500;
    wire [7:0] coin_1000;
    wire [7:0] coin_2000;
    wire [7:0] cash_5000;

    Counter coin500 (.clock(clock), .reset(reset), .enable(money_type == 4'b0001), .number(coin_500));
    Counter coin1000 (.clock(clock), .reset(reset), .enable(money_type == 4'b0010), .number(coin_1000));
    Counter coin2000 (.clock(clock), .reset(reset), .enable(money_type == 4'b0100), .number(coin_2000));
    Counter cash5000 (.clock(clock), .reset(reset), .enable(money_type == 4'b1000), .number(cash_5000));

    always @(posedge clock or posedge reset) 
    begin
        if (reset) 
        begin
            total <= 16'b0;
            error <= 4'b0;
            num_500 <= 8'b0;
            num_1000 <= 8'b0;
            num_2000 <= 8'b0;
            num_5000 <= 8'b0;
        end 
        else 
        begin
            case (money_type)
                4'b0001: 
                begin
                    total <= total + 500;
                    num_500 <= coin_500;
                    error <= 4'b0;
                end
                4'b0010: 
                begin
                    total <= total + 1000;
                    num_1000 <= coin_1000;
                    error <= 4'b0;
                end
                4'b0100: 
                begin
                    total <= total + 2000;
                    num_2000 <= coin_2000;
                    error <= 4'b0;
                end
                4'b1000: 
                begin
                    total <= total + 5000;
                    num_5000 <= cash_5000;
                    error <= 4'b0;
                end
                default: 
                begin
                    error <= 4'b1111; 
                    $display("Error: Invalid Money Type!");
                end
            endcase
        end
    end
endmodule

