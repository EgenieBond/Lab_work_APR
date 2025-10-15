# Очистка предыдущей компиляции
quit -sim
.main clear

# Создание рабочей библиотеки
vlib work

echo "=========================================="
echo "Starting APB System Simulation"
echo "=========================================="

# Компиляция SystemVerilog файлов
vlog -sv ../src/master.sv
vlog -sv ../src/slave.sv
vlog -sv ../src/testbench.sv

echo "Compilation completed"

# Запуск симуляции тестбенча
vsim -voptargs=+acc work.Testbench

echo "Simulation started"

# Добавление сигналов с правильными форматами (синтаксис ModelSim 10.1d)
add wave -hex /Testbench/PADDR
add wave -hex /Testbench/PWDATA
add wave -hex /Testbench/PRDATA
add wave -hex /Testbench/master_inst/read_data_reg
add wave -binary /Testbench/master_inst/state
add wave /Testbench/PSEL
add wave /Testbench/PENABLE
add wave /Testbench/PWRITE
add wave /Testbench/PREADY
add wave /Testbench/clk
add wave /Testbench/rst_n
add wave /Testbench/master_inst/transaction_active

# Добавление разделителей для лучшей организации
add wave -divider "APB Bus Signals"
add wave -hex /Testbench/PADDR
add wave -hex /Testbench/PWDATA
add wave -hex /Testbench/PRDATA

add wave -divider "APB Control Signals" 
add wave /Testbench/PSEL
add wave /Testbench/PENABLE
add wave /Testbench/PWRITE
add wave /Testbench/PREADY

add wave -divider "Master Internal State"
add wave -binary /Testbench/master_inst/state
add wave /Testbench/master_inst/transaction_active
add wave -hex /Testbench/master_inst/read_data_reg

add wave -divider "Global Signals"
add wave /Testbench/clk
add wave /Testbench/rst_n

wave zoom full

echo "Running simulation for 1500ns..."
run 1500ns

echo "Simulation completed"