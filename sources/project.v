module Counter (
    input clock,
    input reset,
    input enable,
    output [3:0] number
);
  reg [3:0] next_number;
  always @(posedge clock or posedge reset) begin
    if (reset) next_number <= 4'b0000;
    else if (enable && next_number < 4'b1111) next_number <= next_number + 1;
  end
  assign number = next_number;
endmodule

module money_counter (
    input clock,
    input reset,
    input [1:0] coin,
    output [15:0] total,
    output [3:0] count_500,
    output [3:0] count_1000,
    output [3:0] count_2000,
    output [3:0] count_5000,
    output error
);
  wire [3:0] coin_500, coin_1000, coin_2000, cash_5000;

  Counter coin500 (
      .clock(clock),
      .reset(reset),
      .enable(coin == 2'b00),
      .number(coin_500)
  );
  Counter coin1000 (
      .clock(clock),
      .reset(reset),
      .enable(coin == 2'b01),
      .number(coin_1000)
  );
  Counter coin2000 (
      .clock(clock),
      .reset(reset),
      .enable(coin == 2'b10),
      .number(coin_2000)
  );
  Counter cash5000 (
      .clock(clock),
      .reset(reset),
      .enable(coin == 2'b11),
      .number(cash_5000)
  );

  assign error = 0;

  assign count_500 = coin_500;
  assign count_1000 = coin_1000;
  assign count_2000 = coin_2000;
  assign count_5000 = cash_5000;

  assign total = (coin_500 * 5) + (coin_1000 * 10) + (coin_2000 * 20) + (cash_5000 * 50);
endmodule

module product_enable_generator (
    input [2:0] product_id,
    output reg [7:0] product_enable
);
  always @(*) 
  begin
    product_enable = 8'b00000000;
    product_enable[product_id] = 1;
  end
endmodule

module comparator_5 (
    input [4:0] in_stock_amount,
    output is_less_than_5
);
  assign is_less_than_5 = (in_stock_amount < 5);
endmodule

module comparator_10 (
    input [3:0] product_count,
    output is_greater_than_10
);
  assign is_greater_than_10 = (product_count > 10);
endmodule

module intelligent_discount (
    input  [15:0] real_amount,
    input  [ 3:0] product_count,
    output [15:0] discounted_amount
);
  wire is_greater_than_10;
  comparator_10 cmp (
      .product_count(product_count),
      .is_greater_than_10(is_greater_than_10)
  );
  wire [15:0] multiplied_by_9;
  wire [15:0] divided_by_10;
  assign multiplied_by_9 = (real_amount << 3) + real_amount;
  assign divided_by_10 = (multiplied_by_9 >> 3) + (multiplied_by_9 >> 4);
  assign discounted_amount = (is_greater_than_10) ? divided_by_10 : real_amount;
endmodule

module decrement_counter (
    input clock,
    input reset,
    input enable,
    output reg [4:0] number
);
  always @(posedge clock or posedge reset) begin
    if (reset) number <= 5'b01010;
    else if (enable && number > 0) number <= number - 1;
  end
endmodule

module increment_counter (
    input clock,
    input reset,
    input enable,
    output reg [4:0] number
);
  always @(posedge clock or posedge reset) begin
    if (reset) number <= 5'b00000;
    else if (enable && number < 5'b01011) number <= number + 1;
  end
endmodule

module product_manager (
    input clock,
    input reset,
    input [2:0] product_id,
    input didBuy,
    input [3:0] quantity,
    output [4:0] in_stock_amount,
    output low_stock,
    output error,
    output [7:0] product_price,
    output reg [15:0] total_price,
    output reg [4:0] product_purchase_count
);
  reg [4:0] inventory[7:0];
  reg [7:0] prices[7:0];
  reg [4:0] purchase_count[7:0];
  reg [15:0] selected_products_total;
  reg [3:0] total_buy_count;
  parameter LOW_THRESHOLD = 5'b00101;
  parameter INITIAL_STOCK = 5'b01010;
  initial begin
    prices[0] = 10;
    prices[1] = 15;
    prices[2] = 20;
    prices[3] = 25;
    prices[4] = 30;
    prices[5] = 35;
    prices[6] = 40;
    prices[7] = 45;
    total_buy_count = 0;
    selected_products_total = 0;
    inventory[0] = INITIAL_STOCK;
    inventory[1] = INITIAL_STOCK;
    inventory[2] = INITIAL_STOCK;
    inventory[3] = INITIAL_STOCK;
    inventory[4] = INITIAL_STOCK;
    inventory[5] = INITIAL_STOCK;
    inventory[6] = INITIAL_STOCK;
    inventory[7] = INITIAL_STOCK;
  end
  wire [4:0] decremented_inventory;
  wire [4:0] incremented_purchase_count;
  wire is_less_than_5;
  decrement_counter inventory_decrement (
      .clock(clock),
      .reset(reset),
      .enable(didBuy && inventory[product_id] > 0 && quantity > 0),
      .number(decremented_inventory)
  );
  increment_counter purchase_increment (
      .clock(clock),
      .reset(reset),
      .enable(didBuy && quantity > 0),
      .number(incremented_purchase_count)
  );
  comparator_5 compare_with_5 (
      .in_stock_amount(inventory[product_id]),
      .is_less_than_5 (is_less_than_5)
  );
  assign low_stock = is_less_than_5;
  assign error = (product_id >= 8 || inventory[product_id] == 0);
  assign product_price = (error) ? 8'd0 : prices[product_id];
  assign in_stock_amount = inventory[product_id];
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      total_buy_count <= 0;
      selected_products_total <= 0;
      purchase_count[0] <= 0;
      purchase_count[1] <= 0;
      purchase_count[2] <= 0;
      purchase_count[3] <= 0;
      purchase_count[4] <= 0;
      purchase_count[5] <= 0;
      purchase_count[6] <= 0;
      purchase_count[7] <= 0;
      total_price <= 0;
    end else if (didBuy && inventory[product_id] > 0) begin
      total_buy_count <= total_buy_count + quantity;
      selected_products_total <= selected_products_total + (prices[product_id] * quantity);
    end
  end
  wire [15:0] discounted_total;
  intelligent_discount discount_logic (
      .real_amount(selected_products_total),
      .product_count(total_buy_count),
      .discounted_amount(discounted_total)
  );
  always @(*) begin
    total_price = discounted_total;
    inventory[product_id] <= decremented_inventory;
    purchase_count[product_id] <= incremented_purchase_count;
    product_purchase_count <= incremented_purchase_count;
  end
endmodule

module fsm (
    input clock,
    input reset,
    input money_validation,
    input is_product_selected,
    input is_enough_money,
    output reg [1:0] state,
    output reg enable_payment,
    output reg enable_dispense
);
  parameter IDLE = 2'b00, SELECT = 2'b01, PAY = 2'b10, DISPENSE = 2'b11;
  reg [1:0] state_next;
  always @(posedge clock or posedge reset) begin
    if (reset) state <= IDLE;
    else state <= state_next;
  end
  always @(*) begin
    case (state)
      IDLE:
      if (money_validation) state_next = SELECT;
      else state_next = IDLE;
      SELECT:
      if (is_product_selected) state_next = PAY;
      else state_next = SELECT;
      PAY:
      if (is_enough_money) state_next = DISPENSE;
      else state_next = PAY;
      DISPENSE: state_next = IDLE;
      default: state_next = IDLE;
    endcase
  end
  always @(*) begin
    enable_payment  = (state == PAY);
    enable_dispense = (state == DISPENSE);
  end
endmodule

module feedback_storage (
    input clock,
    input reset,
    input [2:0] product_id,
    input [2:0] feedback,
    output error,
    output [2:0] stored_feedback_0,
    output [2:0] stored_feedback_1,
    output [2:0] stored_feedback_2,
    output [2:0] stored_feedback_3,
    output [2:0] stored_feedback_4,
    output [2:0] stored_feedback_5,
    output [2:0] stored_feedback_6,
    output [2:0] stored_feedback_7
);
  reg [2:0] stored_feedback[7:0];
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      stored_feedback[0] <= 3'b000;
      stored_feedback[1] <= 3'b000;
      stored_feedback[2] <= 3'b000;
      stored_feedback[3] <= 3'b000;
      stored_feedback[4] <= 3'b000;
      stored_feedback[5] <= 3'b000;
      stored_feedback[6] <= 3'b000;
      stored_feedback[7] <= 3'b000;
    end else if (feedback >= 3'b001 && feedback <= 3'b101 && product_id < 8) begin
      stored_feedback[product_id] <= feedback;
    end
  end
  assign stored_feedback_0 = stored_feedback[0];
  assign stored_feedback_1 = stored_feedback[1];
  assign stored_feedback_2 = stored_feedback[2];
  assign stored_feedback_3 = stored_feedback[3];
  assign stored_feedback_4 = stored_feedback[4];
  assign stored_feedback_5 = stored_feedback[5];
  assign stored_feedback_6 = stored_feedback[6];
  assign stored_feedback_7 = stored_feedback[7];
  assign error = (feedback < 3'b001 || feedback > 3'b101 || product_id >= 8);
endmodule

module display (
    input [15:0] total_money,
    input [ 7:0] product_price,
    input [15:0] total_price,
    input [ 1:0] fsm_state,
    input [ 2:0] product_id,
    input [ 4:0] product_count,
    input [ 4:0] product_purchase_count
);
  always @(*) begin
    case (fsm_state)
      2'b00:   $display("FSM State: IDLE");
      2'b01:   $display("FSM State: SELECT");
      2'b10:   $display("FSM State: PAY");
      2'b11:   $display("FSM State: DISPENSE");
      default: $display("FSM State: IDLE");
    endcase
    $display("Selected Product ID: %d", product_id);
    $display("Product Price: %d", product_price);
    $display("Total Money Inserted: %d", total_money);
    $display("Total Cost: %d", total_price);
    $display("Product Purchase Count: %d", product_purchase_count);
    $display("Total Products Left: %d", product_count);
    $display("");
  end
endmodule

module tb;
  reg clock;
  reg reset;
  reg [1:0] coin;
  wire [15:0] total;
  wire [3:0] count_500, count_1000, count_2000, count_5000;
  wire error;
  reg [2:0] product_id;
  reg didBuy;
  reg [3:0] quantity;
  wire [4:0] in_stock_amount;
  wire low_stock;
  wire error_product;
  wire [7:0] product_price;
  wire [15:0] total_price;
  wire [4:0] product_purchase_count;
  reg money_validation;
  reg is_product_selected;
  reg is_enough_money;
  wire [1:0] state;
  wire enable_payment;
  wire enable_dispense;
  reg [2:0] feedback;
  wire [2:0] stored_feedback_0, stored_feedback_1, stored_feedback_2, stored_feedback_3;
  wire [2:0] stored_feedback_4, stored_feedback_5, stored_feedback_6, stored_feedback_7;
  wire error_feedback;
  money_counter money_counter_inst (
      .clock(clock),
      .reset(reset),
      .coin(coin),
      .total(total),
      .count_500(count_500),
      .count_1000(count_1000),
      .count_2000(count_2000),
      .count_5000(count_5000),
      .error(error)
  );
  product_manager product_manager_inst (
      .clock(clock),
      .reset(reset),
      .product_id(product_id),
      .didBuy(didBuy),
      .quantity(quantity),
      .in_stock_amount(in_stock_amount),
      .low_stock(low_stock),
      .error(error_product),
      .product_price(product_price),
      .total_price(total_price),
      .product_purchase_count(product_purchase_count)
  );
  fsm fsm_inst (
      .clock(clock),
      .reset(reset),
      .money_validation(money_validation),
      .is_product_selected(is_product_selected),
      .is_enough_money(is_enough_money),
      .state(state),
      .enable_payment(enable_payment),
      .enable_dispense(enable_dispense)
  );
  feedback_storage feedback_storage_inst (
      .clock(clock),
      .reset(reset),
      .product_id(product_id),
      .feedback(feedback),
      .error(error_feedback),
      .stored_feedback_0(stored_feedback_0),
      .stored_feedback_1(stored_feedback_1),
      .stored_feedback_2(stored_feedback_2),
      .stored_feedback_3(stored_feedback_3),
      .stored_feedback_4(stored_feedback_4),
      .stored_feedback_5(stored_feedback_5),
      .stored_feedback_6(stored_feedback_6),
      .stored_feedback_7(stored_feedback_7)
  );
  display display_inst (
      .total_money(total),
      .product_price(product_price),
      .total_price(total_price),
      .fsm_state(state),
      .product_id(product_id),
      .product_count(in_stock_amount),
      .product_purchase_count(product_purchase_count)
  );
  always begin
    #5 clock = ~clock;
  end
  initial begin
    clock   = 0;
    reset = 0;
    reset = 1;
    #10;
    reset = 0;
    $display("Cycle 1: Inserting coins...");
    coin = 2'b00;
    #10;
    coin = 2'b00;
    #10;
    coin = 2'b01;
    #10;
    coin = 2'b10;
    #10;
    coin = 2'b11;
    #10;
    coin = 2'bxx;
    #10;
    $display("Total Money: %d, Error: %b", total, error);
    $display("");
    money_validation = 1;
    #10;
    money_validation = 0;
    #10;
    product_id = 3'b001;
    quantity   = 4'b0001;
    $display("Testing Discount - Adding Products...");
    didBuy = 1;
    #10;
    didBuy = 0;
    #10;
    didBuy = 1;
    #10;
    didBuy = 0;
    #10;
    didBuy = 1;
    #10;
    didBuy = 0;
    #10;
    didBuy = 1;
    #10;
    didBuy = 0;
    #10;
    didBuy = 1;
    #10;
    didBuy = 0;
    #10;
    product_id = 3'b001;
    quantity = 4'b0001;
    didBuy = 1;
    #10;
    didBuy = 0;
    #10;
    $display("Total Price with Discount: %d", total_price);
    $display("");
    $display("Low stock detected for product %d: %b", product_id, low_stock);
    $display("");
    feedback = 3'b001;
    #10;
    $display("Stored Feedback for product 1: %d", stored_feedback_1);
    feedback = 3'b111;
    #10;
    $display("Feedback Error: %b", error_feedback);
    is_product_selected = 1;
    #10;
    is_product_selected = 0;
    #10;
    is_enough_money = 1;
    #10;
    is_enough_money = 0;
    #10;
    $finish;
  end
endmodule
