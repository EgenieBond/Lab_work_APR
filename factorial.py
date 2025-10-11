def factorial(n):
    """Вычисляет факториал числа"""
    if n < 0:
        return "Факториал отрицательного числа не определен"
    elif n == 0:
        return 1
    else:
        result = 1
        for i in range(1, n + 1):
            result *= i
        return result


def fibonacci(n):
    """Вычисляет n-ное число Фибоначчи"""
    if n <= 0:
        return "Введите положительное число"
    elif n == 1:
        return 0
    elif n == 2:
        return 1
    else:
        a, b = 0, 1
        for _ in range(n - 2):
            a, b = b, a + b
        return b


if __name__ == "__main__":
    print("=== Калькулятор математических функций ===")
    print("1 - Вычислить факториал")
    print("2 - Вычислить число Фибоначчи")

    choice = input("Выберите операцию (1 или 2): ")

    try:
        if choice == "1":
            num = int(input("Введите число для вычисления факториала: "))
            print(f"Факториал {num} равен {factorial(num)}")
        elif choice == "2":
            num = int(input("Введите номер числа Фибоначчи: "))
            print(f"Число Фибоначчи №{num} равно {fibonacci(num)}")
        else:
            print("Неверный выбор. Запустите программу снова.")
    except ValueError:
        print("Ошибка: введите целое число")