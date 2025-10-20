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

    // Обычные регистры (0x00-0x1F)
    logic [31:0] registers [0:7]; // 8 регистров по 4 байта = 32 байта
    
    // Регистры для cos вычислений (0x20-0x2F)
    logic [31:0] cos_control_reg;
    logic [31:0] cos_data_reg;
    logic [31:0] cos_status_reg;
    
    // Константы для cos(x)
    logic [31:0] COS_VALUES [0:7];
    
    initial begin
        COS_VALUES[0] = 32'h00010000;
        COS_VALUES[1] = 32'h0000B505;
        COS_VALUES[2] = 32'h00000000;
        COS_VALUES[3] = 32'hFFFF4AFB;
        COS_VALUES[4] = 32'hFFFF0000;
        COS_VALUES[5] = 32'hFFFF4AFB;
        COS_VALUES[6] = 32'h00000000;
        COS_VALUES[7] = 32'h0000B505;
    end
    
    // Сигналы управления cos
    logic [2:0] angle_index;
    logic start_calculation;
    logic calculation_done;
    logic calculation_busy;
    
    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0;
    
    assign angle_index = cos_control_reg[2:0];
    assign start_calculation = cos_control_reg[7];

    // Логика записи
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            integer i;
            for (i = 0; i < 8; i = i + 1) begin
                registers[i] <= 32'd0;
            end
            cos_control_reg <= 32'd0;
            cos_data_reg <= 32'd0;
            cos_status_reg <= 32'd0;
            calculation_done <= 1'b0;
            calculation_busy <= 1'b0;
            $display("");
            $display("================================================");
            $display("APB SLAVE: RESET COMPLETED");
            $display("================================================");
            $display("");
        end else begin
            // Обновляем регистр статуса
            cos_status_reg <= {30'd0, calculation_busy, calculation_done};
            
            // Сбрасываем флаг завершения в начале такта
            calculation_done <= 1'b0;
            
            if (PSEL && PENABLE && PWRITE) begin
                if (PADDR[31:8] == 24'h0) begin
                    // Обычные регистры (0x00 - 0x1F)
                    if (PADDR[7:5] == 3'b000) begin // Адреса 0x00-0x1F
                        registers[PADDR[4:2]] <= PWDATA; // Используем биты 4:2 для индекса регистра
                        $display("");
                        $display("------------------------------------------------");
                        $display("APB SLAVE: WRITE TO BASIC REGISTER");
                        $display("------------------------------------------------");
                        $display("Register[0x%02h] = 0x%08h", PADDR[7:0], PWDATA);
                        $display("Write successful");
                        $display("------------------------------------------------");
                        $display("");
                    end
                    // Cos регистры (0x20 - 0x2F)
                    else if (PADDR[7:4] == 4'h2) begin
                        case (PADDR[3:0])
                            4'h0: begin
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
                                
                                if (PWDATA[7] && !calculation_busy) begin
                                    calculation_busy <= 1'b1;
                                    $display("APB SLAVE: Starting cos calculation for angle index %0d", PWDATA[2:0]);
                                end
                            end
                            
                            4'h4: begin
                                cos_data_reg <= PWDATA;
                                $display("APB SLAVE: Data register write = 0x%08h", PWDATA);
                            end
                        endcase
                    end
                end
            end
            
            // Логика вычисления cos(x) - В ОТДЕЛЬНОМ УСЛОВИИ
            if (calculation_busy) begin
                // Имитация вычисления (1 такт)
                $display("APB SLAVE: Processing cos calculation for angle %0d", angle_index);
                cos_data_reg <= COS_VALUES[angle_index];
                calculation_done <= 1'b1;
                calculation_busy <= 1'b0;
                $display("");
                $display("------------------------------------------------");
                $display("APB SLAVE: COS CALCULATION COMPLETED");
                $display("------------------------------------------------");
                $display("Angle index: %0d", angle_index);
                $display("cos value: 0x%08h", COS_VALUES[angle_index]);
                $display("------------------------------------------------");
                $display("");
            end
        end
    end

    // Логика чтения
    always @(*) begin
        PRDATA = 32'd0;
        if (PSEL && !PWRITE) begin
            if (PADDR[31:8] == 24'h0) begin
                // Обычные регистры (0x00 - 0x1F)
                if (PADDR[7:5] == 3'b000) begin
                    // Обработка невыровненных адресов
                    if (PADDR[1:0] != 2'b00) begin
                        PRDATA = 32'hAAAA5555; // Простая константа для невыровненного адреса
                        $display("APB SLAVE: Misaligned address 0x%08h", PADDR);
                    end else begin
                        PRDATA = registers[PADDR[4:2]];
                        $display("");
                        $display("------------------------------------------------");
                        $display("APB SLAVE: READ FROM BASIC REGISTER");
                        $display("------------------------------------------------");
                        $display("Reading Register[0x%02h]", PADDR[7:0]);
                        $display("Data: 0x%08h", PRDATA);
                        $display("------------------------------------------------");
                        $display("");
                    end
                end
                // Cos регистры (0x20 - 0x2F)
                else if (PADDR[7:4] == 4'h2) begin
                    // Проверка выравнивания для cos регистров
                    if (PADDR[3:0] == 4'h0 || PADDR[3:0] == 4'h4 || PADDR[3:0] == 4'h8) begin
                        case (PADDR[3:0])
                            4'h0: begin
                                PRDATA = cos_control_reg;
                                $display("APB SLAVE: Control register read = 0x%08h", cos_control_reg);
                            end
                            
                            4'h4: begin
                                PRDATA = cos_data_reg;
                                $display("");
                                $display("------------------------------------------------");
                                $display("APB SLAVE: READ COS VALUE");
                                $display("------------------------------------------------");
                                $display("cos data register: 0x%08h", cos_data_reg);
                                $display("------------------------------------------------");
                                $display("");
                            end
                            
                            4'h8: begin
                                PRDATA = cos_status_reg;
                                $display("APB SLAVE: Status register read = 0x%08h", cos_status_reg);
                            end
                            
                            default: begin
                                PRDATA = 32'hDEADBEEF;
                            end
                        endcase
                    end else begin
                        PRDATA = 32'h5555AAAA; // Простая константа для неверного адреса cos
                        $display("APB SLAVE: Invalid cos register address 0x%08h", PADDR);
                    end
                end
                else begin
                    PRDATA = 32'hDEADBEEF;
                end
            end else begin
                PRDATA = 32'hDEADBEEF;
            end
        end
    end

    function void print_all_registers();
        begin
            integer i;
            $display("");
            $display("================================================");
            $display("APB SLAVE: BASIC REGISTERS DUMP");
            $display("================================================");
            for (i = 0; i < 8; i = i + 1) begin
                $display("Register[0x%02h] = 0x%08h", i*4, registers[i]);
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
