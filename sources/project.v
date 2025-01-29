module D_FlipFlop_Gates (
    input  wire D,
    input  wire CLK,
    input  wire RESET,
    output reg  Q,
    output wire Qn
);
  assign Qn = ~Q;

  always @(posedge CLK or posedge RESET) begin
    if (RESET) Q <= 0;
    else Q <= D;
  end
endmodule

module Counter (
    input clock,
    input reset,
    input enable,
    output [3:0] number
);
  reg  [3:0] next_number;
  wire [3:0] Q;
  wire [3:0] Qn;
  D_FlipFlop_Gates DFF0 (
      .D(next_number[0]),
      .CLK(clock),
      .RESET(reset),
      .Q(Q[0]),
      .Qn(Qn[0])
  );
  D_FlipFlop_Gates DFF1 (
      .D(next_number[1]),
      .CLK(clock),
      .RESET(reset),
      .Q(Q[1]),
      .Qn(Qn[1])
  );
  D_FlipFlop_Gates DFF2 (
      .D(next_number[2]),
      .CLK(clock),
      .RESET(reset),
      .Q(Q[2]),
      .Qn(Qn[2])
  );
  D_FlipFlop_Gates DFF3 (
      .D(next_number[3]),
      .CLK(clock),
      .RESET(reset),
      .Q(Q[3]),
      .Qn(Qn[3])
  );
  always @(posedge clock or posedge reset) begin
    if (reset) next_number <= 4'b0000;
    else if (enable) next_number <= next_number + 1;
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
    output reg error
);
  wire [3:0] coin_500, coin_1000, coin_2000, cash_5000;

  Counter coin500 (
      .clock (clock),
      .reset (reset),
      .enable(coin == 2'b00),
      .number(coin_500)
  );
  Counter coin1000 (
      .clock (clock),
      .reset (reset),
      .enable(coin == 2'b01),
      .number(coin_1000)
  );
  Counter coin2000 (
      .clock (clock),
      .reset (reset),
      .enable(coin == 2'b10),
      .number(coin_2000)
  );
  Counter cash5000 (
      .clock (clock),
      .reset (reset),
      .enable(coin == 2'b11),
      .number(cash_5000)
  );

  assign count_500 = coin_500;
  assign count_1000 = coin_1000;
  assign count_2000 = coin_2000;
  assign count_5000 = cash_5000;
  assign total = (coin_500 * 5) + (coin_1000 * 10) + (coin_2000 * 20) + (cash_5000 * 50);

  always @(*) begin
    if (reset) error <= 0;
    else if (coin !== 2'b00 && coin !== 2'b01 && coin !== 2'b10 && coin !== 2'b11) begin
      error <= 1;
      $display("money is not supported");
    end else error <= 0;
  end
endmodule

module product_enable_generator (
    input [2:0] product_id,
    output reg [7:0] product_enable
);
  always @(*) begin
    product_enable = 8'b00000000;
    product_enable[product_id] = 1;
  end
endmodule

module comparator_5 (
    input [4:0] in_stock_amount,
    output is_less_than_5
);
  assign is_less_than_5 = (in_stock_amount < 5'b00101);
endmodule

module comparator_10 (
    input [3:0] product_count,
    output is_greater_than_10
);
  assign is_greater_than_10 = (product_count > 4'b1010);
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

module JK_FlipFlop (
    input wire J,
    input wire K,
    input wire CLK,
    input wire RESET,
    output reg Q
);
  always @(posedge CLK or posedge RESET) begin
    if (RESET) Q <= 0;
    else Q <= (J & ~Q) | (~K & Q);
  end
endmodule

module up_down_counter (
    input clock,
    input reset,
    input enable,
    input mode, // 1 for up, 0 for down
    output wire [4:0] number
);
  wire [4:0] next_number;
  wire [4:0] temp_up;
  wire [4:0] temp_down;
  wire [4:0] q_state;

  assign temp_up = q_state + 1;
  assign temp_down = q_state - 1;
  assign next_number = (reset) ? 5'b00000 : (enable ? (mode ? temp_up : temp_down) : q_state);
  assign number = q_state;

  genvar i;
  generate
    for (i = 0; i < 5; i = i + 1) begin : flip_flops
      JK_FlipFlop jkff (
        .J(next_number[i]),
        .K(~next_number[i]),
        .CLK(clock),
        .RESET(reset),
        .Q(q_state[i])
      );
    end
  endgenerate
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
  wire [7:0] product_enable;
  wire [4:0] decremented_inventory;
  wire [4:0] incremented_purchase_count;
  wire is_less_than_5;
  product_enable_generator decoder (
      .product_id (product_id),
      .product_enable (product_enable)
  );

  logic [2:0] index;

  always @(*) begin
      case (product_enable)
          8'b00000001: index = 3'd0;
          8'b00000010: index = 3'd1;
          8'b00000100: index = 3'd2;
          8'b00001000: index = 3'd3;
          8'b00010000: index = 3'd4;
          8'b00100000: index = 3'd5;
          8'b01000000: index = 3'd6;
          8'b10000000: index = 3'd7;
          default:     index = 3'dX;
      endcase
  end

  // decrement_counter inventory_decrement (
  //     .clock (clock),
  //     .reset (reset),
  //     .enable(didBuy && inventory[index] > 0 && quantity > 0),
  //     .number(decremented_inventory)
  // );
  up_down_counter inventory_decrement (
      .clock (clock),
      .reset (reset),
      .enable(didBuy && inventory[index] > 0 && quantity > 0),
      .mode(1'b0),
      .number(decremented_inventory)
  );
  // increment_counter purchase_increment (
  //     .clock (clock),
  //     .reset (reset),
  //     .enable(didBuy && quantity > 0),
  //     .number(incremented_purchase_count)
  // );
  up_down_counter purchase_increment (
      .clock (clock),
      .reset (reset),
      .enable(didBuy && quantity > 0),
      .mode(1'b1),
      .number(incremented_purchase_count)
  );
  comparator_5 compare_with_5 (
      .in_stock_amount(inventory[index]),
      .is_less_than_5 (is_less_than_5)
  );
  assign low_stock = is_less_than_5;
  assign error = (index >= 8 || inventory[index] == 0);
  assign product_price = (error) ? 8'd0 : prices[index];
  assign in_stock_amount = inventory[index];
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
    end else if (didBuy && inventory[index] > 0) begin
      total_buy_count <= total_buy_count + quantity;
      selected_products_total <= selected_products_total + (prices[index] * quantity);
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
    inventory[index] <= decremented_inventory;
    purchase_count[index] <= incremented_purchase_count;
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

  reg  [1:0] state_next;
  wire [1:0] state_reg;
  D_FlipFlop_Gates state_dff_0 (
      .D(state_next[0]),
      .CLK(clock),
      .RESET(reset),
      .Q(state_reg[0]),
      .Qn()
  );
  D_FlipFlop_Gates state_dff_1 (
      .D(state_next[1]),
      .CLK(clock),
      .RESET(reset),
      .Q(state_reg[1]),
      .Qn()
  );

  always @(posedge clock or posedge reset) begin
    if (reset) state <= IDLE;
    else state <= state_reg;
  end

  always @(*) begin
    case (state)
      IDLE: begin
        if (money_validation) state_next = SELECT;
        else state_next = IDLE;
      end
      SELECT: begin
        if (is_product_selected) state_next = PAY;
        else state_next = SELECT;
      end
      PAY: begin
        if (is_enough_money) state_next = DISPENSE;
        else state_next = PAY;
      end
      DISPENSE: state_next = IDLE;
      default:  state_next = IDLE;
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
    clock = 0;
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
