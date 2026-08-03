#include <iostream>
#include <string>

template <typename T> T max_val(T a, T b) { return a > b ? a : b; }

template <typename T, typename U> void print_pair(T a, U b) {
  std::cout << "Here is a: " << a << " and here is b: " << b << std::endl;
}

template <typename T> void describe(T a) {
  std::cout << "generic type" << std::endl;
}

template <> void describe<int>(int a) { std::cout << "int type" << std::endl; }

template <bool T> int clamp_or_not(int val) {
  if (T) {
    return val + 27;
  }
  return val;
}

int main() {
  std::cout << max_val<float>(2.4, 4.0) << std::endl;

  print_pair<int, std::string>(4, "Hello");

  describe<float>(4.0);
  describe<int>(4);

  std::cout << "Printing clamp_or_not<true>(18): " << clamp_or_not<true>(18)
            << std::endl;
  std::cout << "Printing clamp_or_not<true>(18): " << clamp_or_not<false>(18)
            << std::endl;

  std::cout << "testing max_val() and print_pair() w/out types" << std::endl;

  std::cout << max_val(4, 5) << std::endl;
  print_pair(7.3, "Sowed");
}
