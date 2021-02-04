module MultiplierTestBench;

	int a, b, result;
	Multiplier mult(a,b,result);
	
	task assert_else_error(input [31:0] exp_result);
		assert (result == exp_result) else begin
			$error("multiply %b %b (%b %b)", a, b, result, exp_result);
		end
	endtask

	initial begin
        #1;
		a <= 2 <<< 20;
		b <= 5 <<< 20;
		#1 assert_else_error(10 <<< 20);
	end
	
endmodule

module DividerTestBench;

	int a, b, result;
	Divider div(a,b,result);
	
	task assert_else_error(input [31:0] exp_result);
		assert (result == exp_result) else begin
			$error("divide %b %b (%b %b)", a, b, result, exp_result);
		end
	endtask

	initial begin
        #1;
		a <= 10 <<< 20;
		b <= 2 <<< 20;
		#1 assert_else_error(5 <<< 20);
	end
	
endmodule
