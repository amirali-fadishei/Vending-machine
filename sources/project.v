//comment

// module DownCounter (
//     input wire CLK,
//     input wire RESET,
//     input wire enable,
//     output wire [4:0] number
// );
//   wire Q0, Q1, Q2, Q3, Q4;
//   wire J0, K0, J1, K1, J2, K2, J3, K3, J4, K4;
//   wire enable_clk;
//   assign enable_clk = CLK & enable;
//   reg [4:0] next_number;

//   // Reset when RESET is high or number reaches 10 (01010)
//   assign reset_condition = RESET | (number == 5'b11111);

//   assign J0 = 1;
//   assign K0 = 1;
//   JK_FlipFlop ff0 (.J(J0), .K(K0), .CLK(enable_clk), .RESET(reset_condition), .Q(Q0));

//   assign J1 = (~Q0);
//   assign K1 = (~Q0);
//   JK_FlipFlop_r ff1 (.J(J1), .K(K1), .CLK(enable_clk), .RESET(reset_condition), .Q(Q1));

//   assign J2 = (~Q0 & ~Q1);
//   assign K2 = (~Q0 & ~Q1);
//   JK_FlipFlop ff2 (.J(J2), .K(K2), .CLK(enable_clk), .RESET(reset_condition), .Q(Q2));

//   assign J3 = (~Q0 & ~Q1 & ~Q2);
//   assign K3 = (~Q0 & ~Q1 & ~Q2);
//   JK_FlipFlop_r ff3 (.J(J3), .K(K3), .CLK(enable_clk), .RESET(reset_condition), .Q(Q3));

//   assign J4 = (~Q0 & ~Q1 & ~Q2 & ~Q3);
//   assign K4 = (~Q0 & ~Q1 & ~Q2 & ~Q3);
//   JK_FlipFlop ff4 (.J(J4), .K(K4), .CLK(enable_clk), .RESET(reset_condition), .Q(Q4));


//   always @(posedge CLK or posedge RESET) begin
//     if (reset_condition)
//       next_number <= 5'b01010;  
//     else
//       next_number <= {Q4, Q3, Q2, Q1, Q0};
//   end

//   assign number = next_number;
// endmodule

// module UpCounter (
//     input wire CLK,
//     input wire RESET,
//     input wire enable,
//     output wire [4:0] number
// );
//     wire Q0, Q1, Q2, Q3, Q4;
//     wire J0, K0, J1, K1, J2, K2, J3, K3, J4, K4;
//     wire enable_clk;
//     wire reset_condition;
//     reg [4:0] next_number;

//     assign enable_clk = CLK & enable;

//     // Reset when RESET is high or number reaches 10 (01010)
//     assign reset_condition = RESET | (number == 5'b01011);

//     assign J0 = 1;
//     assign K0 = 1;
//     JK_FlipFlop ff0 (.J(J0), .K(K0), .CLK(enable_clk), .RESET(reset_condition), .Q(Q0));

//     assign J1 = (Q0);
//     assign K1 = (Q0);
//     JK_FlipFlop ff1 (.J(J1), .K(K1), .CLK(enable_clk), .RESET(reset_condition), .Q(Q1));

//     assign J2 = (Q0 & Q1);
//     assign K2 = (Q0 & Q1);
//     JK_FlipFlop ff2 (.J(J2), .K(K2), .CLK(enable_clk), .RESET(reset_condition), .Q(Q2));

//     assign J3 = (Q0 & Q1 & Q2);
//     assign K3 = (Q0 & Q1 & Q2);
//     JK_FlipFlop ff3 (.J(J3), .K(K3), .CLK(enable_clk), .RESET(reset_condition), .Q(Q3));

//     assign J4 = (Q0 & Q1 & Q2 & Q3);
//     assign K4 = (Q0 & Q1 & Q2 & Q3);
//     JK_FlipFlop ff4 (.J(J4), .K(K4), .CLK(enable_clk), .RESET(reset_condition), .Q(Q4));


