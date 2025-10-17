`timescale 1ns/1ps

module Testbench;

    // Тактовый сигнал и сброс
    logic clk;
    logic rst_n;
    
    // APB сигналы
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;
    
    // Генерация тактового сигнала
    initial begin
        clk = 0;
        $display("Starting clock generation...");
        forever #5 clk = ~clk;
    end
    
    // Генерация сброса
    initial begin
        rst_n = 0;
        $display("Reset asserted");
        #20 rst_n = 1;
        $display("Reset deasserted at time %0t", $time);
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
        logic [31:0] read_data;
        
        // Инициализация
        #30;
        $display("");
        $display("************************************************");
        $display("APB SYSTEM TEST STARTED - LAB 1 + LAB 2");
        $display("************************************************");
        $display("");
        
        // ЧАСТЬ 1: Лабораторная работа 1 - Оригинальные операции
        $display("=== PART 1: LABORATORY WORK 1 ===");
        
        // 1. Запись по адресу 0x0 значения 2
        $display("TEST 1: Writing value 2 to address 0x0");
        master_inst.apb_write(32'h00000000, 32'h00000002);
        #50;
        
        // 2. Запись по адресу 0x4 значения дата
        $display("TEST 2: Writing date to address 0x4");
        master_inst.apb_write(32'h00000004, 32'h15122024);
        #50;
        
        // 3. Запись по адресу 0x8 значения фамилия
        $display("TEST 3: Writing surname to address 0x8");
        master_inst.apb_write(32'h00000008, 32'h424F4E44); // BOND
        #50;
        
        // 4. Запись по адресу 0xC значения имя
        $display("TEST 4: Writing name to address 0xC");
        master_inst.apb_write(32'h0000000C, 32'h45564745); // EVGE
        #50;
        
        // Печать всех регистров slave для проверки
        slave_inst.print_all_registers();
        
        // Чтение для проверки оригинальных операций
        $display("=== VERIFICATION: ORIGINAL VALUES ===");
        
        // Чтение адреса 0x0
        master_inst.apb_read(32'h00000000, read_data);
        $display("VERIFICATION: Read addr 0x0 = 0x%08h (Expected: 0x00000002)", read_data);
        if (read_data == 32'h00000002) 
            $display("PASS: Data matches expected value!");
        else 
            $display("FAIL: Data mismatch!");
        #20;
        
        // Чтение адреса 0x4
        master_inst.apb_read(32'h00000004, read_data);
        $display("VERIFICATION: Read addr 0x4 = 0x%08h (Expected: 0x15122024)", read_data);
        if (read_data == 32'h15122024) 
            $display("PASS: Data matches expected value!");
        else 
            $display("FAIL: Data mismatch!");
        #20;
        
        // Чтение адреса 0x8
        master_inst.apb_read(32'h00000008, read_data);
        $display("VERIFICATION: Read addr 0x8 = 0x%08h (Expected: 0x424F4E44)", read_data);
        if (read_data == 32'h424F4E44) 
            $display("PASS: Data matches expected value!");
        else 
            $display("FAIL: Data mismatch!");
        #20;
        
        // Чтение адреса 0xC
        master_inst.apb_read(32'h0000000C, read_data);
        $display("VERIFICATION: Read addr 0xC = 0x%08h (Expected: 0x45564745)", read_data);
        if (read_data == 32'h45564745) 
            $display("PASS: Data matches expected value!");
        else 
            $display("FAIL: Data mismatch!");
        #20;
        
        // ЧАСТЬ 2: Лабораторная работа 2 - Cos операции
        $display("");
        $display("=== PART 2: LABORATORY WORK 2 - COS CALCULATIONS ===");
        
        // Тестирование всех углов с шагом π/4
        for (int i = 0; i < 8; i++) begin
            $display("COS TEST %0d: Calculating cos for angle index %0d", i+1, i);
            
            // 1. Запись угла в контрольный регистр и запуск вычисления
            // Адрес 0x20: [7] - start=1, [2:0] - angle index
            // ИСПРАВЛЕНО: используем явные hex значения с битом 7 = 1
            case (i)
                0: master_inst.apb_write(32'h00000020, 32'h00000080); // 1000_0000
                1: master_inst.apb_write(32'h00000020, 32'h00000081); // 1000_0001  
                2: master_inst.apb_write(32'h00000020, 32'h00000082); // 1000_0010
                3: master_inst.apb_write(32'h00000020, 32'h00000083); // 1000_0011
                4: master_inst.apb_write(32'h00000020, 32'h00000084); // 1000_0100
                5: master_inst.apb_write(32'h00000020, 32'h00000085); // 1000_0101
                6: master_inst.apb_write(32'h00000020, 32'h00000086); // 1000_0110
                7: master_inst.apb_write(32'h00000020, 32'h00000087); // 1000_0111
            endcase
            #50;
            
            // 2. Чтение регистра статуса для проверки завершения (адрес 0x28)
            master_inst.apb_read(32'h00000028, read_data);
            $display("Status register (0x28) = 0x%08h (bit0=done)", read_data);
            
            // 3. Чтение результата cos (адрес 0x24)
            master_inst.apb_read(32'h00000024, read_data);
            
            // Вывод результата в удобном формате
            case (i)
                0: $display("cos(0) = 0x%08h (expected: 0x00010000 = 1.0)", read_data);
                1: $display("cos(π/4) = 0x%08h (expected: 0x0000B505 = 0.7071)", read_data);
                2: $display("cos(π/2) = 0x%08h (expected: 0x00000000 = 0.0)", read_data);
                3: $display("cos(3π/4) = 0x%08h (expected: 0xFFFF4AFB = -0.7071)", read_data);
                4: $display("cos(π) = 0x%08h (expected: 0xFFFF0000 = -1.0)", read_data);
                5: $display("cos(5π/4) = 0x%08h (expected: 0xFFFF4AFB = -0.7071)", read_data);
                6: $display("cos(3π/2) = 0x%08h (expected: 0x00000000 = 0.0)", read_data);
                7: $display("cos(7π/4) = 0x%08h (expected: 0x0000B505 = 0.7071)", read_data);
            endcase
            
            // Проверка результата
            if (read_data == get_expected_cos(i))
                $display("PASS: cos value matches expected!");
            else
                $display("FAIL: cos value mismatch!");
            
            $display("");
            #50;
        end
        
        // Финальный отчет
        $display("");
        $display("************************************************");
        $display("APB SYSTEM TEST COMPLETED - BOTH LABS FINISHED");
        $display("************************************************");
        $display("Summary: All operations from Lab 1 and Lab 2 finished");
        $display("Simulation time: %0t ns", $time);
        $display("************************************************");
        $display("");
        
        #50;
        $finish;
    end
    
    // Функция для получения ожидаемого значения cos
    function logic [31:0] get_expected_cos(int index);
        case (index)
            0: return 32'h00010000;   // cos(0) = 1.0
            1: return 32'h0000B505;   // cos(π/4) = 0.7071
            2: return 32'h00000000;   // cos(π/2) = 0.0
            3: return 32'hFFFF4AFB;   // cos(3π/4) = -0.7071
            4: return 32'hFFFF0000;   // cos(π) = -1.0
            5: return 32'hFFFF4AFB;   // cos(5π/4) = -0.7071
            6: return 32'h00000000;   // cos(3π/2) = 0.0
            7: return 32'h0000B505;   // cos(7π/4) = 0.7071
            default: return 32'h00000000;
        endcase
    endfunction

    // Мониторинг APB шины
    initial begin
        $monitor("Time: %0t | APB_BUS: PSEL=%b PENABLE=%b PWRITE=%b PADDR=0x%08h PWDATA=0x%08h PRDATA=0x%08h PREADY=%b", 
                 $time, PSEL, PENABLE, PWRITE, PADDR, PWDATA, PRDATA, PREADY);
    end

    // Тайм-аут для безопасности
    initial begin
        #5000; // 5000 нс тайм-аут
        $display("");
        $display("TIMEOUT: Simulation took too long, forcing finish");
        $display("");
        $finish;
    end

endmodule