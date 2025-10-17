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
    input PSLVERR,
    
    // Slave внутренние сигналы
    input [31:0] cos_control_reg,
    input [31:0] cos_data_reg,
    input [31:0] cos_status_reg,
    input [2:0]  angle_index,
    input        start_calculation,
    input        calculation_done,
    
    // Master внутренние сигналы
    input [1:0]  master_state,
    input        transaction_active,
    input        read_complete
);
    
    // ========== STATEMENT COVERAGE ==========
    reg [31:0] stmt_master_fsm;
    reg [31:0] stmt_slave_write;
    reg [31:0] stmt_slave_read;
    reg [31:0] stmt_slave_cos;
    
    // ========== CONDITION COVERAGE ==========
    reg cond_master_transaction;
    reg cond_master_pready;
    reg cond_slave_psel_penable;
    reg cond_slave_pwrite;
    reg cond_slave_start_calc;
    
    // ========== BRANCH COVERAGE ==========
    reg branch_master_idle_setup;
    reg branch_master_setup_access;
    reg branch_master_access_idle;
    reg branch_slave_write_basic;
    reg branch_slave_write_cos_ctrl;
    reg branch_slave_write_cos_data;
    reg branch_slave_read_basic;
    reg branch_slave_read_cos_ctrl;
    reg branch_slave_read_cos_data;
    reg branch_slave_read_status;
    
    // ========== FUNCTION COVERAGE ==========
    reg function_apb_write;
    reg function_apb_read;
    reg function_cos_calc;
    reg function_slave_reset;
    
    // ========== FSM COVERAGE ==========
    reg [31:0] fsm_idle;
    reg [31:0] fsm_setup;
    reg [31:0] fsm_access;
    reg fsm_trans_idle_setup;
    reg fsm_trans_setup_access;
    reg fsm_trans_access_idle;
    
    // ========== TOGGLE COVERAGE ==========
    reg toggle_psel_0_1;
    reg toggle_psel_1_0;
    reg toggle_penable_0_1;
    reg toggle_penable_1_0;
    reg toggle_pwrite_0_1;
    reg toggle_pwrite_1_0;
    reg toggle_start_0_1;
    reg toggle_start_1_0;
    reg toggle_done_0_1;
    reg toggle_done_1_0;
    
    // ========== PARAMETER COVERAGE ==========
    reg param_addr_min;
    reg param_addr_max_basic;
    reg param_addr_cos_ctrl;
    reg param_addr_cos_data;
    reg param_addr_cos_status;
    reg param_data_zero;
    reg param_data_max;
    reg param_data_cos_1;
    reg param_data_cos_minus_1;
    
    // Предыдущие значения для FSM переходов
    reg [1:0] master_state_prev;
    reg psel_prev;
    reg penable_prev;
    reg pwrite_prev;
    reg start_prev;
    reg done_prev;
    
    integer i;
    
    initial begin
        // Инициализация всех флагов покрытия
        stmt_master_fsm = 0;
        stmt_slave_write = 0;
        stmt_slave_read = 0;
        stmt_slave_cos = 0;
        
        cond_master_transaction = 0;
        cond_master_pready = 0;
        cond_slave_psel_penable = 0;
        cond_slave_pwrite = 0;
        cond_slave_start_calc = 0;
        
        branch_master_idle_setup = 0;
        branch_master_setup_access = 0;
        branch_master_access_idle = 0;
        branch_slave_write_basic = 0;
        branch_slave_write_cos_ctrl = 0;
        branch_slave_write_cos_data = 0;
        branch_slave_read_basic = 0;
        branch_slave_read_cos_ctrl = 0;
        branch_slave_read_cos_data = 0;
        branch_slave_read_status = 0;
        
        function_apb_write = 0;
        function_apb_read = 0;
        function_cos_calc = 0;
        function_slave_reset = 0;
        
        fsm_idle = 0;
        fsm_setup = 0;
        fsm_access = 0;
        fsm_trans_idle_setup = 0;
        fsm_trans_setup_access = 0;
        fsm_trans_access_idle = 0;
        
        toggle_psel_0_1 = 0;
        toggle_psel_1_0 = 0;
        toggle_penable_0_1 = 0;
        toggle_penable_1_0 = 0;
        toggle_pwrite_0_1 = 0;
        toggle_pwrite_1_0 = 0;
        toggle_start_0_1 = 0;
        toggle_start_1_0 = 0;
        toggle_done_0_1 = 0;
        toggle_done_1_0 = 0;
        
        param_addr_min = 0;
        param_addr_max_basic = 0;
        param_addr_cos_ctrl = 0;
        param_addr_cos_data = 0;
        param_addr_cos_status = 0;
        param_data_zero = 0;
        param_data_max = 0;
        param_data_cos_1 = 0;
        param_data_cos_minus_1 = 0;
        
        master_state_prev = 2'b00;
        psel_prev = 0;
        penable_prev = 0;
        pwrite_prev = 0;
        start_prev = 0;
        done_prev = 0;
    end
    
    // ========== STATEMENT COVERAGE ==========
    // Отслеживается через мониторинг выполнения основных блоков
    
    // ========== CONDITION COVERAGE ==========
    always @(posedge PCLK) begin
        // Условия в master
        if (transaction_active) 
            cond_master_transaction = 1;
        if (PREADY) 
            cond_master_pready = 1;
            
        // Условия в slave
        if (PSEL && PENABLE) 
            cond_slave_psel_penable = 1;
        if (PWRITE) 
            cond_slave_pwrite = 1;
        if (start_calculation) 
            cond_slave_start_calc = 1;
    end
    
    // ========== BRANCH COVERAGE ==========
    always @(posedge PCLK) begin
        // Ветвления FSM master
        if (master_state == 2'b00 && transaction_active) 
            branch_master_idle_setup = 1;
        if (master_state == 2'b01) 
            branch_master_setup_access = 1;
        if (master_state == 2'b10 && PREADY) 
            branch_master_access_idle = 1;
            
        // Ветвления slave write
        if (PSEL && PENABLE && PWRITE) begin
            if (PADDR[7:4] == 4'h0) 
                branch_slave_write_basic = 1;
            else if (PADDR[7:4] == 4'h2) begin
                if (PADDR[3:0] == 4'h0) 
                    branch_slave_write_cos_ctrl = 1;
                else if (PADDR[3:0] == 4'h4) 
                    branch_slave_write_cos_data = 1;
            end
        end
        
        // Ветвления slave read
        if (PSEL && PENABLE && !PWRITE) begin
            if (PADDR[7:4] == 4'h0) 
                branch_slave_read_basic = 1;
            else if (PADDR[7:4] == 4'h2) begin
                if (PADDR[3:0] == 4'h0) 
                    branch_slave_read_cos_ctrl = 1;
                else if (PADDR[3:0] == 4'h4) 
                    branch_slave_read_cos_data = 1;
                else if (PADDR[3:0] == 4'h8) 
                    branch_slave_read_status = 1;
            end
        end
    end
    
    // ========== FUNCTION COVERAGE ==========
    always @(posedge PCLK) begin
        if (PSEL && PENABLE && PWRITE) 
            function_apb_write = 1;
        if (PSEL && PENABLE && !PWRITE) 
            function_apb_read = 1;
        if (start_calculation && !calculation_done) 
            function_cos_calc = 1;
        if (!PRESETn) 
            function_slave_reset = 1;
    end
    
    // ========== FSM COVERAGE ==========
    always @(posedge PCLK) begin
        // Состояния FSM
        case (master_state)
            2'b00: fsm_idle = fsm_idle + 1;
            2'b01: fsm_setup = fsm_setup + 1;
            2'b10: fsm_access = fsm_access + 1;
        endcase
        
        // Переходы FSM
        if (master_state == 2'b01 && master_state_prev == 2'b00)
            fsm_trans_idle_setup = 1;
        if (master_state == 2'b10 && master_state_prev == 2'b01)
            fsm_trans_setup_access = 1;
        if (master_state == 2'b00 && master_state_prev == 2'b10)
            fsm_trans_access_idle = 1;
            
        master_state_prev = master_state;
    end
    
    // ========== TOGGLE COVERAGE ==========
    always @(posedge PCLK) begin
        // Переключения APB сигналов
        if (PSEL && !psel_prev) toggle_psel_0_1 = 1;
        if (!PSEL && psel_prev) toggle_psel_1_0 = 1;
        if (PENABLE && !penable_prev) toggle_penable_0_1 = 1;
        if (!PENABLE && penable_prev) toggle_penable_1_0 = 1;
        if (PWRITE && !pwrite_prev) toggle_pwrite_0_1 = 1;
        if (!PWRITE && pwrite_prev) toggle_pwrite_1_0 = 1;
        
        // Переключения управляющих сигналов
        if (start_calculation && !start_prev) toggle_start_0_1 = 1;
        if (!start_calculation && start_prev) toggle_start_1_0 = 1;
        if (calculation_done && !done_prev) toggle_done_0_1 = 1;
        if (!calculation_done && done_prev) toggle_done_1_0 = 1;
        
        // Сохранение предыдущих значений
        psel_prev = PSEL;
        penable_prev = PENABLE;
        pwrite_prev = PWRITE;
        start_prev = start_calculation;
        done_prev = calculation_done;
    end
    
    // ========== PARAMETER COVERAGE ==========
    always @(posedge PCLK) begin
        // Граничные адреса
        if (PADDR == 32'h00000000) param_addr_min = 1;
        if (PADDR == 32'h0000000C) param_addr_max_basic = 1;
        if (PADDR == 32'h00000020) param_addr_cos_ctrl = 1;
        if (PADDR == 32'h00000024) param_addr_cos_data = 1;
        if (PADDR == 32'h00000028) param_addr_cos_status = 1;
        
        // Граничные данные
        if (PWDATA == 32'h00000000) param_data_zero = 1;
        if (PWDATA == 32'hFFFFFFFF) param_data_max = 1;
        if (cos_data_reg == 32'h00010000) param_data_cos_1 = 1;
        if (cos_data_reg == 32'hFFFF0000) param_data_cos_minus_1 = 1;
    end
    
    // Задача для отчета о покрытии
    task print_coverage_report;
        integer total_items;
        integer covered_items;
        integer coverage_percent;
        begin
            total_items = 0;
            covered_items = 0;
            
            $display("");
            $display("==================================================");
            $display("COMPREHENSIVE COVERAGE ANALYSIS REPORT");
            $display("==================================================");
            
            // ========== CONDITION COVERAGE ==========
            $display("");
            $display("=== CONDITION COVERAGE ===");
            total_items = total_items + 5;
            if (cond_master_transaction) begin
                $display("✓ transaction_active condition");
                covered_items = covered_items + 1;
            end else $display("✗ transaction_active condition");
            
            if (cond_master_pready) begin
                $display("✓ PREADY condition");
                covered_items = covered_items + 1;
            end else $display("✗ PREADY condition");
            
            if (cond_slave_psel_penable) begin
                $display("✓ PSEL && PENABLE condition");
                covered_items = covered_items + 1;
            end else $display("✗ PSEL && PENABLE condition");
            
            if (cond_slave_pwrite) begin
                $display("✓ PWRITE condition");
                covered_items = covered_items + 1;
            end else $display("✗ PWRITE condition");
            
            if (cond_slave_start_calc) begin
                $display("✓ start_calculation condition");
                covered_items = covered_items + 1;
            end else $display("✗ start_calculation condition");
            
            // ========== BRANCH COVERAGE ==========
            $display("");
            $display("=== BRANCH COVERAGE ===");
            total_items = total_items + 10;
            if (branch_master_idle_setup) begin
                $display("✓ IDLE -> SETUP branch");
                covered_items = covered_items + 1;
            end else $display("✗ IDLE -> SETUP branch");
            
            if (branch_master_setup_access) begin
                $display("✓ SETUP -> ACCESS branch");
                covered_items = covered_items + 1;
            end else $display("✗ SETUP -> ACCESS branch");
            
            if (branch_master_access_idle) begin
                $display("✓ ACCESS -> IDLE branch");
                covered_items = covered_items + 1;
            end else $display("✗ ACCESS -> IDLE branch");
            
            if (branch_slave_write_basic) begin
                $display("✓ Slave write basic registers");
                covered_items = covered_items + 1;
            end else $display("✗ Slave write basic registers");
            
            if (branch_slave_write_cos_ctrl) begin
                $display("✓ Slave write cos control");
                covered_items = covered_items + 1;
            end else $display("✗ Slave write cos control");
            
            if (branch_slave_write_cos_data) begin
                $display("✓ Slave write cos data");
                covered_items = covered_items + 1;
            end else $display("✗ Slave write cos data");
            
            if (branch_slave_read_basic) begin
                $display("✓ Slave read basic registers");
                covered_items = covered_items + 1;
            end else $display("✗ Slave read basic registers");
            
            if (branch_slave_read_cos_ctrl) begin
                $display("✓ Slave read cos control");
                covered_items = covered_items + 1;
            end else $display("✗ Slave read cos control");
            
            if (branch_slave_read_cos_data) begin
                $display("✓ Slave read cos data");
                covered_items = covered_items + 1;
            end else $display("✗ Slave read cos data");
            
            if (branch_slave_read_status) begin
                $display("✓ Slave read status");
                covered_items = covered_items + 1;
            end else $display("✗ Slave read status");
            
            // ========== FUNCTION COVERAGE ==========
            $display("");
            $display("=== FUNCTION COVERAGE ===");
            total_items = total_items + 4;
            if (function_apb_write) begin
                $display("✓ APB write function");
                covered_items = covered_items + 1;
            end else $display("✗ APB write function");
            
            if (function_apb_read) begin
                $display("✓ APB read function");
                covered_items = covered_items + 1;
            end else $display("✗ APB read function");
            
            if (function_cos_calc) begin
                $display("✓ COS calculation function");
                covered_items = covered_items + 1;
            end else $display("✗ COS calculation function");
            
            if (function_slave_reset) begin
                $display("✓ Slave reset function");
                covered_items = covered_items + 1;
            end else $display("✗ Slave reset function");
            
            // ========== FSM COVERAGE ==========
            $display("");
            $display("=== FSM COVERAGE ===");
            total_items = total_items + 6;
            if (fsm_idle > 0) begin
                $display("✓ FSM IDLE state");
                covered_items = covered_items + 1;
            end else $display("✗ FSM IDLE state");
            
            if (fsm_setup > 0) begin
                $display("✓ FSM SETUP state");
                covered_items = covered_items + 1;
            end else $display("✗ FSM SETUP state");
            
            if (fsm_access > 0) begin
                $display("✓ FSM ACCESS state");
                covered_items = covered_items + 1;
            end else $display("✗ FSM ACCESS state");
            
            if (fsm_trans_idle_setup) begin
                $display("✓ FSM IDLE -> SETUP transition");
                covered_items = covered_items + 1;
            end else $display("✗ FSM IDLE -> SETUP transition");
            
            if (fsm_trans_setup_access) begin
                $display("✓ FSM SETUP -> ACCESS transition");
                covered_items = covered_items + 1;
            end else $display("✗ FSM SETUP -> ACCESS transition");
            
            if (fsm_trans_access_idle) begin
                $display("✓ FSM ACCESS -> IDLE transition");
                covered_items = covered_items + 1;
            end else $display("✗ FSM ACCESS -> IDLE transition");
            
            // ========== TOGGLE COVERAGE ==========
            $display("");
            $display("=== TOGGLE COVERAGE ===");
            total_items = total_items + 10;
            if (toggle_psel_0_1) begin
                $display("✓ PSEL 0->1 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ PSEL 0->1 toggle");
            
            if (toggle_psel_1_0) begin
                $display("✓ PSEL 1->0 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ PSEL 1->0 toggle");
            
            if (toggle_penable_0_1) begin
                $display("✓ PENABLE 0->1 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ PENABLE 0->1 toggle");
            
            if (toggle_penable_1_0) begin
                $display("✓ PENABLE 1->0 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ PENABLE 1->0 toggle");
            
            if (toggle_pwrite_0_1) begin
                $display("✓ PWRITE 0->1 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ PWRITE 0->1 toggle");
            
            if (toggle_pwrite_1_0) begin
                $display("✓ PWRITE 1->0 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ PWRITE 1->0 toggle");
            
            if (toggle_start_0_1) begin
                $display("✓ start_calc 0->1 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ start_calc 0->1 toggle");
            
            if (toggle_start_1_0) begin
                $display("✓ start_calc 1->0 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ start_calc 1->0 toggle");
            
            if (toggle_done_0_1) begin
                $display("✓ calc_done 0->1 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ calc_done 0->1 toggle");
            
            if (toggle_done_1_0) begin
                $display("✓ calc_done 1->0 toggle");
                covered_items = covered_items + 1;
            end else $display("✗ calc_done 1->0 toggle");
            
            // ========== PARAMETER COVERAGE ==========
            $display("");
            $display("=== PARAMETER COVERAGE ===");
            total_items = total_items + 8;
            if (param_addr_min) begin
                $display("✓ Address 0x00000000");
                covered_items = covered_items + 1;
            end else $display("✗ Address 0x00000000");
            
            if (param_addr_max_basic) begin
                $display("✓ Address 0x0000000C");
                covered_items = covered_items + 1;
            end else $display("✗ Address 0x0000000C");
            
            if (param_addr_cos_ctrl) begin
                $display("✓ Address 0x00000020");
                covered_items = covered_items + 1;
            end else $display("✗ Address 0x00000020");
            
            if (param_addr_cos_data) begin
                $display("✓ Address 0x00000024");
                covered_items = covered_items + 1;
            end else $display("✗ Address 0x00000024");
            
            if (param_addr_cos_status) begin
                $display("✓ Address 0x00000028");
                covered_items = covered_items + 1;
            end else $display("✗ Address 0x00000028");
            
            if (param_data_zero) begin
                $display("✓ Data 0x00000000");
                covered_items = covered_items + 1;
            end else $display("✗ Data 0x00000000");
            
            if (param_data_max) begin
                $display("✓ Data 0xFFFFFFFF");
                covered_items = covered_items + 1;
            end else $display("✗ Data 0xFFFFFFFF");
            
            if (param_data_cos_1) begin
                $display("✓ COS result 1.0 (0x00010000)");
                covered_items = covered_items + 1;
            end else $display("✗ COS result 1.0 (0x00010000)");
            
            if (param_data_cos_minus_1) begin
                $display("✓ COS result -1.0 (0xFFFF0000)");
                covered_items = covered_items + 1;
            end else $display("✗ COS result -1.0 (0xFFFF0000)");
            
            // Расчет общего покрытия
            coverage_percent = (covered_items * 100) / total_items;
            
            $display("");
            $display("--------------------------------------------------");
            $display("OVERALL COVERAGE SUMMARY:");
            $display("Covered items: %0d/%0d", covered_items, total_items);
            $display("TOTAL COVERAGE: %0d%%", coverage_percent);
            $display("--------------------------------------------------");
            
            if (coverage_percent < 100) begin
                $display("");
                $display("MISSING COVERAGE AREAS:");
                if (!cond_master_transaction) $display("  - transaction_active condition");
                if (!cond_master_pready) $display("  - PREADY condition");
                if (!branch_slave_read_status) $display("  - Slave read status branch");
                if (!toggle_done_1_0) $display("  - calc_done 1->0 toggle");
                // Добавьте другие непокрытые области по необходимости
            end
            
            $display("==================================================");
            $display("");
        end
    endtask

endmodule