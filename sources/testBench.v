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
