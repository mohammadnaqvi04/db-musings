/*
 * Make a simple wrapper around a raw int* buffer. Concretely, write a class
 that:

  1. Allocates an int* in its constructor, frees it in the destructor.
  2. Has a copy constructor that deep-copies the buffer.
  3. Has a move constructor that steals the pointer and sets the source's
 pointer to nullptr.
  4. Has a move assignment operator too (this one's slightly different from the
 constructor — you also have to free your own existing buffer first before
 stealing the new one).
  5. A main() that constructs one, moves it into another via std::move, and
 prints/asserts that the source's pointer is now nullptr (proving the theft
 actually happened, not just a relabeling).
  */

#include <iostream>;

class MyData {
private:
  static const int buffer_size = 20;
  int *buffer;

public:
  // Where constructors, overload assignment operators, and destructor lives

  // Constructor
  MyData(int buffer_size) { buffer = new int[buffer_size]; }

  // Copy constructor
  MyData(const MyData &source) {

    std::cout << "Copy constructor was used" << std::endl;
  }

  // Move constructor
};

int main() {}