//     always @(posedge CLK or posedge RESET) begin
//     if (reset_condition)
//       next_number <= 5'b00000;
//     else
//       next_number <= {Q4, Q3, Q2, Q1, Q0};
//   end

//   assign number = next_number; 

// endmodule

// decrement_counter inventory_decrement (
//     .clock(clock),
//     .reset(reset),
//     .Quantity(quantity),
//     .enable(didBuy && inventory[index] > 0 && quantity > 0),
//     .number(decremented_inventory)
// );

// increment_counter purchase_increment (
//     .clock(clock),
//     .reset(reset),
//     .Quantity(quantity),
//     .enable(didBuy && quantity > 0),
//     .number(incremented_purchase_count)
// );

// DownCounter inventory_decrement (
//     .CLK (clock),
//     .RESET (reset),
//     .enable(didBuy && inventory[index] > 0 && quantity > 0),
//     .number(decremented_inventory)
// );
// UpCounter purchase_increment (
//     .CLK (clock),
//     .RESET (reset),
//     .enable(didBuy && quantity > 0),
//     .number(incremented_purchase_count)
// );

//


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
module JK_FlipFlop (
    input  wire J,
    input  wire K,
    input  wire CLK,
    input  wire RESET,
    output reg  Q
);
  always @(posedge CLK or posedge RESET) begin
    if (RESET) Q <= 0;
    else Q <= (J & ~Q) | (~K & Q);
  end
