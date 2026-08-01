#include <assert.h>
#include <iostream>

class MyData {
private:
  static const int buffer_size = 5;

public:
  int *buffer;
  MyData(int nums[], int buffer_size) {
    buffer = new int[buffer_size];

    for (int i = 0; i < buffer_size; i++) {
      buffer[i] = nums[i];
    }

    std::cout << "Constructor called" << std::endl;
  }

  MyData(const MyData &source) {
    buffer = new int[buffer_size];

    for (int i = 0; i < buffer_size; i++) {
      buffer[i] = source.buffer[i];
    }

    std::cout << "Copy constructor was used" << std::endl;
  }

  MyData(MyData &&being_moved) : buffer(being_moved.buffer) {
    // Null this out to avoid issues with the destructor
    being_moved.buffer = nullptr;
    std::cout << "Move constructor was used" << std::endl;
  }

  // Move overload assignment called
  MyData &operator=(MyData &&being_moved) {
    std::cout << "Move assignment operator is being used" << std::endl;
    buffer = being_moved.buffer;
    being_moved.buffer = nullptr;
    return *this;
  }

  ~MyData() {
    delete[] buffer;
    std::cout << "Destructor called" << std::endl;
  }
};

int main() {

  int arr[] = {1, 2, 3, 4, 5};
  MyData instance = MyData(arr, 5);

  // copy constructor
  MyData otherInstance = instance;

  MyData stealingInstance = std::move(otherInstance);

  int pirate[] = {6, 7, 8, 9, 10};
  MyData stealingAgainInstance = MyData(pirate, 5);
  stealingAgainInstance = std::move(stealingInstance);
  assert(stealingInstance.buffer == nullptr);
}
