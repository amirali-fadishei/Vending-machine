module Counter(input clk, input reset, input enable, output reg [3:0] number);

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            number <= 4'b0000;
        else if (enable) 
            number <= number + 1;
    end

endmodule

module money_counter(input clk, input reset, input [1:0] coin, output reg [15:0] total, output reg [3:0] num_500, num_1000, num_2000, num_5000);

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
        end 
        else 
        begin
            num_500 <= coin_500;
            num_1000 <= coin_1000;
            num_2000 <= coin_2000;
            num_5000 <= cash_5000;
            total <= (coin_500 * 500) + (coin_1000 * 1000) + 
                     (coin_2000 * 2000) + (cash_5000 * 5000);
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

module product_manager(input clk, input reset, input [2:0] product_id, input didBuy, output reg [4:0] in_stock_amount, output reg low_stock);

    reg [4:0] inventory [7:0];
    wire [4:0] decremented_value;
    wire comparison_result;

    parameter LOW_THRESHOLD = 5'b00101;

    always @(posedge reset) 
    begin
        integer i;
        for (i = 0; i < 8; i = i + 1) 
            inventory[i] <= 5'b01010;
    end

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            low_stock <= 0;
            in_stock_amount <= 0;
        end 
        else if (didBuy && product_id < 8 && inventory[product_id] > 0) 
        begin
            inventory[product_id] <= inventory[product_id] - 1;
            in_stock_amount <= inventory[product_id] - 1;
            low_stock <= (inventory[product_id] - 1 <= LOW_THRESHOLD);
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


