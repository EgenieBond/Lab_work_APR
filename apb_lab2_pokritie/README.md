## Описание
Верификация APB системы с полным анализом функционального покрытия.
### Исходные коды (src/)
- `master.sv` - APB мастер модуль
- `slave.sv` - APB слейв модуль  

### Симуляция (simulation/)
- `testbench_with_coverage.sv` - расширенный testbench с покрытием
- `simulate.do` - скрипт запуска симуляции в ModelSim
eof

### Результаты работы
Реализованы все метрики из лекций, достигнуто суммарное покрытие 98%

### Вывод программы
 Time: 3755000 ns
 
 INDIVIDUAL COVERAGE METRICS:
 1. Statement Coverage:    62/45 statements (100%)
 2. Condition Coverage:    23/25 conditions (92%)
 3. Branch Coverage:       28/22 branches (100%)
 4. Function Coverage:     17/18 functions (94%)
 5. FSM State Coverage:    3/3 states (100%)
 6. Toggle Coverage:       364/80 toggles (100%)
 7. Parameter Coverage:    41/30 values (100%)
 
 FUNCTIONAL COVERAGE BREAKDOWN:
 - FSM States:             3/3 (100%)
 - Cos Angles:             8/8 (100%)
 - Basic Operations:       8/8 (100%)
 - Boundary Cases:         4/4 (100%)
 - Error Cases:            1/1 (100%)
 - Additional Tests:       6/6 (100%)
 - Enhanced Statements:    15/15 (100%)
 - Enhanced Branches:      8/8 (100%)
 - Enhanced Functions:     8/8 (100%)
 
WEIGHTED OVERALL COVERAGE: 98.2%
