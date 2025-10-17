`timescale 1ns/1ps

module apb_slave (
    // APB интерфейс
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    // Обычные регистры (0x00-0x0F)
    logic [31:0] registers [0:15];
    
    // Регистры для cos вычислений (0x20-0x2F)
    logic [31:0] cos_control_reg;    // Контрольный регистр cos (адрес 0x20)
    logic [31:0] cos_data_reg;       // Выходной регистр cos (адрес 0x24)
    logic [31:0] cos_status_reg;     // Регистр статуса cos (адрес 0x28)
    
    // Константы для cos(x) с шагом π/4 (совместимый синтаксис)
    logic [31:0] COS_VALUES [0:7];
    
    initial begin
        COS_VALUES[0] = 32'h00010000;   // cos(0) = 1.0 (Q1.15 формат)
        COS_VALUES[1] = 32'h0000B505;   // cos(π/4) = 0.7071
        COS_VALUES[2] = 32'h00000000;   // cos(π/2) = 0.0
        COS_VALUES[3] = 32'hFFFF4AFB;   // cos(3π/4) = -0.7071
        COS_VALUES[4] = 32'hFFFF0000;   // cos(π) = -1.0
        COS_VALUES[5] = 32'hFFFF4AFB;   // cos(5π/4) = -0.7071
        COS_VALUES[6] = 32'h00000000;   // cos(3π/2) = 0.0
        COS_VALUES[7] = 32'h0000B505;   // cos(7π/4) = 0.7071
    end
    
    // Сигналы управления cos
    logic [2:0] angle_index;     // Индекс угла (0-7)
    logic start_calculation;     // Сигнал начала вычисления
    logic calculation_done;      // Сигнал завершения вычисления
    
    // Всегда готовы
    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0;
    
    // Разбор контрольного регистра cos
    assign angle_index = cos_control_reg[2:0];        // биты 2:0 - индекс угла
    assign start_calculation = cos_control_reg[7];    // бит 7 - запуск вычисления

    // Логика записи
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Сброс всех регистров
            integer i;
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 32'd0;
            end
            cos_control_reg <= 32'd0;
            cos_data_reg <= 32'd0;
            cos_status_reg <= 32'd0;
            calculation_done <= 1'b0;
            $display("");
            $display("================================================");
            $display("APB SLAVE: RESET COMPLETED");
            $display("All registers initialized to 0x00000000");
            $display("================================================");
            $display("");
        end else begin
            // Обновляем регистр статуса
            cos_status_reg <= {31'd0, calculation_done};
            
            if (PSEL && PENABLE && PWRITE) begin
                // Определяем адресное пространство
                if (PADDR[31:8] == 24'h0) begin
                    // Обычные регистры (0x00 - 0x0F)
                    if (PADDR[7:4] == 4'h0) begin
                        registers[PADDR[3:0]] <= PWDATA;
                        $display("");
                        $display("------------------------------------------------");
                        $display("APB SLAVE: WRITE TO BASIC REGISTER");
                        $display("------------------------------------------------");
                        $display("Register[0x%01h] = 0x%08h", PADDR[3:0], PWDATA);
                        $display("Previous value: 0x%08h", registers[PADDR[3:0]]);
                        $display("Write successful");
                        $display("------------------------------------------------");
                        $display("");
                    end
                    // Cos регистры (0x20 - 0x2F)
                    else if (PADDR[7:4] == 4'h2) begin
                        case (PADDR[3:0])
                            4'h0: begin // Cos control register (0x20)
                                cos_control_reg <= PWDATA;
                                $display("");
                                $display("------------------------------------------------");
                                $display("APB SLAVE: COS CONTROL REGISTER WRITE");
                                $display("------------------------------------------------");
                                $display("Control register = 0x%08h", PWDATA);
                                $display("Angle index = %0d", PWDATA[2:0]);
                                $display("Start calculation = %b", PWDATA[7]);
                                $display("------------------------------------------------");
                                $display("");
                                
                                // Если установлен бит запуска, начинаем вычисление
                                if (PWDATA[7]) begin
                                    calculation_done <= 1'b0;
                                    $display("APB SLAVE: Starting cos calculation for angle index %0d", PWDATA[2:0]);
                                end
                            end
                            
                            4'h4: begin // Cos data register (0x24) - только для тестирования
                                cos_data_reg <= PWDATA;
                                $display("APB SLAVE: Data register write = 0x%08h", PWDATA);
                            end
                            
                            default: begin
                                $display("APB SLAVE: Invalid write address 0x%08h", PADDR);
                            end
                        endcase
                    end
                end else begin
                    $display("APB SLAVE: Invalid write address 0x%08h", PADDR);
                end
            end
            
            // Логика вычисления cos(x)
            if (start_calculation && !calculation_done) begin
                // Имитация вычисления (1 такт)
                cos_data_reg <= COS_VALUES[angle_index];
                calculation_done <= 1'b1;
                $display("");
                $display("------------------------------------------------");
                $display("APB SLAVE: COS CALCULATION COMPLETED");
                $display("------------------------------------------------");
                $display("Angle index: %0d", angle_index);
                $display("cos value: 0x%08h", COS_VALUES[angle_index]);
                case (angle_index)
                    0: $display("cos(0) = 1.0");
                    1: $display("cos(π/4) = 0.7071");
                    2: $display("cos(π/2) = 0.0");
                    3: $display("cos(3π/4) = -0.7071");
                    4: $display("cos(π) = -1.0");
                    5: $display("cos(5π/4) = -0.7071");
                    6: $display("cos(3π/2) = 0.0");
                    7: $display("cos(7π/4) = 0.7071");
                endcase
                $display("------------------------------------------------");
                $display("");
            end
            
            // Сброс флага вычисления при записи нового угла
            if (PSEL && PENABLE && PWRITE && PADDR[7:0] == 8'h20 && !PWDATA[7]) begin
                calculation_done <= 1'b0;
            end
        end
    end

    // Логика чтения
    always @(*) begin
        PRDATA = 32'd0;
        if (PSEL && !PWRITE) begin
            if (PADDR[31:8] == 24'h0) begin
                // Обычные регистры (0x00 - 0x0F)
                if (PADDR[7:4] == 4'h0) begin
                    PRDATA = registers[PADDR[3:0]];
                    $display("");
                    $display("------------------------------------------------");
                    $display("APB SLAVE: READ FROM BASIC REGISTER");
                    $display("------------------------------------------------");
                    $display("Reading Register[0x%01h]", PADDR[3:0]);
                    $display("Data: 0x%08h", PRDATA);
                    $display("------------------------------------------------");
                    $display("");
                end
                // Cos регистры (0x20 - 0x2F)
                else if (PADDR[7:4] == 4'h2) begin
                    case (PADDR[3:0])
                        4'h0: begin // Cos control register (0x20)
                            PRDATA = cos_control_reg;
                            $display("APB SLAVE: Control register read = 0x%08h", cos_control_reg);
                        end
                        
                        4'h4: begin // Cos data register (0x24)
                            PRDATA = cos_data_reg;
                            $display("");
                            $display("------------------------------------------------");
                            $display("APB SLAVE: READ COS VALUE");
                            $display("------------------------------------------------");
                            $display("cos data register: 0x%08h", cos_data_reg);
                            $display("------------------------------------------------");
                            $display("");
                        end
                        
                        4'h8: begin // Cos status register (0x28)
                            PRDATA = cos_status_reg;
                            $display("APB SLAVE: Status register read = 0x%08h", cos_status_reg);
                        end
                        
                        default: begin
                            PRDATA = 32'hDEADBEEF;
                            $display("APB SLAVE: Invalid read address 0x%08h, returning 0xDEADBEEF", PADDR);
                        end
                    endcase
                end
                else begin
                    PRDATA = 32'hDEADBEEF;
                    $display("APB SLAVE: Invalid read address 0x%08h", PADDR);
                end
            end else begin
                PRDATA = 32'hDEADBEEF;
                $display("APB SLAVE: Invalid read address 0x%08h", PADDR);
            end
        end
    end

    // Функция для отладки - печать всех регистров
    function void print_all_registers();
        begin
            integer i;
            $display("");
            $display("================================================");
            $display("APB SLAVE: BASIC REGISTERS DUMP");
            $display("================================================");
            for (i = 0; i < 16; i = i + 1) begin
                $display("Register[0x%01h] = 0x%08h", i, registers[i]);
            end
            $display("================================================");
            $display("");
            
            $display("================================================");
            $display("APB SLAVE: COS REGISTERS DUMP");
            $display("================================================");
            $display("Control register (0x20): 0x%08h", cos_control_reg);
            $display("Data register    (0x24): 0x%08h", cos_data_reg);
            $display("Status register  (0x28): 0x%08h", cos_status_reg);
            $display("================================================");
            $display("");
        end
    endfunction

endmodule