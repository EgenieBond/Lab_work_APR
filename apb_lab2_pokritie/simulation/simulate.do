# Очистка предыдущей компиляции
quit -sim
.main clear

# Создание рабочей библиотеки
vlib work

echo "=========================================="
echo "Starting APB System Simulation with Manual Coverage"
echo "=========================================="

# Компиляция файлов в правильном порядке
vlog ../src/master.sv
vlog ../src/slave.sv  
vlog coverage_collector.sv
vlog testbench_with_coverage.sv

echo "Compilation completed"

# Запуск симуляции
vsim -voptargs=+acc work.Testbench

echo "Simulation started with manual coverage collection"

# Добавление сигналов
add wave -hex /Testbench/PADDR
add wave -hex /Testbench/PWDATA
add wave -hex /Testbench/PRDATA
add wave -binary /Testbench/master_inst/state
add wave /Testbench/PSEL
add wave /Testbench/PENABLE
add wave /Testbench/PWRITE
add wave /Testbench/PREADY

add wave -divider "Slave Cos Registers" 
add wave -hex /Testbench/slave_inst/cos_control_reg
add wave -hex /Testbench/slave_inst/cos_data_reg
add wave -hex /Testbench/slave_inst/cos_status_reg
add wave -binary /Testbench/slave_inst/angle_index
add wave /Testbench/slave_inst/start_calculation
add wave /Testbench/slave_inst/calculation_done

add wave -divider "Coverage Counters"
add wave -decimal /Testbench/cov_inst/master_idle_count
add wave -decimal /Testbench/cov_inst/master_setup_count
add wave -decimal /Testbench/cov_inst/master_access_count
add wave -decimal /Testbench/cov_inst/write_operations
add wave -decimal /Testbench/cov_inst/read_operations

wave zoom full

echo "Running simulation for coverage analysis..."
run 8000ns

echo "Simulation completed - check console for coverage report"