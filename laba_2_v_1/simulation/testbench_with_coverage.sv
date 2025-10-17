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
        .PSLVERR(PSLVERR),
        .cos_control_reg(slave_inst.cos_control_reg),
        .cos_data_reg(slave_inst.cos_data_reg),
        .cos_status_reg(slave_inst.cos_status_reg),
        .angle_index(slave_inst.angle_index),
        .start_calculation(slave_inst.start_calculation),
        .calculation_done(slave_inst.calculation_done),
        .master_state(master_inst.state),
        .transaction_active(master_inst.transaction_active),
        .read_complete(master_inst.read_complete)
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
        integer i;
        
        // Инициализация
        #30;
        $display("COMPREHENSIVE COVERAGE TEST STARTED");
        
        // Тестирование всех функций и условий
        
        // 1. Базовые операции записи
        master_inst.apb_write(32'h00000000, 32'h00000002);
        #50;
        master_inst.apb_write(32'h00000004, 32'h15122024);
        #50;
        master_inst.apb_write(32'h00000008, 32'h424F4E44);
        #50;
        master_inst.apb_write(32'h0000000C, 32'h00000000); // Граничное значение
        #50;
        
        // 2. Базовые операции чтения
        master_inst.apb_read(32'h00000000, read_data);
        #20;
        master_inst.apb_read(32'h00000004, read_data);
        #20;
        master_inst.apb_read(32'h00000008, read_data);
        #20;
        master_inst.apb_read(32'h0000000C, read_data);
        #20;
        
        // 3. Граничные значения данных
        master_inst.apb_write(32'h00000000, 32'hFFFFFFFF);
        #30;
        
        // 4. Cos операции
        master_inst.apb_write(32'h00000020, 32'h00000080); // Cos control
        #30;
        master_inst.apb_write(32'h00000024, 32'h12345678); // Cos data (тест)
        #30;
        
        // 5. Чтение cos регистров
        master_inst.apb_read(32'h00000020, read_data);
        #20;
        master_inst.apb_read(32'h00000024, read_data);
        #20;
        master_inst.apb_read(32'h00000028, read_data); // Status
        #20;
        
        // 6. Полное тестирование cos вычислений
        for (i = 0; i < 8; i = i + 1) begin
            case (i)
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
        
        // 7. Дополнительные тесты для покрытия
        // Запись без запуска вычисления
        master_inst.apb_write(32'h00000020, 32'h00000005);
        #30;
        master_inst.apb_read(32'h00000024, read_data);
        #20;
        
        // Финальный отчет
        #100;
        cov_inst.print_coverage_report();
        
        $display("COVERAGE TESTING COMPLETED");
        #100;
        $finish;
    end

    // Тайм-аут
    initial begin
        #10000;
        $display("TIMEOUT: Simulation took too long");
        cov_inst.print_coverage_report();
        $finish;
    end

endmodule