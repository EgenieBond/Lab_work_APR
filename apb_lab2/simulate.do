# Очистка предыдущей компиляции
quit -sim
.main clear

# Создание рабочей библиотеки
vlib work

echo "=========================================="
echo "Starting APB System Simulation - Lab 1 + Lab 2"
echo "=========================================="

# Компиляция SystemVerilog файлов
vlog -sv ../src/master.sv
vlog -sv ../src/slave.sv
vlog -sv ../src/testbench.sv

echo "Compilation completed"

# Запуск симуляции тестбенча
vsim -voptargs=+acc work.Testbench

echo "Simulation started"

# Добавление сигналов
add wave -hex /Testbench/PADDR
add wave -hex /Testbench/PWDATA
add wave -hex /Testbench/PRDATA
add wave -binary /Testbench/master_inst/state
add wave /Testbench/PSEL
add wave /Testbench/PENABLE
add wave /Testbench/PWRITE
add wave /Testbench/PREADY

add wave -divider "Slave Basic Registers"
add wave -hex /Testbench/slave_inst/registers

add wave -divider "Slave Cos Registers" 
add wave -hex /Testbench/slave_inst/cos_control_reg
add wave -hex /Testbench/slave_inst/cos_data_reg
add wave -hex /Testbench/slave_inst/cos_status_reg

wave zoom full

echo "Running simulation for 5000ns..."
run 5000ns

echo "Simulation completed"