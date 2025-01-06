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
                    $display("Error: Invalid Money Type!",num_500);
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

module decoderSelector(input [2:0] address, output reg [7:0] selectors, output reg [2:0] product_address);

    always @(*) begin
        selectors = 8'b0;
        case (address)
            3'b000: selectors[0] = 1;
            3'b001: selectors[1] = 1;
            3'b010: selectors[2] = 1;
            3'b011: selectors[3] = 1;
            3'b100: selectors[4] = 1;
            3'b101: selectors[5] = 1;
            3'b110: selectors[6] = 1;
            3'b111: selectors[7] = 1;
            default: selectors = 8'b0;
        endcase
        product_address = address;
    end
    
endmodule

module FSM(input clock, input reset, input [2:0] product_address, output reg [15:0] price);

    reg [15:0] price_0, price_1, price_2, price_3, price_4, price_5, price_6, price_7;
    
    initial 
    begin
        price_0 = 16'd500; 
        price_1 = 16'd1000;
        price_2 = 16'd1500;
        price_3 = 16'd2000;
        price_4 = 16'd2500;
        price_5 = 16'd3000;
        price_6 = 16'd3500;
        price_7 = 16'd4000;
    end
    
    always @(posedge clock or posedge reset) 
    begin
        if (reset) 
        begin
            price <= 16'd0;
        end 
        else 
        begin
            case (product_address)
                3'b000: price <= price_0;
                3'b001: price <= price_1;
                3'b010: price <= price_2;
                3'b011: price <= price_3;
                3'b100: price <= price_4;
                3'b101: price <= price_5;
                3'b110: price <= price_6;
                3'b111: price <= price_7;
                default: price <= 16'd0;
            endcase
        end
    end

endmodule

module ProductSelector(input clock, input reset, input [2:0] address, output [15:0] price);
    
    wire [7:0] select;
    wire [2:0] product_address;

    decoderSelector decoder (.address(address), .selectors(select), .product_address(product_address));
    FSM fsm (.clock(clock), .reset(reset), .product_address(product_address), .price(price));

endmodule

module testBench;

    // Inputs
    reg clock;
    reg reset;
    reg [3:0] money_type;
    reg [2:0] address;

    // Outputs
    wire [3:0] error;
    wire [15:0] total;
    wire [7:0] num_500;
    wire [7:0] num_1000;
    wire [7:0] num_2000;
    wire [7:0] num_5000;
    wire [15:0] price;

    // Instantiate the modules
    MoneyInput moneyInput (
        .clock(clock), 
        .reset(reset), 
        .money_type(money_type), 
        .error(error), 
        .total(total), 
        .num_500(num_500), 
        .num_1000(num_1000), 
        .num_2000(num_2000), 
        .num_5000(num_5000)
    );

    ProductSelector productSelector (
        .clock(clock), 
        .reset(reset), 
        .address(address), 
        .price(price)
    );

    // Clock generation
    always #5 clock = ~clock;

    initial begin
        // Initialize Inputs
        clock = 0;
        reset = 1;
        money_type = 0;
        address = 0;

        // Wait for global reset
        #10;
        reset = 0;

        // Test MoneyInput module
        money_type = 4'b0001; // Insert 500
        #10;
        money_type = 4'b0010; // Insert 1000
        #10;
        money_type = 4'b0100; // Insert 2000
        #10;
        money_type = 4'b1000; // Insert 5000
        #10;
        money_type = 4'b1111; // Invalid money type
        #10;

        // Test ProductSelector module
        address = 3'b000; // Select product 0
        #10;
        address = 3'b001; // Select product 1
        #10;
        address = 3'b010; // Select product 2
        #10;
        address = 3'b011; // Select product 3
        #10;
        address = 3'b100; // Select product 4
        #10;
        address = 3'b101; // Select product 5
        #10;
        address = 3'b110; // Select product 6
        #10;
        address = 3'b111; // Select product 7
        #10;

        // Finish simulation
        $finish;
    end

endmodule







