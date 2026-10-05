# ogenc

**ogenc** — набор готовых CMake-файлов и утилит для включения максимально полного набора предупреждений (и опционально флагов оптимизации) компиляторов **g++** и **clang++**, с учётом версии компилятора.

Идея простая:

1. Взять почти все доступные `-W…` для данной версии компилятора.
2. По умолчанию выключить заведомо шумные/бесполезные.
3. Подключить это к таргетам проекта одной функцией.

Репозиторий: https://github.com/migashko/ogenc

---

## Для кого этот документ

Есть два сценария использования:

| Сценарий | Что нужно |
|---|---|
| **Подключить ogenc к своему проекту** | Каталог `cmake/` (и содержимое). Скрипты `ogenc*` не обязательны. |
| **Перегенерировать списки опций** под новые компиляторы | Весь репозиторий, bash, установленные g++/clang++ |

Большинству пользователей достаточно первого сценария.

---

## Быстрый старт (подключение к проекту)

### 1. Добавьте ogenc в проект

Скопируйте или подключите как submodule/FetchContent так, чтобы был доступен файл:

```text
…/cmake/ogenc.cmake
```

### 2. Подключите в `CMakeLists.txt`

```cmake
include(path/to/cmake/ogenc.cmake)

add_executable(myapp main.cpp)
target_ogenc_warnings(myapp)

# опционально — доп. флаги оптимизации из ogenc
# target_ogenc_optimize(myapp)
```

### 3. Соберите с нужным уровнем строгости

```bash
cmake -S . -B build -DPARANOID_WARNINGS=ON
cmake --build build
```

Без `PARANOID_WARNINGS` ogenc всё равно даёт базовый набор (`-Werror -Wall`, при `EXTRA_WARNINGS` ещё `-Wextra` и pedantic), но **полный** список предупреждений из сгенерированных файлов включается только в paranoid-режиме.

---

## Уровни предупреждений

`target_ogenc_warnings(<target>)` включает флаги в зависимости от CMake-опций:

| Режим | Как включить | Что примерно добавляется |
|---|---|---|
| Выключено | `-DDISABLE_WARNINGS=ON` | Ничего |
| Базовый | по умолчанию (`DISABLE_WARNINGS=OFF`) | `-Werror -Wall` |
| Extra | `-DEXTRA_WARNINGS=ON` (по умолчанию **ON**) | плюс `-Wextra -Wpedantic -Wformat -pedantic-errors` |
| Paranoid | `-DPARANOID_WARNINGS=ON` или `-DOGENC_WARNINGS=ON` | плюс почти все `-W…` для вашей версии g++/clang++ |

Замечания:

- `EXTRA_WARNINGS` по умолчанию **включён**. Чтобы остаться только на `-Werror -Wall`, передайте `-DEXTRA_WARNINGS=OFF`.
- `PARANOID_WARNINGS` и `OGENC_WARNINGS` — синонимы.
- `APOCALYPTIC_WARNINGS=ON` просто включает `PARANOID_WARNINGS` (удобно прокидывать «максимум строгости» в дерево с зависимостями).
- `DISABLE_WARNINGS=ON` отключает всё, что навешивает `target_ogenc_warnings`, независимо от остальных флагов.

Те же опции можно задать переменными окружения **до** первого конфигурирования CMake (если соответствующая CMake-переменная ещё не задана):

```bash
export PARANOID_WARNINGS=ON
cmake -S . -B build
```

---

## Пример из репозитория

В корне:

```bash
make            # обычная сборка example/
make extra      # EXTRA_WARNINGS
make paranoid   # PARANOID_WARNINGS
make clean
```

Пример таргета — `example/demo1.cpp`, подключение в `example/CMakeLists.txt`:

```cmake
include(../cmake/ogenc.cmake)
add_executable(demo1 demo1.cpp)
set_target_properties(demo1 PROPERTIES CXX_STANDARD 11 CXX_EXTENSIONS OFF)
target_ogenc_warnings(demo1)
```

---

## Тонкая настройка предупреждений

### Выключить/включить одну опцию глобально (до `target_ogenc_warnings`)

```cmake
include(path/to/cmake/ogenc.cmake)

# имеет смысл при PARANOID_WARNINGS=ON
ogenc_warning(-Wshadow OFF)
ogenc_warning(-Wconversion ON)

add_executable(myapp main.cpp)
target_ogenc_warnings(myapp)
```

