#!/usr/bin/env python3

from ev3dev.ev3 import LargeMotor
import time

motorA = LargeMotor('outA')

# Заданные напряжения (в процентах)
voltages = [100, 80, 60, 40, 20, -20, -40, -60, -80, -100]

try:
    for vol in voltages:
        # Запоминаем начальное время и позицию мотора
        timeStart = time.time()
        startPos = motorA.position

        # Создаём имя файла для сохранения данных
        name = "data_{}.txt".format(vol)
        with open(name, "w") as file:
            while True:
                # Текущее время относительно старта
                timeNow = time.time() - timeStart

                # Устанавливаем скорость мотора
                motorA.run_direct(duty_cycle_sp=vol)

                # Текущая позиция мотора
                pos = motorA.position - startPos

                # Сохраняем данные в файл (время, положение, скорость)
                file.write("{} {} {}\n".format(timeNow, pos, motorA.speed))

                # Прекращаем запись после 1 секунды
                if timeNow > 1:
                    motorA.run_direct(duty_cycle_sp=0)
                    motorA.stop()
                    time.sleep(3)
                    break

except Exception as e:
    # Вывод ошибок
    print(e)

finally:
    # Останавливаем мотор и закрываем файл
    motorA.stop(stop_action='brake')
