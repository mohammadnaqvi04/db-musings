// Quick example showcasing deleting copy constructor, copy assignment operator
// to keep only a single instance active at any time.
#include <iostream>
#include <string>
#include <vector>

class Thermos {
private:
  std::string name_;
  std::vector<std::string> competitors_;

public:
  // Regular constructor that efficiently creates a thermos object
  // without copying the passed competitors vector
  Thermos(std::string name, std::vector<std::string> &&competitors)
      : name_(name), competitors_(competitors) {}

  // move constructor
  Thermos(Thermos &&other) {
    name_ = other.name_;
    competitors_ = other.competitors_;
  }
  // move assignment operator
  Thermos &operator=(Thermos &&other) {
    name_ = other.name_;
    competitors_ = other.competitors_;
    return *this;
  }

  // Deleting the copy constructor + move assignment operator
  Thermos(const Thermos &o) = delete;
  Thermos &operator=(Thermos &o) = delete;
};

int main() {}