### Настройки для конкретных таргетов

```cmake
update_ogenc(
  TARGETS app1 app2
  WARNINGS -Wshadow -Wpadded
  OFF
)

update_ogenc(
  TARGETS app1
  WARNINGS -Wconversion
  ON
)

target_ogenc_warnings(app1)
target_ogenc_warnings(app2)
```

`update_ogenc` работает только если включён `PARANOID_WARNINGS`.

Можно смешивать с обычными флагами CMake:

```cmake
target_ogenc_warnings(myapp)
target_compile_options(myapp PRIVATE -Wno-unused-parameter)
```

---

## Оптимизации (`target_ogenc_optimize`)

Помимо предупреждений ogenc умеет подключать набор `-f…` флагов оптимизации (тоже с разбивкой по версиям компилятора).

```cmake
include(path/to/cmake/ogenc.cmake)

add_executable(myapp main.cpp)
target_ogenc_warnings(myapp)
target_ogenc_optimize(myapp)
```

Включение:

```bash
cmake -S . -B build -DOGENC_OPTIMIZE=ON
# или
cmake -S . -B build -DPARANOID_OPTIMIZE=ON
```

По умолчанию отдельные optimize-флаги в сгенерированных файлах идут как **OFF** — то есть paranoid-optimize не включает «всё подряд автоматически», а даёт инфраструктуру `ogenc_optimize(...)` / `update_ogenc(... OPTIMIZE ...)`, чтобы точечно включать нужное:

```cmake
ogenc_optimize(-ffast-math ON)   # пример; конкретные имена смотрите в cmake/ogenc/gen/optimize-*.cmake

update_ogenc(
  TARGETS myapp
  OPTIMIZE -ffast-math
  ON
)
```

На практике большинство пользователей используют только warnings-часть.

---

## Как ogenc выбирает флаги под ваш компилятор

При `PARANOID_WARNINGS=ON` подключаются файлы вида:

```text
cmake/ogenc/gen/warnings-g++.cmake
cmake/ogenc/gen/warnings-clang++.cmake
```

Они по `CMAKE_CXX_COMPILER_ID` и `CMAKE_CXX_COMPILER_VERSION` включают слои:

```text
warnings-g++-4.8.cmake
warnings-g++-5.3.cmake
…
warnings-g++-14.2.cmake
```

Каждый слой добавляет опции, которые появились (или стали актуальны) начиная с этой версии. На g++ 12 вы получите объединение всех слоёв ≤ 12.

Аналогично для clang++ и для optimize-файлов.

В каждом `ogenc_warning(-Wfoo "…" ON|OFF)`:

- **ON** — флаг попадёт в список по умолчанию;
- **OFF** — флаг известен, но по умолчанию выключен (можно включить через `ogenc_warning` / `update_ogenc`).

---

## Перегенерация списков (для сопровождающих репозиторий)

Готовые файлы в `cmake/ogenc/gen/` и `lists/` уже можно использовать as-is. Перегенерация нужна, когда появляется новый компилятор или вы хотите пересмотреть disabled/enabled.

### Требования

- bash
- установленные компиляторы из `config/compilers.txt`
- для генерации описаний желателен свежий **g++** (он используется как источник `--help=warnings` / `--help=optimize`)

### Конфигурация

| Файл | Назначение |
|---|---|
| `config/compilers.txt` | Пути к компиляторам, которые нужно просканировать |
| `config/ignored.txt` | Опции, которые **не попадают** в итоговые списки (уже покрыты уровнями Wall/Extra, мета-флаги и т.п.) |
| `config/disabled.txt` | Опции, которые попадают в cmake как **OFF** по умолчанию (шумные/бесполезные) |
| `config/enabled.txt` | Опции, которые принудительно остаются **ON** (даже если иначе попали бы под другую логику) |

Типичный подход к `disabled.txt`: включить всё, что возможно, затем занести в disabled то, что на реальных проектах даёт только шум (`-Weffc++`, `-Wsystem-headers`, `-Wtemplates`, …).

### Запуск

```bash
# по желанию — подробный лог
export VERBOSE=1

./ogenc
```

Конвейер:

1. Для каждого доступного компилятора из `config/compilers.txt` собирает сырые списки warnings/optimize.
2. Отфильтровывает `ignored.txt`.
3. Раскладывает опции по версиям (`lists/`, `lists/all/`).
4. Генерирует `cmake/ogenc/gen/*.cmake`.

