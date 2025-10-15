`timescale 1ns/1ps

module coverage_collector(
    input PCLK,
    input PRESETn,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [31:0] PADDR,
    input [31:0] PWDATA,
    input [31:0] PRDATA,
    input PREADY,
    
    // Slave внутренние сигналы
    input [31:0] cos_control_reg,
    input [31:0] cos_data_reg,
    input [31:0] cos_status_reg,
    input [2:0]  angle_index,
    input        start_calculation,
    input        calculation_done,
    
    // Master внутренние сигналы
    input [1:0]  master_state,
    input        transaction_active
);
    
    // Счетчики покрытия
    reg [31:0] master_idle_count;
    reg [31:0] master_setup_count;
    reg [31:0] master_access_count;
    reg [31:0] write_operations;
    reg [31:0] read_operations;
    reg [31:0] cos_angle_0;
    reg [31:0] cos_angle_1;
    reg [31:0] cos_angle_2;
    reg [31:0] cos_angle_3;
    reg [31:0] cos_angle_4;
    reg [31:0] cos_angle_5;
    reg [31:0] cos_angle_6;
    reg [31:0] cos_angle_7;
    
    initial begin
        master_idle_count = 0;
        master_setup_count = 0;
        master_access_count = 0;
        write_operations = 0;
        read_operations = 0;
        cos_angle_0 = 0;
        cos_angle_1 = 0;
        cos_angle_2 = 0;
        cos_angle_3 = 0;
        cos_angle_4 = 0;
        cos_angle_5 = 0;
        cos_angle_6 = 0;
        cos_angle_7 = 0;
    end
    
    // Мониторинг состояний
    always @(posedge PCLK) begin
        // Покрытие FSM мастера
        case (master_state)
            2'b00: master_idle_count <= master_idle_count + 1;
            2'b01: master_setup_count <= master_setup_count + 1;
            2'b10: master_access_count <= master_access_count + 1;
        endcase
        
        // Покрытие операций APB
        if (PSEL && PENABLE) begin
            if (PWRITE) write_operations <= write_operations + 1;
            else read_operations <= read_operations + 1;
        end
        
        // Покрытие углов cos
        if (start_calculation && !calculation_done) begin
            case (angle_index)
                3'd0: cos_angle_0 <= cos_angle_0 + 1;
                3'd1: cos_angle_1 <= cos_angle_1 + 1;
                3'd2: cos_angle_2 <= cos_angle_2 + 1;
                3'd3: cos_angle_3 <= cos_angle_3 + 1;
                3'd4: cos_angle_4 <= cos_angle_4 + 1;
                3'd5: cos_angle_5 <= cos_angle_5 + 1;
                3'd6: cos_angle_6 <= cos_angle_6 + 1;
                3'd7: cos_angle_7 <= cos_angle_7 + 1;
            endcase
        end
    end
    
    // Задача для отчета о покрытии
    task print_coverage;
        integer covered_items;
        integer total_items;
        integer coverage_percent;
        begin
            covered_items = 0;
            total_items = 0;
            
            $display("");
            $display("==================================================");
            $display("COVERAGE ANALYSIS REPORT (MANUAL)");
            $display("==================================================");
            
            // FSM Coverage
            $display("MASTER FSM COVERAGE:");
            $display("  IDLE state:  %0d hits", master_idle_count);
            $display("  SETUP state: %0d hits", master_setup_count);
            $display("  ACCESS state: %0d hits", master_access_count);
            
            if (master_idle_count > 0) covered_items = covered_items + 1;
            if (master_setup_count > 0) covered_items = covered_items + 1;
            if (master_access_count > 0) covered_items = covered_items + 1;
            total_items = total_items + 3;
            
            // APB Operations
            $display("");
            $display("APB OPERATIONS COVERAGE:");
            $display("  Write operations: %0d", write_operations);
            $display("  Read operations:  %0d", read_operations);
            
            if (write_operations > 0) covered_items = covered_items + 1;
            if (read_operations > 0) covered_items = covered_items + 1;
            total_items = total_items + 2;
            
            // COS Angles Coverage
            $display("");
            $display("COS ANGLES COVERAGE:");
            $display("  Angle 0 (cos(0)):     %0d hits", cos_angle_0);
            $display("  Angle 1 (cos(π/4)):   %0d hits", cos_angle_1);
            $display("  Angle 2 (cos(π/2)):   %0d hits", cos_angle_2);
            $display("  Angle 3 (cos(3π/4)):  %0d hits", cos_angle_3);
            $display("  Angle 4 (cos(π)):     %0d hits", cos_angle_4);
            $display("  Angle 5 (cos(5π/4)):  %0d hits", cos_angle_5);
            $display("  Angle 6 (cos(3π/2)):  %0d hits", cos_angle_6);
            $display("  Angle 7 (cos(7π/4)):  %0d hits", cos_angle_7);
            
            if (cos_angle_0 > 0) covered_items = covered_items + 1;
            if (cos_angle_1 > 0) covered_items = covered_items + 1;
            if (cos_angle_2 > 0) covered_items = covered_items + 1;
            if (cos_angle_3 > 0) covered_items = covered_items + 1;
            if (cos_angle_4 > 0) covered_items = covered_items + 1;
            if (cos_angle_5 > 0) covered_items = covered_items + 1;
            if (cos_angle_6 > 0) covered_items = covered_items + 1;
            if (cos_angle_7 > 0) covered_items = covered_items + 1;
            total_items = total_items + 8;
            
            // Calculate coverage percentage (без real)
            coverage_percent = (covered_items * 100) / total_items;
            
            $display("");
            $display("--------------------------------------------------");
            $display("COVERAGE SUMMARY:");
            $display("  Covered items: %0d/%0d", covered_items, total_items);
            $display("  TOTAL COVERAGE: %0d%%", coverage_percent);
            $display("--------------------------------------------------");
            
            // Missing coverage report
            if (coverage_percent < 100) begin
                $display("");
                $display("MISSING COVERAGE:");
                if (master_idle_count == 0) $display("  - MASTER IDLE state not covered");
                if (master_setup_count == 0) $display("  - MASTER SETUP state not covered");
                if (master_access_count == 0) $display("  - MASTER ACCESS state not covered");
                if (write_operations == 0) $display("  - WRITE operations not covered");
                if (read_operations == 0) $display("  - READ operations not covered");
                if (cos_angle_0 == 0) $display("  - cos(0) not tested");
                if (cos_angle_1 == 0) $display("  - cos(π/4) not tested");
                if (cos_angle_2 == 0) $display("  - cos(π/2) not tested");
                if (cos_angle_3 == 0) $display("  - cos(3π/4) not tested");
                if (cos_angle_4 == 0) $display("  - cos(π) not tested");
                if (cos_angle_5 == 0) $display("  - cos(5π/4) not tested");
                if (cos_angle_6 == 0) $display("  - cos(3π/2) not tested");
                if (cos_angle_7 == 0) $display("  - cos(7π/4) not tested");
            end
            
            $display("==================================================");
            $display("");
        end
    endtask

endmodule