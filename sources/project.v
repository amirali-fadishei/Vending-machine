module money_counter(input clk, input reset, input [1:0] coin, output reg [15:0] total);

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            total <= 0;
        end 
        else 
        begin
            case (coin)
                2'b00: total <= total + 500;
                2'b01: total <= total + 1000;
                2'b10: total <= total + 2000;
                2'b11: total <= total + 5000;
                default: total <= total;
            endcase
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

module product_manager(input clk, input reset, input [2:0] product_id, input didBuy, output reg [7:0] in_stock_amount, output reg low_stock);

    reg [7:0] inventory [7:0];

    initial 
    begin
        inventory[0] = 10;
        inventory[1] = 10;
        inventory[2] = 10;
        inventory[3] = 10;
        inventory[4] = 10;
        inventory[5] = 10;
        inventory[6] = 10;
        inventory[7] = 10;
    end

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            low_stock <= 0;
        end 
        else if (didBuy) 
        begin
            if (inventory[product_id] > 0) 
            begin
                inventory[product_id] <= inventory[product_id] - 1;
                if (inventory[product_id] <= 5) 
                begin
                    low_stock <= 1;
                end 
                else 
                begin
                    low_stock <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            in_stock_amont <= 0;
        end
        else 
        begin
            in_stock_amont <= inventory[product_id];
        end
    end

endmodule

module fsm(input clk, input reset, input money_validation, input is_product_selected, input is_enough_money, output reg [1:0] state);

    parameter IDLE = 2'b00, SELECT = 2'b01, PAY = 2'b10, DISPENSE = 2'b11;

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            state <= IDLE;
        end 
        else 
        begin
            case (state)
                IDLE: 
                begin
                    if (money_validation) 
                    begin
                        state <= SELECT;
                    end
                end

                SELECT: 
                begin
                    if (is_product_selected) 
                    begin
                        state <= PAY;
                    end
                end

                PAY: 
                begin
                    if (is_enough_money) 
                    begin
                        state <= DISPENSE;
                    end
                end

                DISPENSE: 
                begin
                    state <= IDLE;
                end

                default:
                    state <= IDLE;
            endcase
        end
    end

endmodule

module inteligent_discount(input [15:0] real_amount, input [3:0] product_count, output reg [15:0] discounted_amount);

    reg [15:0] discount;

    always @(*) 
    begin
        if (product_count > 10) 
        begin

            // کامنت های این بخش بعدا باید حذف شود
            // سیستم تخفیف با گیت های منطقی پیاده سازی شود
            // چرا به جای نود درصد، هفتاد و پنج درصد؟
            // Calculate 90% of real_amount using binary operations
            discount = (real_amount >> 1) + (real_amount >> 2); // 50% + 25% = 75%
            discounted_amount = real_amount - discount;
        end 
        else 
        begin
            discounted_amount = real_amount;
        end
    end
endmodule

module feedback_storage(input clk, input reset, input [2:0] product_id, input [2:0] feedback, output reg [2:0] stored_feedback_0, output reg [2:0] stored_feedback_1, output reg [2:0] stored_feedback_2, output reg [2:0] stored_feedback_3, output reg [2:0] stored_feedback_4, output reg [2:0] stored_feedback_5, output reg [2:0] stored_feedback_6, output reg [2:0] stored_feedback_7);

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            stored_feedback_0 <= 0;
            stored_feedback_1 <= 0;
            stored_feedback_2 <= 0;
            stored_feedback_3 <= 0;
            stored_feedback_4 <= 0;
            stored_feedback_5 <= 0;
            stored_feedback_6 <= 0;
            stored_feedback_7 <= 0;
        end 
        else 
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

endmodule


// Additional modules such as display can be implemented similarly.




//tb

module vending_machine_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [1:0] coin;
    reg [2:0] product_id;
    reg didBuy;
    reg money_validation;
    reg is_product_selected;
    reg is_enough_money;
    reg [3:0] product_count;
    reg [2:0] feedback;

    // Outputs
    wire [15:0] total;
    wire [7:0] product_enable;
    wire [7:0] in_stock_amont;
    wire low_stock;
    wire [1:0] state;
    wire [15:0] discounted_amount;
    // !! I couldent work with array in verilog !!
    wire [2:0] stored_feedback_0;
    wire [2:0] stored_feedback_1;
    wire [2:0] stored_feedback_2;
    wire [2:0] stored_feedback_3;
    wire [2:0] stored_feedback_4;
    wire [2:0] stored_feedback_5;
    wire [2:0] stored_feedback_6;
    wire [2:0] stored_feedback_7;

    // Instantiate the modules
    money_counter mc (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .total(total)
    );

    product_enable_generator peg (
        .product_id(product_id),
        .product_enable(product_enable)
    );

    product_manager pm (
        .clk(clk),
        .reset(reset),
        .product_id(product_id),
        .didBuy(didBuy),
        .in_stock_amont(in_stock_amont),
        .low_stock(low_stock)
    );

    fsm fsm_inst (
        .clk(clk),
        .reset(reset),
        .money_validation(money_validation),
        .is_product_selected(is_product_selected),
        .is_enough_money(is_enough_money),
        .state(state)
    );

    inteligent_discount id (
        .real_amount(total),
        .product_count(product_count),
        .discounted_amount(discounted_amount)
    );

    feedback_storage fs (
        .clk(clk),
        .reset(reset),
        .product_id(product_id),
        .feedback(feedback),
        .stored_feedback_0(stored_feedback_0),
        .stored_feedback_1(stored_feedback_1),
        .stored_feedback_2(stored_feedback_2),
        .stored_feedback_3(stored_feedback_3),
        .stored_feedback_4(stored_feedback_4),
        .stored_feedback_5(stored_feedback_5),
        .stored_feedback_6(stored_feedback_6),
        .stored_feedback_7(stored_feedback_7)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Generate clock with 10ns period
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        coin = 2'b00; // Insert 500
        product_id = 3'b000; // Select product 0
        didBuy = 0;
        money_validation = 0;
        is_product_selected = 0;
        is_enough_money = 0;
        product_count = 4'd5; // Less than 10 products
        feedback = 3'b001; // Feedback rating: 1

        // Apply reset
        reset = 1;
        #10;
        reset = 0;

        // Test money counter (insert coins)
        coin = 2'b00; // Insert 500
        #10;
        coin = 2'b01; // Insert 1000
        #10;
        coin = 2'b10; // Insert 2000
        #10;
        coin = 2'b11; // Insert 5000
        #10;

        // Check total amount
        $display("Total Amount: %d", total);

        // Test product selection (select product 0)
        product_id = 3'b000;
        is_product_selected = 1;
        #10;
        is_product_selected = 0;
        
        // Test if enough money
        is_enough_money = 1;
        #10;
        is_enough_money = 0;

        // Simulate a purchase (didBuy)
        didBuy = 1;
        #10;
        didBuy = 0;

        // Check if product is dispensed and stock is updated
        $display("Product 0 Stock after purchase: %d", in_stock_amont);
        $display("Low Stock: %d", low_stock);

        // Test discount system
        product_count = 4'd15; // More than 10 products for discount
        #10;
        $display("Discounted Amount: %d", discounted_amount);

        // Test feedback storage (product 0 gets feedback)
        feedback = 3'b011; // Feedback rating: 3
        #10;
        $display("Stored Feedback for Product 0: %d", stored_feedback_0);

        // Test FSM state transitions
        money_validation = 1;
        #10;
        $display("FSM State: %b", state); // Check FSM state

        // End simulation
        $finish;
    end

endmodule