endmodule
module Counter (
    input clock,
    input reset,
    input enable,
    output reg [3:0] number
);
  wire Q0, Q1, Q2, Q3;
  wire J0, K0, J1, K1, J2, K2, J3, K3;
  wire enable_clk;

  assign enable_clk = clock & enable;

  assign J0 = 1;
  assign K0 = 1;
  JK_FlipFlop ff0 (
      .J(J0),
      .K(K0),
      .CLK(enable_clk),
      .RESET(reset),
      .Q(Q0)
  );

  assign J1 = Q0;
  assign K1 = Q0;
  JK_FlipFlop ff1 (
      .J(J1),
      .K(K1),
      .CLK(enable_clk),
      .RESET(reset),
      .Q(Q1)
  );

  assign J2 = Q0 & Q1;
  assign K2 = Q0 & Q1;
  JK_FlipFlop ff2 (
      .J(J2),
      .K(K2),
      .CLK(enable_clk),
      .RESET(reset),
      .Q(Q2)
  );

  assign J3 = Q0 & Q1 & Q2;
  assign K3 = Q0 & Q1 & Q2;
  JK_FlipFlop ff3 (
      .J(J3),
      .K(K3),
      .CLK(enable_clk),
      .RESET(reset),
      .Q(Q3)
  );

  always @(posedge clock or posedge reset) begin
    if (reset) number <= 4'b0000;
    else number <= {Q3, Q2, Q1, Q0};
  end
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
      .enable(coin === 2'b00),
      .number(coin_500)
  );
  Counter coin1000 (
      .clock (clock),
      .reset (reset),
      .enable(coin === 2'b01),
      .number(coin_1000)
  );
  Counter coin2000 (
      .clock (clock),
      .reset (reset),
      .enable(coin === 2'b10),
      .number(coin_2000)
  );
  Counter cash5000 (
      .clock (clock),
      .reset (reset),
      .enable(coin === 2'b11),
      .number(cash_5000)
  );

  assign count_500 = coin_500;
  assign count_1000 = coin_1000;
  assign count_2000 = coin_2000;
  assign count_5000 = cash_5000;
  assign total = (coin_500 * 5) + (coin_1000 * 10) + (coin_2000 * 20) + (cash_5000 * 50);

  always @(coin) begin
    if (reset) error <= 0;
    else if (coin !== 2'b00 && coin !== 2'b01 && coin !== 2'b10 && coin !== 2'b11) begin
      error <= 1;
      $display("money is not supported");
      $display("");
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
    input [3:0] in_stock_amount,
    output less_than_5
);
  assign less_than_5 = (in_stock_amount < 5'b00101);
endmodule
module comparator_10 (
    input [3:0] product_count,
    output greater_than_10
);
  assign greater_than_10 = (product_count > 4'b1010);
endmodule
module intelligent_discount (
    input  [15:0] real_amount,
    input  [ 3:0] product_count,
    output [15:0] discounted_amount
);
  wire greater_than_10;
  comparator_10 cmp (
      .product_count  (product_count),
      .greater_than_10(greater_than_10)
  );
  wire [15:0] result;
  assign result = (real_amount * 9) / 10;
  assign discounted_amount = (greater_than_10) ? result : real_amount;
endmodule
module decrement_counter (
    input clock,
    input reset,
    input enable,
    input [3:0] Quantity,
    output reg [4:0] number
);
  always @(posedge clock or posedge reset) begin
    if (reset) number <= 5'b01010;
    else if (enable && number > 0) number <= number - Quantity;
  end
endmodule
module increment_counter (
    input clock,
    input reset,
    input enable,
    input [3:0] Quantity,
    output reg [4:0] number
);
  always @(posedge clock or posedge reset) begin
    if (reset) number <= 5'b00000;
    else if (enable && number < 5'b01011) number <= number + Quantity;
  end
endmodule
module product_manager (
    input clock,
    input reset,
    input didBuy,
    input [15:0] total_money,
    input [2:0] product_id,
    input [3:0] quantity,
    output [4:0] in_stock_amount,
    output [7:0] product_price,
    output reg [15:0] total_price,
    output reg [4:0] product_purchase_count,
    output reg error
);
  reg [3:0] inventory[7:0];
  reg [7:0] prices[7:0];
  reg [3:0] purchase_count[7:0];
  reg [15:0] selected_products_price;
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

    inventory[0] = INITIAL_STOCK;
    inventory[1] = INITIAL_STOCK;
    inventory[2] = INITIAL_STOCK;
    inventory[3] = INITIAL_STOCK;
    inventory[4] = INITIAL_STOCK;
    inventory[5] = INITIAL_STOCK;
    inventory[6] = INITIAL_STOCK;
    inventory[7] = INITIAL_STOCK;

    total_buy_count = 0;
    selected_products_price = 0;
  end

  wire [7:0] product_enable;
  wire [4:0] decremented_inventory;
  wire [4:0] incremented_purchase_count;
  wire [15:0] discounted_total;
  wire less_than_5;

  product_enable_generator decoder (
      .product_id(product_id),
      .product_enable(product_enable)
  );

  reg [2:0] index;

  always @(product_id) begin
    case (product_enable)
      8'b00000001: index = 3'd0;
      8'b00000010: index = 3'd1;
      8'b00000100: index = 3'd2;
      8'b00001000: index = 3'd3;
      8'b00010000: index = 3'd4;
      8'b00100000: index = 3'd5;
      8'b01000000: index = 3'd6;
      8'b10000000: index = 3'd7;
    endcase
  end

  decrement_counter inventory_decrement (
      .clock(clock),
      .reset(reset),
      .Quantity(quantity),
      .enable(didBuy && inventory[index] > 0 && quantity > 0),
      .number(decremented_inventory)
  );

  increment_counter purchase_increment (
      .clock(clock),
      .reset(reset),
      .Quantity(quantity),
      .enable(didBuy && quantity > 0),
      .number(incremented_purchase_count)
  );

  comparator_5 compare_with_5 (
      .in_stock_amount(inventory[index]),
      .less_than_5(less_than_5)
  );

  assign product_price   = prices[index];
  assign in_stock_amount = inventory[index];

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      purchase_count[0] <= 0;
      purchase_count[1] <= 0;
      purchase_count[2] <= 0;
      purchase_count[3] <= 0;
      purchase_count[4] <= 0;
      purchase_count[5] <= 0;
      purchase_count[6] <= 0;
      purchase_count[7] <= 0;
    end else if (didBuy && inventory[index] > 0) begin
      total_buy_count <= total_buy_count + quantity;
      inventory[index] <= decremented_inventory;
      selected_products_price <= (prices[index] * quantity);
    end
  end

  intelligent_discount discount_logic (
      .real_amount(selected_products_price),
      .product_count(total_buy_count),
      .discounted_amount(discounted_total)
  );

  always @(discounted_total) begin
    total_price = discounted_total;
    case (total_price > total_money)
      1: $display("money is not enough");
    endcase
    inventory[index] <= decremented_inventory;
    purchase_count[index] <= incremented_purchase_count;
    product_purchase_count <= incremented_purchase_count;
  end

  always @(inventory[index]) begin
    if (inventory[index] < LOW_THRESHOLD) begin
      error <= 1;
      $display("Product is not available or low stock");
      $display("");
    end
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

  always @(state) begin
    enable_payment  = (state == PAY);
    enable_dispense = (state == DISPENSE);
  end
endmodule
module feedback_storage (
    input clock,
    input reset,
    input [2:0] product_id,
    input [2:0] feedback,
    output reg error,
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

  always @(feedback) begin
    if (feedback < 3'b001 || feedback > 3'b101 || product_id >= 8) begin
      error <= 1;
      $display("feedback is not supported");
      $display("");
    end else error <= 0;
  end
endmodule
module display (
    input [15:0] total_money,
    input [ 7:0] product_price,
    input [15:0] total_price,
    input [ 1:0] fsm_state,
    input [ 2:0] product_id,
    input [ 4:0] product_count,
    input [ 4:0] product_purchase_count,
    input [ 3:0] count_500,
    input [ 3:0] count_1000,
    input [ 3:0] count_2000,
    input [ 3:0] count_5000,
    input [ 3:0] quantity,
    input [ 2:0] stored_feedback_0,
    input [ 2:0] stored_feedback_1,
    input [ 2:0] stored_feedback_2,
    input [ 2:0] stored_feedback_3,
    input [ 2:0] stored_feedback_4,
    input [ 2:0] stored_feedback_5,
    input [ 2:0] stored_feedback_6,
    input [ 2:0] stored_feedback_7
);
  always @(fsm_state) begin
    case (fsm_state)
      2'b00: $display("FSM State: IDLE");
      2'b01: $display("FSM State: SELECT");
      2'b10: $display("FSM State: PAY");
      2'b11: $display("FSM State: DISPENSE");
    endcase
  end
  always @(count_500 or count_1000 or count_2000 or count_5000) begin
    $display("500 Coins: %d", count_500);
    $display("1000 Coins: %d", count_1000);
    $display("2000 Coins: %d", count_2000);
    $display("5000 Coins: %d", count_5000);
    $display("Total Money Inserted: %d", total_money);
    $display("");
  end
  always @(product_id) begin
    $display("Selected Product ID: %d", product_id);
    $display("Product Price: %d", product_price);
  end
  always @(quantity) begin
    $display("Quantity Selected: %d", quantity);
    $display("");
  end
  always @(total_price) begin
    $display("Total Cost: %d", total_price);
    $display("");
  end
  always @(product_purchase_count) begin
    $display("Product Purchase Count: %d", product_purchase_count);
    $display("Total Products Left: %d", product_count);
    $display("");
  end
  always @(stored_feedback_0 or stored_feedback_1 or stored_feedback_2 or stored_feedback_3 or stored_feedback_4 or stored_feedback_5 or stored_feedback_6 or stored_feedback_7) begin
    case (product_id)
      3'b000: $display("Feedback for Product 0: %d", stored_feedback_0);
      3'b001: $display("Feedback for Product 1: %d", stored_feedback_1);
      3'b010: $display("Feedback for Product 2: %d", stored_feedback_2);
      3'b011: $display("Feedback for Product 3: %d", stored_feedback_3);
      3'b100: $display("Feedback for Product 4: %d", stored_feedback_4);
      3'b101: $display("Feedback for Product 5: %d", stored_feedback_5);
      3'b110: $display("Feedback for Product 6: %d", stored_feedback_6);
      3'b111: $display("Feedback for Product 7: %d", stored_feedback_7);
    endcase
    $display("");
  end
endmodule
module testbench;

  reg clock, reset;
  reg  [ 1:0] coin;
  wire [15:0] total;
  wire [3:0] count_500, count_1000, count_2000, count_5000;
  wire error;

  reg [2:0] product_id;
  reg [3:0] quantity;
  reg didBuy;
  wire [4:0] in_stock_amount;
  wire [7:0] product_price;
  wire [15:0] total_price;
  wire [4:0] product_purchase_count;

  reg money_validation, is_product_selected, is_enough_money;
  wire [1:0] fsm_state;
  wire enable_payment, enable_dispense;

  reg [2:0] feedback;
  wire [2:0] stored_feedback_0, stored_feedback_1, stored_feedback_2, stored_feedback_3;

  wire [15:0] total_money;

  money_counter m_counter (
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

  product_manager p_manager (
      .clock(clock),
      .reset(reset),
      .total_money(total),
      .didBuy(didBuy),
      .product_id(product_id),
      .quantity(quantity),
      .in_stock_amount(in_stock_amount),
      .product_price(product_price),
      .total_price(total_price),
      .product_purchase_count(product_purchase_count),
      .error(error)
  );

  fsm fsm_inst (
      .clock(clock),
      .reset(reset),
      .money_validation(money_validation),
      .is_product_selected(is_product_selected),
      .is_enough_money(is_enough_money),
      .state(fsm_state),
      .enable_payment(enable_payment),
      .enable_dispense(enable_dispense)
  );

  feedback_storage f_storage (
      .clock(clock),
      .reset(reset),
      .product_id(product_id),
      .feedback(feedback),
      .error(error),
      .stored_feedback_0(stored_feedback_0),
      .stored_feedback_1(stored_feedback_1),
      .stored_feedback_2(stored_feedback_2),
      .stored_feedback_3(stored_feedback_3),
      .stored_feedback_4(),
      .stored_feedback_5(),
      .stored_feedback_6(),
      .stored_feedback_7()
  );

  display display_inst (
      .total_money(total),
      .product_price(product_price),
      .total_price(total_price),
      .fsm_state(fsm_state),
      .product_id(product_id),
      .product_count(in_stock_amount),
      .product_purchase_count(product_purchase_count),
      .count_500(count_500),
      .count_1000(count_1000),
      .count_2000(count_2000),
      .count_5000(count_5000),
      .quantity(quantity),
      .stored_feedback_0(stored_feedback_0),
      .stored_feedback_1(stored_feedback_1),
      .stored_feedback_2(stored_feedback_2),
      .stored_feedback_3(stored_feedback_3)
  );

  always begin
    #5 clock = ~clock;
  end

  initial begin
    clock = 0;
    reset = 1;

    #10 reset = 0;

    #10 coin = 2'b00;
    #10 coin = 2'b01;
    #10 coin = 2'b10;
    #10 coin = 2'b11;
    #10 coin = 2'bxx;

    #10 money_validation = 1;

    #10 is_product_selected = 1;
    #10 product_id = 3'b001;
    #10 quantity = 4'b0100;

    #10 didBuy = 1;
    #10 didBuy = 0;

    #10 is_enough_money = 1;

    #10 feedback = 3'b011;
    #10 feedback = 3'b110;

    #10 is_enough_money = 0;

    #20 $finish;
  end
endmodule
