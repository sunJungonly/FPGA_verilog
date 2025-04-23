`timescale 1ns/1ns
module tb_alu();
    reg [3:0] a, b; // DUT의 입력 값
    reg [1:0] op; // 연산 코드
    wire [3:0] result; // DUT의 출력 값

// DUT 인스턴스화
alu dut (
    .a(a),
    .b(b),
    .op(op),
    .result(result)
);


// task 정의: 특정 연산을 테스트하고 결과를 출력
task test_alu;
    input [3:0] test_a; // 첫 번째 입력 값
    input [3:0] test_b; // 두 번째 입력 값
    input [1:0] test_op; // 연산 코드
    input [3:0] expected; // 예상 결과값

    begin
        a = test_a;
        b = test_b;
        op = test_op;

        #10; // 연산 결과 대기

        if (result === expected) begin
            $display("PASS: a=%h, b=%h, op=%b -> result=%h", test_a, test_b, test_op, result);
        end else begin
            $display("FAIL: a=%h, b=%h, op=%b -> result=%h (expected %h)", test_a, test_b, test_op, result, expected);
        end

    end
endtask

// 테스트 시나리오 실행 및 모니터링 설정
    initial begin
        $display("Starting ALU Test ... ");
        // $monitor 사용하여 실시간 값 추적 (입력 및 출력 상태를 확인)
        $monitor("Time=%0t | a=%h | b=%h | op=%b | result=%h", $time, a, b, op, result);
        // 덧셈 테스트 (ADD)
        test_alu(4'h3,4'h5, 2'b00, 4'h8); // 3 + 5 = 8
        // 별셈 테스트 (SUB)
        test_alu(4'h7, 4'h2, 2'b01, 4'h5); // 7 - 2 = 5
        // AND 테스트 (AND)
        test_alu(4'hF, 4'hA, 2'b10, 4'hA); // F & A = A
        // OR 테스트 (OR)
        test_alu(4'hC, 4'h3, 2'b11, 4'hF); // C | 3 = F
        $display("ALU Test Completed.");
        $finish;

    end

endmodule
