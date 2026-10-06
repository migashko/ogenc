#include "demo1.hpp"

// Глобально выключено: ogenc_warning(-Wzero-as-null-pointer-constant OFF)
int demo1_global()
{
  int* pointer = 0;
  return pointer == 0 ? 0 : 1;
}

int main()
{
  return demo1_global() + demo1_target() + demo1_tu();
}
