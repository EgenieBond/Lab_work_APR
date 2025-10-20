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
Реализованы все метрики из лекций, достигнуто суммарное покрытие 93%

### Вывод программы
Time: 3475000 ns

 INDIVIDUAL COVERAGE METRICS:
 1. Statement Coverage:    37/45 statements (82%)
 2. Condition Coverage:    21/25 conditions (84%)
 3. Branch Coverage:       20/22 branches (90%)
 4. Function Coverage:     17/18 functions (94%)
 5. FSM State Coverage:    3/3 states (100%)
 6. Toggle Coverage:       275/80 toggles (100%)
 7. Parameter Coverage:    26/30 values (86%)
 
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
 
 WEIGHTED OVERALL COVERAGE: 92.6%

