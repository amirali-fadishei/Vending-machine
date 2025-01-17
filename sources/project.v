module Counter(input clk, input reset, input enable, output reg [3:0] number);
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            number <= 4'b0000;
        else if (enable && number < 4'b1111)
            number <= number + 1;
    end
endmodule


module money_counter(input clk, input reset, input [1:0] coin, output reg [15:0] total, output reg [3:0] num_500, num_1000, num_2000, num_5000, output reg error);
    wire [3:0] coin_500, coin_1000, coin_2000, cash_5000;

    Counter coin500 (.clk(clk), .reset(reset), .enable(coin == 2'b00), .number(coin_500));
    Counter coin1000 (.clk(clk), .reset(reset), .enable(coin == 2'b01), .number(coin_1000));
    Counter coin2000 (.clk(clk), .reset(reset), .enable(coin == 2'b10), .number(coin_2000));
    Counter cash5000 (.clk(clk), .reset(reset), .enable(coin == 2'b11), .number(cash_5000));

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            total <= 16'b0000000000000000;
            num_500 <= 4'b0000;
            num_1000 <= 4'b0000;
            num_2000 <= 4'b0000;
            num_5000 <= 4'b0000;
            error <= 1'b0;
        end 
        else 
        begin
            // بررسی سکه‌های غیرمعتبر
            if (coin > 2'b11)
                error <= 1'b1;
            else
                error <= 1'b0;

            // بروزرسانی شمارنده‌ها
            num_500 <= coin_500;
            num_1000 <= coin_1000;
            num_2000 <= coin_2000;
            num_5000 <= cash_5000;

            // محاسبه مجموع
            total <= (coin_500 * 16'd500) + (coin_1000 * 16'd1000) + 
                     (coin_2000 * 16'd2000) + (cash_5000 * 16'd5000);
        end
    end
endmodule


module product_enable_generator(input [2:0] product_id, output reg [7:0] product_enable);
    always @(*) 
    begin
        product_enable = 8'b00000000;
        product_enable[product_id] = 1;
    end
endmodule

module binary_compare_with_5 (input [4:0] in_stock_amount,output reg is_equal_to_5,output reg is_greater_than_5,output reg is_less_than_5);
    reg [3:0] five = 4'b0101;

    always @(*) begin
        is_equal_to_5 = 0;
        is_greater_than_5 = 0;
        is_less_than_5 = 0;

        if ((in_stock_amount[3] == five[3]) && (in_stock_amount[2] == five[2]) && 
            (in_stock_amount[1] == five[1]) && (in_stock_amount[0] == five[0])) 
        begin
            is_equal_to_5 = 1;
        end

        else if ((in_stock_amount[3] > five[3]) || 
                 (in_stock_amount[3] == five[3] && in_stock_amount[2] > five[2]) ||
                 (in_stock_amount[3] == five[3] && in_stock_amount[2] == five[2] && in_stock_amount[1] > five[1]) ||
                 (in_stock_amount[3] == five[3] && in_stock_amount[2] == five[2] && in_stock_amount[1] == five[1] && in_stock_amount[0] > five[0]))
        begin
            is_greater_than_5 = 1;
        end

        else begin
            is_less_than_5 = 1;
        end
    end
endmodule

module product_manager(
    input clk,
    input reset,
    input [2:0] product_id,
    input didBuy,
    output reg [4:0] in_stock_amount,
    output reg low_stock,
    output reg error,
    output reg [7:0] product_price
);

    reg [4:0] inventory [7:0];     
    reg [7:0] prices [7:0];         
    parameter LOW_THRESHOLD = 4'b0101; // 5 in binary (threshold for low stock)
    parameter INITIAL_STOCK = 4'b1010; // 10 in binary (initial stock)

    initial begin

        prices[0] = 8'b00001010;
        prices[1] = 8'b00010100;
        prices[2] = 8'b00001111;
        prices[3] = 8'b00011110;
        prices[4] = 8'b00011001;
        prices[5] = 8'b00100011;
        prices[6] = 8'b00101000;
        prices[7] = 8'b00110010;
    end

    wire is_equal_to_5;
    wire is_greater_than_5;
    wire is_less_than_5;

    binary_compare_with_5 compare_with_5 (
        .in_stock_amount(inventory[product_id]),  
        .is_equal_to_5(is_equal_to_5),
        .is_greater_than_5(is_greater_than_5),
        .is_less_than_5(is_less_than_5)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin

            inventory[0] <= INITIAL_STOCK;
            inventory[1] <= INITIAL_STOCK;
            inventory[2] <= INITIAL_STOCK;
            inventory[3] <= INITIAL_STOCK;
            inventory[4] <= INITIAL_STOCK;
            inventory[5] <= INITIAL_STOCK;
            inventory[6] <= INITIAL_STOCK;
            inventory[7] <= INITIAL_STOCK;

            low_stock <= 0;
            in_stock_amount <= INITIAL_STOCK;
            error <= 0;
            product_price <= 8'd0;
        end else if (didBuy) begin
            if (product_id >= 8) begin
                error <= 1;  
                in_stock_amount <= 0;
                product_price <= 8'd0;
            end else if (inventory[product_id] == 0) begin
                error <= 1;  
                in_stock_amount <= inventory[product_id];
                product_price <= 8'd0;
            end else begin
                inventory[product_id] <= inventory[product_id] - 1;
                in_stock_amount <= inventory[product_id] - 1;
                product_price <= prices[product_id];

                if (is_less_than_5) begin
                    low_stock <= 1; 
                end else begin
                    low_stock <= 0;
                end

                error <= 0;
            end
        end
    end
endmodule

module Display(
    input clk,
    input reset,
    input [1:0] state, 
    input [15:0] total_money, 
    input [7:0] product_price, 
    input [3:0] product_count, 
    input [2:0] product_code, 
    input error, 
    input low_stock
);

    parameter IDLE = 2'b00;
    parameter SELECT = 2'b01;
    parameter PAY = 2'b10;
    parameter DISPENSE = 2'b11;

    always @(posedge clk or posedge reset)
    begin
        if (reset) 
            $display("Ready for Input");
        else if (error) 
        begin

            if (product_code >= 8) 
                $display("Error: Invalid Product ID %0d", product_code);
            else if (low_stock) 
                $display("Error: Low Stock Alert for Product %0d", product_code);
            else 
                $display("Error: Unknown Error Occurred");
        end 
        else if (low_stock) 
            $display("Low Stock Alert for Product %0d", product_code);
        else 
        begin
            case (state)
                IDLE: 
                    $display("Ready for Input");
                SELECT: 
                    $display("Select Prod: ID=%0d", product_code);
                PAY: 
                    $display("Total Money: %0d | Product Price: %0d", total_money, product_price);
                DISPENSE: 
                    $display("Dispense Prod ID=%0d", product_code);
                default: 
                    $display("Unknown State");
            endcase
        end
    end
endmodule

module fsm(
    input clk,
    input reset,
    input money_validation,
    input is_product_selected,
    input is_enough_money,
    output reg [1:0] state,
    output reg enable_payment,
    output reg enable_dispense
);

    parameter IDLE = 2'b00, SELECT = 2'b01, PAY = 2'b10, DISPENSE = 2'b11;

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            state <= IDLE;  
        else 
        begin
            case (state)
                IDLE: if (money_validation) state <= SELECT;  
                SELECT: if (is_product_selected) state <= PAY; 
                PAY: if (is_enough_money) state <= DISPENSE;  
                DISPENSE: state <= IDLE;  
            endcase
        end
    end

    always @(*) 
    begin
        case (state)
            IDLE: begin enable_payment = 0; enable_dispense = 0; end
            SELECT: begin enable_payment = 0; enable_dispense = 0; end
            PAY: begin enable_payment = 1; enable_dispense = 0; end
            DISPENSE: begin enable_payment = 0; enable_dispense = 1; end
            default: begin enable_payment = 0; enable_dispense = 0; end
        endcase
    end
endmodule

module comparator_10 (input [3:0] product_count, output reg is_greater_than_10);
    reg a, b, c, d;

    always @(*) begin
        a = (product_count[3] & 1'b1);
        b = (product_count[2] & 1'b0);
        c = (product_count[1] & 1'b1);
        d = (product_count[0] & 1'b0);
        if (a | b | c | d)
            is_greater_than_10 = 1;
        else
            is_greater_than_10 = 0;
    end
endmodule

module inteligent_discount (input [15:0] real_amount, input [3:0] product_count, output reg [15:0] discounted_amount);
    wire is_greater_than_10;
    wire [15:0] multiplied_by_9;
    wire [15:0] approx_divided_by_10;

    comparator_10 cmp (
        .product_count(product_count),
        .is_greater_than_10(is_greater_than_10)
    );

    assign multiplied_by_9 = real_amount + (real_amount << 3);

    assign approx_divided_by_10 = (multiplied_by_9 + (multiplied_by_9 >> 1) + (multiplied_by_9 >> 2) + (multiplied_by_9 >> 3)) >> 3;

    always @(*) begin
        if (is_greater_than_10) begin
            discounted_amount = approx_divided_by_10;
        end else begin
            discounted_amount = real_amount;
        end
    end
endmodule

module feedback_storage(
    input clk,
    input reset,
    input [2:0] product_id,
    input [2:0] feedback,
    output reg error,
    output reg [2:0] stored_feedback_0,
    output reg [2:0] stored_feedback_1,
    output reg [2:0] stored_feedback_2,
    output reg [2:0] stored_feedback_3,
    output reg [2:0] stored_feedback_4,
    output reg [2:0] stored_feedback_5,
    output reg [2:0] stored_feedback_6,
    output reg [2:0] stored_feedback_7
);

    reg [2:0] stored_feedback [7:0];
    integer i;

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            for (i = 0; i < 8; i = i + 1)
                stored_feedback[i] <= 3'b000;
            error <= 0;
        end 
        else 
        begin
            if (feedback >= 3'b001 && feedback <= 3'b101 && product_id < 8) 
            begin
                stored_feedback[product_id] <= feedback;
                error <= 0;
            end 
            else 
            begin
                error <= 1;
            end
        end
    end

    always @(*) 
    begin
        stored_feedback_0 = stored_feedback[0];
        stored_feedback_1 = stored_feedback[1];
        stored_feedback_2 = stored_feedback[2];
        stored_feedback_3 = stored_feedback[3];
        stored_feedback_4 = stored_feedback[4];
        stored_feedback_5 = stored_feedback[5];
        stored_feedback_6 = stored_feedback[6];
        stored_feedback_7 = stored_feedback[7];
    end
endmodule

module tb_money_counter;

    reg clk;
    reg reset;
    reg [1:0] coin; // The coin input will simulate the type of coin being inserted
    wire [15:0] total;
    wire [3:0] num_500, num_1000, num_2000, num_5000;
    wire error;

    // Instantiate the money_counter module
    money_counter uut (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .total(total),
        .num_500(num_500),
        .num_1000(num_1000),
        .num_2000(num_2000),
        .num_5000(num_5000),
        .error(error)
    );

    // Clock generation
    always
    begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 0;

        reset = 1;
        #10 reset = 0;
        
        $display("Inserting 500 coin...");
        coin = 2'b00;
        #10;
        $display("Total: %d, Num 500: %d, Num 1000: %d, Num 2000: %d, Num 5000: %d, Error: %b", total, num_500, num_1000, num_2000, num_5000, error);
        
        // Insert 1000 coin
        $display("Inserting 1000 coin...");
        coin = 2'b01; // 1000 coin
        #10;
        $display("Total: %d, Num 500: %d, Num 1000: %d, Num 2000: %d, Num 5000: %d, Error: %b", total, num_500, num_1000, num_2000, num_5000, error);
        
        // Insert 2000 coin
        $display("Inserting 2000 coin...");
        coin = 2'b10; // 2000 coin
        #10;
        $display("Total: %d, Num 500: %d, Num 1000: %d, Num 2000: %d, Num 5000: %d, Error: %b", total, num_500, num_1000, num_2000, num_5000, error);
        
        // Insert 5000 coin
        $display("Inserting 5000 coin...");
        coin = 2'b11; // 5000 coin
        #10;
        $display("Total: %d, Num 500: %d, Num 1000: %d, Num 2000: %d, Num 5000: %d, Error: %b", total, num_500, num_1000, num_2000, num_5000, error);
        
        // Insert an invalid coin type
        $display("Inserting invalid coin...");
        coin = 2'bXX; // Invalid coin type
        #10;
        $display("Total: %d, Num 500: %d, Num 1000: %d, Num 2000: %d, Num 5000: %d, Error: %b", total, num_500, num_1000, num_2000, num_5000, error);
        
        $finish;
    end

endmodule