Вспомогательно:

```bash
./ogenc-compilers update     # обновить кэш доступных компиляторов
./ogenc-compilers generator  # показать g++, выбранный как источник --help
./ogenc-versions name /usr/bin/g++-12
```

Отдельные стадии (если нужно точечно):

```bash
./ogenc-generator warnings /usr/bin/g++-12
./ogenc-generator optimize /usr/bin/clang++
./ogenc-splitter warnings
./ogenc-splitter optimize
./ogenc-cmake warnings
./ogenc-cmake optimize
```

### Побочные файлы при генерации

При проверке некоторых флагов (например `-fsave-optimization-record`) компилятор может создать рядом артефакты вроде:

```text
*.opt-record.json.gz   # g++
*.opt.yaml             # clang++
```

Их можно удалять — на работу ogenc они не влияют. Имеет смысл добавить такие шаблоны в `.gitignore`.

---

## Рекомендуемый рабочий процесс в своём проекте

1. Подключить `ogenc.cmake` и вызвать `target_ogenc_warnings` на своих таргетах (не на чужих submodule, если не готовы их чинить).
2. Сначала собрать с Extra (дефолт): `-Wall -Wextra -Wpedantic …`.
3. Включить `-DPARANOID_WARNINGS=ON` и пройтись по новым предупреждениям.
4. Точечно глушить шум через `ogenc_warning(… OFF)` / `update_ogenc` / `-Wno-…`, а не отключать paranoid целиком.
5. Держать `-Werror` (ogenc добавляет его в базовом режиме) только если команда готова не копить предупреждения.

Для библиотек с публичными заголовками учитывайте, что часть paranoid-флагов может быть агрессивной для API (`-Wabi*`, `-Wpadded` и т.п. — в upstream-репозитории они обычно в `disabled.txt`).

---

## Краткий справочник CMake-опций

| Опция | По умолчанию | Смысл |
|---|---|---|
| `DISABLE_WARNINGS` | OFF | Полностью отключить warnings от ogenc |
| `EXTRA_WARNINGS` | ON | `-Wextra -Wpedantic -Wformat -pedantic-errors` |
| `PARANOID_WARNINGS` | OFF | Полный набор `-W…` по версии компилятора |
| `OGENC_WARNINGS` | OFF | Синоним `PARANOID_WARNINGS` |
| `APOCALYPTIC_WARNINGS` | OFF | Включает `PARANOID_WARNINGS` |
| `PARANOID_OPTIMIZE` | OFF | Подключить optimize-инфраструктуру ogenc |
| `OGENC_OPTIMIZE` | OFF | Синоним / условие для `target_ogenc_optimize` |

## Краткий справочник функций

| Функция | Назначение |
|---|---|
| `target_ogenc_warnings(target)` | Навесить выбранный уровень предупреждений на таргет |
| `target_ogenc_optimize(target)` | Навесить optimize-опции ogenc (если включены) |
| `ogenc_warning(-Wflag ON\|OFF)` | Глобально включить/выключить предупреждение |
| `ogenc_optimize(-fflag ON\|OFF)` | Глобально включить/выключить optimize-флаг |
| `update_ogenc(TARGETS … WARNINGS/OPTIMIZE … ON\|OFF)` | То же для списка таргетов |

---

## Структура репозитория (ориентир)

```text
cmake/ogenc.cmake              # точка входа для проектов
cmake/ogenc/ogenc-option.cmake # ogenc_warning / update_ogenc / …
cmake/ogenc/gen/               # сгенерированные слои по версиям компиляторов
config/                        # compilers / ignored / disabled / enabled
lists/                         # списки опций, появившихся в конкретной версии
lists/all/                     # полные списки опций для версии
example/                       # демо-таргет
ogenc                          # полный цикл перегенерации
ogenc-*                        # отдельные стадии конвейера
```

---

## Ограничения

- Ориентация на **g++** и **clang++** (C++).
- Набор флагов — снимок возможностей установленных при генерации компиляторов; совсем новый major может потребовать `./ogenc`.
- Некоторые флаги из `--help` компилятора намеренно игнорируются или выключены — см. `config/ignored.txt` и `config/disabled.txt`.
- Paranoid-режим может требовать правок кода или точечных `-Wno-…`; это ожидаемо.
