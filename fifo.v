module fifo (
    input [7:0] data_in,
    input reset, clk,  wr_en, rd_en,
    output reg underflow, overflow,
    output reg [7:0] fifo_counter, data_out
);

    reg [5:0] wr_ptr, rd_ptr;
    reg [7:0] fifo_memory [63:0];

    always @(fifo_counter) // to set overflow and underflow
    begin
        underflow = (fifo_counter == 0);
        overflow = (fifo_counter == 64);
    end

    always @(posedge clk or negedge reset) // performs reading operation
    begin
        if (!reset) begin
			wr_ptr <= 0;
			rd_ptr <= 0;
         data_out <= 0;
			fifo_counter <= 0;
		end
		else begin
			if (!underflow && rd_en) begin
				data_out <= fifo_memory[rd_ptr];
				rd_ptr <= rd_ptr + 1'b1;
				fifo_counter <= fifo_counter - 1;
			end
			if (!overflow && wr_en) begin
				fifo_memory[wr_ptr] <= data_in;
				wr_ptr <= wr_ptr + 1'b1;
				fifo_counter <= fifo_counter + 1;
			end
		end
    end

endmodule
module fifo_tb;

    reg clk, reset, wr_en, rd_en;
    reg [7:0] data_in;
    wire [7:0] data_out, fifo_counter;
    wire underflow, overflow;

    fifo DUT (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_out(data_out),
        .fifo_counter(fifo_counter),
        .underflow(underflow),
        .overflow(overflow)
    );

    integer i;

    initial
    begin
        clk = 0;
        reset = 0;
    end

    always #10 clk = ~clk;

    initial
    begin

        @(posedge clk);

        #1;
        reset = 1;

        $display("Underflow: %b, Overflow: %b", underflow, overflow);

        wr_en = 1'b1;
        
        for (i = 0; i < 64; i = i + 1)
        begin
            @(posedge clk);
            data_in = i;

            #5;
            $display("data_in: %d, wr_ptr: %d @ loc: %d\n fifo_counter: %d\n Underflow: %b, Overflow: %b", i, DUT.wr_ptr, DUT.fifo_memory[i], DUT.fifo_counter, underflow, overflow);
        end

        rd_en = 1'b1;
        wr_en = 1'b0;
        
        forever begin
            if(underflow == 1) $finish;

            @(posedge clk);
            #5;

            $display("Data Out: %d, rd_ptr: %d\nfifo_counter: %d\n Underflow: %b, Overflow: %b", data_out, DUT.rd_ptr, DUT.fifo_counter, underflow, overflow);

        end

        $display("Write END");
        $finish(0);
    end

endmodule
