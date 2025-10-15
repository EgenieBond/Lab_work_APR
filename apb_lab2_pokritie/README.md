## Описание
Верификация APB системы с полным анализом функционального покрытия.
### Исходные коды (src/)
- `master.sv` - APB мастер модуль
- `slave.sv` - APB слейв модуль  
- `testbench.sv` - базовое тестовое окружение

### Симуляция (simulation/)
- `coverage_collector.sv` - коллектор покрытия APB транзакций
- `testbench_with_coverage.sv` - расширенный testbench с покрытием
- `simulate.do` - скрипт запуска симуляции в ModelSim
eof
