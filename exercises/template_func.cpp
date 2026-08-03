/*
 * Spec:
 * 1. max_val<T>(T a, T b) - templated function, returns the larger of two
 * values.
 * 2. print_pair<T, U>(T a, U b) - two different template types, prints "a, b".
 * 3. describe<T>() - prints "generic type" for any T, but write a
 * specialization for <int> that prints "int type" instead.

 * 4. clamp_or_not<bool Clamp>(int val) - non-type bool template param. If Clamp
 *    is true, clamp val to [0, 100]; if false, return val unchanged.
 *
 * In main(): call each with explicit template args, then call max_val and
 * print_pair once WITHOUT explicit args and confirm the compiler deduces them.
 */

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
