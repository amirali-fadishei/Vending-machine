module Counter(input clk, input reset, input enable, output reg [3:0] number);

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            number <= 4'b0000;
        else if (enable && number < 4'b1111)
            number <= number + 1;
    end

endmodule

module money_counter(input clk, input reset, input [1:0] coin, output reg [15:0] total, 
                     output reg [3:0] num_500, num_1000, num_2000, num_5000, output reg error);

    wire [3:0] coin_500, coin_1000, coin_2000, cash_5000;

    Counter coin500 (.clk(clk), .reset(reset), .enable(coin == 2'b00), .number(coin_500));
    Counter coin1000 (.clk(clk), .reset(reset), .enable(coin == 2'b01), .number(coin_1000));
    Counter coin2000 (.clk(clk), .reset(reset), .enable(coin == 2'b10), .number(coin_2000));
    Counter cash5000 (.clk(clk), .reset(reset), .enable(coin == 2'b11), .number(cash_5000));

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            total <= 16'b0;
            num_500 <= 4'b0;
            num_1000 <= 4'b0;
            num_2000 <= 4'b0;
            num_5000 <= 4'b0;
            error <= 1'b0;
        end 
        else 
        begin
            num_500 <= coin_500;
            num_1000 <= coin_1000;
            num_2000 <= coin_2000;
            num_5000 <= cash_5000;

            total <= (coin_500 * 16'd500) + (coin_1000 * 16'd1000) + 
                     (coin_2000 * 16'd2000) + (cash_5000 * 16'd5000);

            if (coin > 2'b11)
                error <= 1'b1;
            else
                error <= 1'b0;
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

module product_manager(input clk, input reset, input [2:0] product_id, 
    input didBuy, 
    output reg [3:0] in_stock_amount_0, output reg [3:0] in_stock_amount_1, 
    output reg [3:0] in_stock_amount_2, output reg [3:0] in_stock_amount_3, 
    output reg [3:0] in_stock_amount_4, output reg [3:0] in_stock_amount_5, 
    output reg [3:0] in_stock_amount_6, output reg [3:0] in_stock_amount_7, 
    output reg low_stock, 
    output reg error, 
    output reg [7:0] product_price
);

    reg [4:0] inventory [7:0]; // Array for product inventory
    reg [7:0] prices [7:0];    // Array for product prices
    parameter LOW_THRESHOLD = 5'b00101; // 5
    parameter INITIAL_STOCK = 5'b01010; // 10

    initial 
    begin
        prices[0] = 8'b00001010; //  10$
        prices[1] = 8'b00010100; //  20$
        prices[2] = 8'b00001111; //  15$
        prices[3] = 8'b00011110; //  30$
        prices[4] = 8'b00011001; //  25$
        prices[5] = 8'b00100011; //  35$
        prices[6] = 8'b00101000; //  40$
        prices[7] = 8'b00110010; //  50$
    end

    wire [7:0] product_enable;
    product_enable_generator enable_gen (
        .product_id(product_id),
        .product_enable(product_enable)
    );

    integer i;
    always @(posedge reset) 
    begin
        // Initialize inventory and stock amounts
        for (i = 0; i < 8; i = i + 1) 
        begin
            inventory[i] = INITIAL_STOCK;
        end
        // Set stock amounts for individual products
        in_stock_amount_0 <= INITIAL_STOCK;
        in_stock_amount_1 <= INITIAL_STOCK;
        in_stock_amount_2 <= INITIAL_STOCK;
        in_stock_amount_3 <= INITIAL_STOCK;
        in_stock_amount_4 <= INITIAL_STOCK;
        in_stock_amount_5 <= INITIAL_STOCK;
        in_stock_amount_6 <= INITIAL_STOCK;
        in_stock_amount_7 <= INITIAL_STOCK;
    end

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            low_stock <= 0;
            error <= 0;
            product_price <= 8'd0;
        end 
        else if (didBuy) 
        begin
            if (product_id >= 8) 
            begin
                error <= 1;
            end 
            else if (inventory[product_id] == 0) 
            begin
                error <= 1;
            end 
            else 
            begin
                inventory[product_id] <= inventory[product_id] - 1;
                // Update stock amounts for each individual product
                case (product_id)
                    3'd0: in_stock_amount_0 <= inventory[0];
                    3'd1: in_stock_amount_1 <= inventory[1];
                    3'd2: in_stock_amount_2 <= inventory[2];
                    3'd3: in_stock_amount_3 <= inventory[3];
                    3'd4: in_stock_amount_4 <= inventory[4];
                    3'd5: in_stock_amount_5 <= inventory[5];
                    3'd6: in_stock_amount_6 <= inventory[6];
                    3'd7: in_stock_amount_7 <= inventory[7];
                endcase
                product_price <= prices[product_id];
                low_stock <= (inventory[product_id] - 1 <= LOW_THRESHOLD);
                error <= 0;
            end
        end
    end
endmodule

module Display(
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

    always @(*) 
    begin
        if (error) 
        begin
            $display("Error Detected!");
        end 
        else if (low_stock) 
        begin
            $display("Low Stock Alert!");
        end 
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


module fsm(input clk, input reset, input money_validation, input is_product_selected, 
           input is_enough_money, output reg [1:0] state, output reg enable_payment, output reg enable_dispense);

    parameter IDLE = 2'b00, SELECT = 2'b01, PAY = 2'b10, DISPENSE = 2'b11;

    // مقداردهی اولیه برای خروجی‌ها
    initial begin
        state = IDLE;
        enable_payment = 0;
        enable_dispense = 0;
    end

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

    always @(state) 
    begin
        case (state)
            IDLE: begin 
                enable_payment = 0; 
                enable_dispense = 0; 
            end
            SELECT: begin 
                enable_payment = 0; 
                enable_dispense = 0; 
            end
            PAY: begin 
                enable_payment = 1; 
                enable_dispense = 0; 
            end
            DISPENSE: begin 
                enable_payment = 0; 
                enable_dispense = 1; 
            end
        endcase
    end

endmodule



module inteligent_discount(input [15:0] real_amount, input [3:0] product_count, output reg [15:0] discounted_amount);

    wire [15:0] product_count_comparison;
    wire [15:0] multiplied_by_9;
    wire [15:0] approx_divided_by_10;

    assign product_count_comparison = (product_count > 4'b1010) ? 1 : 0;

    assign multiplied_by_9 = real_amount + (real_amount << 3);

    assign approx_divided_by_10 = (multiplied_by_9 + (multiplied_by_9 >> 1) + (multiplied_by_9 >> 2) + (multiplied_by_9 >> 3)) >> 3;

    always @(*) 
    begin
        if (product_count_comparison)
        begin
            discounted_amount = approx_divided_by_10;
        end 
        else 
        begin
            discounted_amount = real_amount;
        end
    end

endmodule


module feedback_storage(
    input clk,
    input reset,
    input [2:0] product_id,
    input [2:0] feedback,
    output reg [2:0] stored_feedback_0,
    output reg [2:0] stored_feedback_1,
    output reg [2:0] stored_feedback_2,
    output reg [2:0] stored_feedback_3,
    output reg [2:0] stored_feedback_4,
    output reg [2:0] stored_feedback_5,
    output reg [2:0] stored_feedback_6,
    output reg [2:0] stored_feedback_7
);

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            stored_feedback_0 <= 3'b000;
            stored_feedback_1 <= 3'b000;
            stored_feedback_2 <= 3'b000;
            stored_feedback_3 <= 3'b000;
            stored_feedback_4 <= 3'b000;
            stored_feedback_5 <= 3'b000;
            stored_feedback_6 <= 3'b000;
            stored_feedback_7 <= 3'b000;
        end 
        else 
        begin
            if (feedback >= 3'b001 && feedback <= 3'b101 && product_id < 8)
            begin
                case (product_id)
                    3'd0: stored_feedback_0 <= feedback;
                    3'd1: stored_feedback_1 <= feedback;
                    3'd2: stored_feedback_2 <= feedback;
                    3'd3: stored_feedback_3 <= feedback;
                    3'd4: stored_feedback_4 <= feedback;
                    3'd5: stored_feedback_5 <= feedback;
                    3'd6: stored_feedback_6 <= feedback;
                    3'd7: stored_feedback_7 <= feedback;
                    default: ;
                endcase
            end
        end
    end

endmodule


//*********Testbench*********//

module testbench;

    // ورودی‌ها
    reg clk;
    reg reset;
    reg [1:0] coin;
    reg [2:0] product_id;
    reg didBuy;
    reg [2:0] product_code;
    reg money_validation;
    reg is_product_selected;
    reg is_enough_money;
    reg [3:0] product_count;
    reg [2:0] feedback;
        
    // خروجی‌ها
    wire [15:0] total_money;
    wire [7:0] product_price;
    wire [3:0] product_count_out;
    wire [3:0] in_stock_amount_0;
    wire [3:0] in_stock_amount_1;
    wire [3:0] in_stock_amount_2;
    wire [3:0] in_stock_amount_3;
    wire [3:0] in_stock_amount_4;
    wire [3:0] in_stock_amount_5;
    wire [3:0] in_stock_amount_6;
    wire [3:0] in_stock_amount_7;
    wire low_stock;
    wire error;
    wire [127:0] display;
    wire [1:0] state;
    wire enable_payment;
    wire enable_dispense;
        
    // ماژول‌ها
    money_counter mc (
        .clk(clk), 
        .reset(reset), 
        .coin(coin), 
        .total(total_money), 
        .num_5000(), 
        .num_1000(), 
        .num_2000(), 
        .num_5000(), 
        .error(error)
    );

    product_manager pm (
        .clk(clk), 
        .reset(reset), 
        .product_id(product_id), 
        .didBuy(didBuy), 
        .in_stock_amount_0(in_stock_amount_0),  // موجودی محصول 0
        .in_stock_amount_1(in_stock_amount_1),  // موجودی محصول 1
        .in_stock_amount_2(in_stock_amount_2),  // موجودی محصول 2
        .in_stock_amount_3(in_stock_amount_3),  // موجودی محصول 3
        .in_stock_amount_4(in_stock_amount_4),  // موجودی محصول 4
        .in_stock_amount_5(in_stock_amount_5),  // موجودی محصول 5
        .in_stock_amount_6(in_stock_amount_6),  // موجودی محصول 6
        .in_stock_amount_7(in_stock_amount_7),  // موجودی محصول 7
        .low_stock(low_stock), 
        .error(error), 
        .product_price(product_price)
    );

    Display display_module (
        .state(state), 
        .total_money(total_money), 
        .product_price(product_price), 
        .product_count(product_count_out), 
        .product_code(product_code), 
        .error(error), 
        .low_stock(low_stock)
    );

    fsm fsm_module (
        .clk(clk), 
        .reset(reset), 
        .money_validation(money_validation), 
        .is_product_selected(is_product_selected), 
        .is_enough_money(is_enough_money), 
        .state(state), 
        .enable_payment(enable_payment), 
        .enable_dispense(enable_dispense)
    );

    inteligent_discount id (
        .real_amount(total_money), 
        .product_count(product_count), 
        .discounted_amount()
    );

    feedback_storage fs (
        .clk(clk), 
        .reset(reset), 
        .product_id(product_id), 
        .feedback(feedback),
        .stored_feedback_0(), 
        .stored_feedback_1(), 
        .stored_feedback_2(), 
        .stored_feedback_3(),
        .stored_feedback_4(), 
        .stored_feedback_5(), 
        .stored_feedback_6(),
        .stored_feedback_7()
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        coin = 2'b00;
        product_id = 3'b000;
        didBuy = 0;
        money_validation = 0;
        is_product_selected = 0;
        is_enough_money = 0;
        product_count = 4'b010;
        feedback = 3'b010;  // Neutral feedback

        // Resetting
        $display("Initial Reset");
        reset = 1;
        #10 reset = 0;
        
        // وارد کردن پول (500) و بررسی وضعیت
        $display("Insert 500 coin");
        coin = 2'b00;  // 500 coin
        #10 coin = 2'b00;
        #10;

        // وارد کردن پول (1000) و بررسی وضعیت
        $display("Insert 1000 coin");
        coin = 2'b01;  // 1000 coin
        #10 coin = 2'b01;
        #10;

        // خرید محصول
        $display("Buying Product ID = 0");
        didBuy = 1;
        #10 didBuy = 0;

        // تغییر وضعیت
        $display("Changing State to SELECT");
        money_validation = 1;
        #10 money_validation = 0;

        $display("Changing State to PAY");
        is_product_selected = 1;
        #10 is_product_selected = 0;

        $display("Changing State to DISPENSE");
        is_enough_money = 1;
        #10 is_enough_money = 0;

        // تکمیل تست
        $display("Test Complete");
        $finish;
    end

    // نمایش مقادیر
    always @ (posedge clk) begin
        $display("Time: %0t | Total Money: %0d | Price: %0d | Display: %s | Error: %b | Low Stock: %b", 
                $time, total_money, product_price, display, error, low_stock);
    end

endmodule
