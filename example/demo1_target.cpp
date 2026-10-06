#include "demo1.hpp"

enum Color { Red, Green, Blue };

// Для цели demo1 выключено: update_ogenc(... WARNINGS -Wswitch-enum OFF)
int demo1_target()
{
  Color color = Red;
  switch (color)
  {
  case Red:
    return 0;
  case Green:
    return 1;
  default:
    return -1;
  }
}
