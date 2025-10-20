# Очистка предыдущей компиляции
quit -sim
.main clear

# Создание рабочей библиотеки
vlib work

echo "=========================================="
echo "Starting APB System Simulation with Coverage"
echo "=========================================="

# Компиляция SystemVerilog файлов
vlog -sv ../src/master.sv
vlog -sv ../src/slave.sv
vlog -sv ../src/testbench_with_coverage.sv

echo "Compilation completed"

# Запуск симуляции тестбенча
vsim -voptargs=+acc work.Testbench_With_Coverage

echo "Simulation started"

# Добавление основных сигналов APB
add wave -hex /Testbench_With_Coverage/PADDR
add wave -hex /Testbench_With_Coverage/PWDATA
add wave -hex /Testbench_With_Coverage/PRDATA
add wave -binary /Testbench_With_Coverage/master_inst/state
add wave /Testbench_With_Coverage/PSEL
add wave /Testbench_With_Coverage/PENABLE
add wave /Testbench_With_Coverage/PWRITE
add wave /Testbench_With_Coverage/PREADY

add wave -divider "Slave Basic Registers"
add wave -hex /Testbench_With_Coverage/slave_inst/registers

add wave -divider "Slave Cos Registers" 
add wave -hex /Testbench_With_Coverage/slave_inst/cos_control_reg
add wave -hex /Testbench_With_Coverage/slave_inst/cos_data_reg
add wave -hex /Testbench_With_Coverage/slave_inst/cos_status_reg

# Убрали волны для счетчиков покрытия, так как они не видны в wave
# Вместо этого добавим информационный раздел
add wave -divider "Coverage Info"
add wave -literal /Testbench_With_Coverage/fsm_idle_covered
add wave -literal /Testbench_With_Coverage/fsm_setup_covered
add wave -literal /Testbench_With_Coverage/fsm_access_covered
add wave -binary /Testbench_With_Coverage/cos_angles_covered

wave zoom full

echo "Running simulation for 10000ns..."
run 10000ns

echo "Simulation completed"
