#include "demo1.hpp"

// Только для этой единицы трансляции: COMPILE_OPTIONS -Wno-float-equal
int demo1_tu()
{
  double x = 1.0;
  return x == 1.0 ? 1 : 0;
}
