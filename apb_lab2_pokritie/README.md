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
Реализованы все метрики из лекций, достигнуто суммарное покрытие 85%

### Вывод программы
 INDIVIDUAL COVERAGE METRICS:
1. Statement Coverage:    20/30 statements (66%)
2. Condition Coverage:    21/25 conditions (84%)
3. Branch Coverage:       11/20 branches (55%)
4. Function Coverage:     11/15 functions (73%)
5. FSM State Coverage:    3/3 states (100%)
6. Toggle Coverage:       172/60 toggles (100%)
7. Parameter Coverage:    22/20 values (100%)
 
FUNCTIONAL COVERAGE BREAKDOWN:
- FSM States:             3/3 (100%)
- Cos Angles:             8/8 (100%)
- Basic Operations:       8/8 (100%)
- Boundary Cases:         4/4 (100%)
- Error Cases:            1/1 (100%)
- Additional Tests:       6/6 (100%)
 WEIGHTED OVERALL COVERAGE: 85.3%
