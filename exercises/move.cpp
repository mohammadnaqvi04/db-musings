#include <iostream>

void steal_my_vec(std::vector<int> &&other) {
    std::vector<int> stolen_vec = std::move(other);
    stolen_vec.push_back(11);

    std::cout << "This is the stolen vec " << stolen_vec[5] << std::endl;
    std::cout << "This is the memory address " << stolen_vec.data() << std::endl;

}

int main() {
    // Write out example moving a value from one place to another using a function
    std::vector<int> my_vec = {6,7,8,9,10};
    std::cout << "This is the unstolen vec " << my_vec[4] << std::endl;
    std::cout << "This is the memory address " << my_vec.data() << std::endl;
    steal_my_vec(std::move(my_vec));

}
