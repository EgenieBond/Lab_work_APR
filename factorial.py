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

if __name__ == "__main__":
    try:
        num = int(input("Введите число для вычисления факториала: "))
        print(f"Факториал {num} равен {factorial(num)}")
    except ValueError:
        print("Ошибка: введите целое число")