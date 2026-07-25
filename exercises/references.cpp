#include <iostream>


void add_three(int &a) {a = a + 3;}

int main() {
    int a = 10;
    add_three(a);
    int *b = &a;

    std::cout << *b << std::endl;
};
