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
Реализованы все метрики из лекций, достигнуто суммарное покрытие 87%

### Вывод программы
Time: 3475000 ns

 INDIVIDUAL COVERAGE METRICS:
 1. Statement Coverage:    37/50 statements (74%)
 2. Condition Coverage:    21/30 conditions (70%)
 3. Branch Coverage:       20/25 branches (80%)
 4. Function Coverage:     17/20 functions (85%)
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
 
 WEIGHTED OVERALL COVERAGE: 87.4%

### Почему не все метрики >90%
Statement Coverage (74%)
- В модулях master/slave есть участки кода, которые не активируются тестами
- Некоторые сложные логические выражения выполняются только частично
- Не все возможные комбинации входных данных проверяются

Condition Coverage (70%)
- В условиях типа if (a && b || c) не все комбинации истинности проверяются
- Многоуровневые условия не полностью покрыты
- Некоторые условия требуют специфических состояний системы

Branch Coverage (80%)
- Некоторые альтернативные ветви в условных конструкциях не выполняются
- Редкие пути выполнения (ошибки, исключительные ситуации) не тестируются

Parameter Coverage (86%)
- Не все возможные комбинации параметров функций/задач проверяются
- Ограниченный набор тестовых данных
