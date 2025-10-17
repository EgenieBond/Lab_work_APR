# Очистка предыдущей компиляции
quit -sim
.main clear

# Создание рабочей библиотеки
vlib work

echo "=========================================="
echo "Starting Comprehensive Coverage Analysis"
echo "=========================================="

# Компиляция файлов
vlog ../src/master.sv
vlog ../src/slave.sv  
vlog coverage_collector.sv
vlog testbench_with_coverage.sv

echo "Compilation completed"

# Запуск симуляции
vsim -voptargs=+acc work.Testbench

echo "Simulation started with comprehensive coverage"

# Добавление сигналов
add wave -hex /Testbench/PADDR
add wave -hex /Testbench/PWDATA
add wave -hex /Testbench/PRDATA
add wave -binary /Testbench/master_inst/state
add wave /Testbench/PSEL
add wave /Testbench/PENABLE
add wave /Testbench/PWRITE
add wave /Testbench/PREADY

add wave -divider "Coverage Monitor"
add wave -binary /Testbench/cov_inst/cond_master_transaction
add wave -binary /Testbench/cov_inst/cond_master_pready
add wave -binary /Testbench/cov_inst/branch_master_idle_setup
add wave -binary /Testbench/cov_inst/branch_master_setup_access
add wave -binary /Testbench/cov_inst/branch_master_access_idle
add wave -binary /Testbench/cov_inst/fsm_trans_idle_setup
add wave -binary /Testbench/cov_inst/fsm_trans_setup_access
add wave -binary /Testbench/cov_inst/fsm_trans_access_idle

wave zoom full

echo "Running comprehensive coverage analysis..."
run 10000ns

echo "Simulation completed - check console for detailed coverage report"