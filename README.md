# ogenc

**ogenc** — набор готовых CMake-файлов и утилит для включения максимально полного набора предупреждений (и опционально флагов оптимизации) компиляторов **g++** и **clang++**, с учётом версии компилятора.

Идея простая:

1. Взять почти все доступные `-W…` для данной версии компилятора.
2. По умолчанию выключить заведомо шумные/бесполезные.
3. Подключить это к таргетам проекта одной функцией.

Репозиторий: https://github.com/migashko/ogenc  
Лицензия: MIT (см. `LICENSE`).

---

## Для кого этот документ

Есть два сценария использования:

| Сценарий | Что нужно |
|---|---|
| **Подключить ogenc к своему проекту** | Каталог `cmake/` (и содержимое). Скрипты `ogenc*` не обязательны. |
| **Перегенерировать списки опций** под новые компиляторы | Весь репозиторий, bash, установленные g++/clang++ |

Большинству пользователей достаточно первого сценария.

---

## Краткий справочник CMake-опций

| Опция | По умолчанию | Смысл |
|---|---|---|
| `DISABLE_WARNINGS` | OFF | Полностью отключить warnings от ogenc |
| `OGENC_WERROR` | ON | Добавлять `-Werror` |
| `EXTRA_WARNINGS` | ON | `-Wextra -Wpedantic -Wformat -pedantic-errors` |
| `PARANOID_WARNINGS` | OFF | Полный набор `-W…` по версии компилятора |
| `OGENC_WARNINGS` | OFF | Синоним `PARANOID_WARNINGS` |
| `APOCALYPTIC_WARNINGS` | OFF | См. [APOCALYPTIC_WARNINGS](#apocalyptic_warnings) |
| `OGENC_OPTIMIZE` | OFF | Подключить каталог optimize; условие для `target_ogenc_optimize` |

## Краткий справочник функций

| Функция | Назначение |
|---|---|
| `target_ogenc_warnings(target)` | Навесить выбранный уровень предупреждений на таргет |
| `target_ogenc_optimize(target)` | Навесить optimize-опции ogenc (если включены) |
| `ogenc_warning(-Wflag ON\|OFF)` | Глобально включить/выключить предупреждение |
| `ogenc_optimize(-fflag ON\|OFF)` | Глобально включить/выключить optimize-флаг |
| `update_ogenc(TARGETS/SOURCES … WARNINGS/OPTIMIZE … ON\|OFF)` | То же для таргетов и/или единиц трансляции |

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

Без `PARANOID_WARNINGS` ogenc всё равно даёт базовый набор (`-Wall`, при `OGENC_WERROR` ещё `-Werror`, при `EXTRA_WARNINGS` ещё `-Wextra` и pedantic), но **полный** список предупреждений из сгенерированных файлов включается только в paranoid-режиме.

---

## Уровни предупреждений

`target_ogenc_warnings(<target>)` включает флаги в зависимости от CMake-опций:

| Режим | Как включить | Что примерно добавляется |
|---|---|---|
| Выключено | `-DDISABLE_WARNINGS=ON` | Ничего |
| Базовый | по умолчанию (`DISABLE_WARNINGS=OFF`) | `-Wall`, при `OGENC_WERROR` ещё `-Werror` |
| Extra | `-DEXTRA_WARNINGS=ON` (по умолчанию **ON**) | плюс `-Wextra -Wpedantic -Wformat -pedantic-errors` |
| Paranoid | `-DPARANOID_WARNINGS=ON` или `-DOGENC_WARNINGS=ON` | плюс почти все `-W…` для вашей версии g++/clang++ |

Замечания:

- `EXTRA_WARNINGS` по умолчанию **включён**. Чтобы остаться только на `-Wall` (и `-Werror`, если не выключен), передайте `-DEXTRA_WARNINGS=OFF`.
- `PARANOID_WARNINGS` и `OGENC_WARNINGS` — синонимы.
- `DISABLE_WARNINGS=ON` отключает всё, что навешивает `target_ogenc_warnings`, независимо от остальных флагов.
- `-Werror` можно отключить: `-DOGENC_WERROR=OFF`.
- Для субмодулей и сторонних библиотек см. [APOCALYPTIC_WARNINGS](#apocalyptic_warnings).

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

Пример таргета — `example/demo1.cpp` (+ `demo1_target.cpp`, `demo1_tu.cpp`). Подключение и три способа выключить предупреждение — в `example/CMakeLists.txt`:

```cmake
include(../cmake/ogenc.cmake)

# глобально (все таргеты, paranoid)
ogenc_warning(-Wzero-as-null-pointer-constant OFF)

add_executable(demo1 demo1.cpp demo1_target.cpp demo1_tu.cpp)
set_target_properties(demo1 PROPERTIES CXX_STANDARD 11 CXX_EXTENSIONS OFF)

# для цели (paranoid) и для единицы трансляции (любой уровень)
update_ogenc(
  TARGETS demo1
  SOURCES demo1_tu.cpp
  WARNINGS -Wswitch-enum -Wfloat-equal
  OFF
)

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

`TARGETS` в `update_ogenc` применяются только если включён `PARANOID_WARNINGS` (и до `target_ogenc_warnings`). `SOURCES` работают на любом уровне: `OFF` добавляет `-Wno-…` на указанные исходники.

Можно смешивать с обычными флагами CMake:

```cmake
target_ogenc_warnings(myapp)
target_compile_options(myapp PRIVATE -Wno-unused-parameter)
```

### Для одной единицы трансляции

```cmake
update_ogenc(
  SOURCES legacy.cpp
  WARNINGS -Wfloat-equal
  OFF
)
target_ogenc_warnings(myapp)
```

В одном вызове можно указать и цели, и файлы — список `WARNINGS` применяется к обеим областям.

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
```

По умолчанию отдельные optimize-флаги в сгенерированных файлах идут как **OFF**. `OGENC_OPTIMIZE` не включает «всё подряд»: это каталог и API `ogenc_optimize(...)` / `update_ogenc(... OPTIMIZE ...)`, чтобы точечно включать нужное:

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
./scripts/ogenc-compilers update     # обновить кэш доступных компиляторов
./scripts/ogenc-compilers generator  # показать g++, выбранный как источник --help
./scripts/ogenc-versions name /usr/bin/g++-12
```

Отдельные стадии (если нужно точечно):

```bash
./scripts/ogenc-generator warnings /usr/bin/g++-12
./scripts/ogenc-generator optimize /usr/bin/clang++
./scripts/ogenc-splitter warnings
./scripts/ogenc-splitter optimize
./scripts/ogenc-cmake warnings
./scripts/ogenc-cmake optimize
```

### Побочные файлы при генерации

При проверке некоторых флагов (например `-fsave-optimization-record`) компилятор может создать рядом артефакты вроде:

```text
*.opt-record.json.gz   # g++
*.opt.yaml             # clang++
```

Их можно удалять — на работу ogenc они не влияют. Шаблоны уже есть в `.gitignore`.

---

## Рекомендуемый рабочий процесс в своём проекте

1. Подключить `ogenc.cmake` и вызвать `target_ogenc_warnings` на своих таргетах (не на чужих submodule, если не готовы их чинить).
2. Сначала собрать с Extra (дефолт): `-Wall -Wextra -Wpedantic …`.
3. Включить `-DPARANOID_WARNINGS=ON` и пройтись по новым предупреждениям.
4. Точечно глушить шум через `ogenc_warning(… OFF)` / `update_ogenc` / `-Wno-…`, а не отключать paranoid целиком.
5. Держать `-Werror` (по умолчанию через `OGENC_WERROR`) только если команда готова не копить предупреждения. Выключить: `-DOGENC_WERROR=OFF`.

Для библиотек с публичными заголовками учитывайте, что часть paranoid-флагов может быть агрессивной для API (`-Wabi*`, `-Wpadded` и т.п. — в upstream-репозитории они обычно в `disabled.txt`).

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
scripts/                       # стадии конвейера (compilers, generator, splitter, cmake, …)
```

---

## Ограничения

- Ориентация на **g++** и **clang++** (C++).
- Набор флагов — снимок возможностей установленных при генерации компиляторов; совсем новый major может потребовать `./ogenc`.
- Некоторые флаги из `--help` компилятора намеренно игнорируются или выключены — см. `config/ignored.txt` и `config/disabled.txt`.
- Paranoid-режим может требовать правок кода или точечных `-Wno-…`; это ожидаемо.

---

## APOCALYPTIC_WARNINGS

Для **своего** кода обычно включают `-DPARANOID_WARNINGS=ON`. Для **субмодулей и сторонних библиотек** полный paranoid часто избыточен: чужой код уже прогоняют в своём CI, а у вас он только раздувает лог и ломает сборку.

Рекомендуемое поведение:

1. По умолчанию перед `add_subdirectory` / подключением зависимости **выключать** `PARANOID_WARNINGS` (и `OGENC_WARNINGS`).
2. Если нужно прогнать paranoid и по зависимостям — собрать с `-DAPOCALYPTIC_WARNINGS=ON`.

Сам ogenc дерево `add_subdirectory` **не** обходит. `APOCALYPTIC_WARNINGS` только включает `PARANOID_WARNINGS` и служит сигналом для **вашей** обёртки.

Пример:

```cmake
function(my_add_subdirectory)
  cmake_parse_arguments(arg "WARNINGS" "PATH" "" ${ARGN})
  if (NOT arg_PATH)
    message(FATAL_ERROR "PATH is required")
  endif()

  # По умолчанию не тащим paranoid в чужой код.
  # Apocalyptic — принудительно оставить paranoid и для субмодуля.
  if (NOT APOCALYPTIC_WARNINGS AND NOT arg_WARNINGS)
    set(PARANOID_WARNINGS OFF)
    set(OGENC_WARNINGS OFF)
  endif()

  add_subdirectory("${PROJECT_SOURCE_DIR}/${arg_PATH}")
endfunction()

# обычная сборка: свой код с paranoid, зависимость — без
my_add_subdirectory(PATH third_party/foo)

# зависимость тоже под paranoid (например, разовый прогон)
my_add_subdirectory(PATH third_party/foo WARNINGS)
```

Сборка:

```bash
# свой проект с paranoid; субмодули без (если обёртка как выше)
cmake -S . -B build -DPARANOID_WARNINGS=ON

# paranoid и для зависимостей
cmake -S . -B build -DAPOCALYPTIC_WARNINGS=ON
```

`-DAPOCALYPTIC_WARNINGS=ON` сам по себе включает `PARANOID_WARNINGS` в корне; смысл флага — не отключать его в обёртках при подключении субмодулей.
