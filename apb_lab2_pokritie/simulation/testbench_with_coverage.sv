`timescale 1ns/1ps

module Testbench;

    // Тактовый сигнал и сброс
    reg clk;
    reg rst_n;
    
    // APB сигналы
    wire        PSEL;
    wire        PENABLE;
    wire        PWRITE;
    wire [31:0] PADDR;
    wire [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire        PREADY;
    wire        PSLVERR;
    
    // Коллектор покрытия
    coverage_collector cov_inst(
        .PCLK(clk),
        .PRESETn(rst_n),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .cos_control_reg(slave_inst.cos_control_reg),
        .cos_data_reg(slave_inst.cos_data_reg),
        .cos_status_reg(slave_inst.cos_status_reg),
        .angle_index(slave_inst.angle_index),
        .start_calculation(slave_inst.start_calculation),
        .calculation_done(slave_inst.calculation_done),
        .master_state(master_inst.state),
        .transaction_active(master_inst.transaction_active)
    );
    
    // Генерация тактового сигнала
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Генерация сброса
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end
    
    // Инстанциирование мастера
    apb_master master_inst (
        .PCLK(clk),
        .PRESETn(rst_n),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );
    
    // Инстанциирование slave
    apb_slave slave_inst (
        .PCLK(clk),
        .PRESETn(rst_n),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );
    
    // Основной тест
    initial begin
        reg [31:0] read_data;
        integer angle;
        
        // Инициализация
        #30;
        $display("APB SYSTEM TEST WITH COVERAGE ANALYSIS");
        
        // Базовые операции записи
        master_inst.apb_write(32'h00000000, 32'h00000002);
        #50;
        master_inst.apb_write(32'h00000004, 32'h15122024);
        #50;
        master_inst.apb_write(32'h00000008, 32'h424F4E44);
        #50;
        
        // Базовые операции чтения
        master_inst.apb_read(32'h00000000, read_data);
        #20;
        master_inst.apb_read(32'h00000004, read_data);
        #20;
        master_inst.apb_read(32'h00000008, read_data);
        #20;
        
        // Тестирование всех углов cos
        for (angle = 0; angle < 8; angle = angle + 1) begin
            // Запуск вычисления
            case (angle)
                0: master_inst.apb_write(32'h00000020, 32'h00000080);
                1: master_inst.apb_write(32'h00000020, 32'h00000081);
                2: master_inst.apb_write(32'h00000020, 32'h00000082);
                3: master_inst.apb_write(32'h00000020, 32'h00000083);
                4: master_inst.apb_write(32'h00000020, 32'h00000084);
                5: master_inst.apb_write(32'h00000020, 32'h00000085);
                6: master_inst.apb_write(32'h00000020, 32'h00000086);
                7: master_inst.apb_write(32'h00000020, 32'h00000087);
            endcase
            #50;
            
            master_inst.apb_read(32'h00000024, read_data);
            #30;
        end
        
        // Финальный отчет о покрытии
        #100;
        cov_inst.print_coverage();
        
        #100;
        $finish;
    end
    
    // Функция для получения ожидаемого значения cos
    function [31:0] get_expected_cos;
        input [2:0] index;
        begin
            case (index)
                3'd0: get_expected_cos = 32'h00010000;
                3'd1: get_expected_cos = 32'h0000B505;
                3'd2: get_expected_cos = 32'h00000000;
                3'd3: get_expected_cos = 32'hFFFF4AFB;
                3'd4: get_expected_cos = 32'hFFFF0000;
                3'd5: get_expected_cos = 32'hFFFF4AFB;
                3'd6: get_expected_cos = 32'h00000000;
                3'd7: get_expected_cos = 32'h0000B505;
                default: get_expected_cos = 32'h00000000;
            endcase
        end
    endfunction

    // Тайм-аут
    initial begin
        #8000;
        $display("TIMEOUT: Simulation took too long");
        cov_inst.print_coverage();
        $finish;
    end

endmodule