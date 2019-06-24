#include<iostream>


int count_lines(const std::string &file)
{
    std::ifstream in(file);

    return std::count(std::istreambuf_iterator<char>(in),
                      std::istreambuf_iterator<char>(),
                      '\n');
}

// std::vector<int> counter(const std::vector<string> &files)
// {
// 
// }

int main()
{

    return 0;
}
