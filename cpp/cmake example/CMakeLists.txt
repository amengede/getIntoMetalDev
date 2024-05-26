cmake_minimum_required(VERSION 3.28.0)
project(test VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 20)

add_executable(test
    src/backend/glfw_adapter.mm

    src/main.cpp
)

target_include_directories(test
    PRIVATE
    dependencies
)

find_library(METAL Metal)
find_library(FOUNDATION Foundation)
find_library(QUARTZCORE QuartzCore)
find_library(APPKIT AppKit)

target_link_libraries(test 
    stdc++ 
    "-framework Metal" 
    "-framework Foundation" 
    "-framework QuartzCore"
    "-framework AppKit" objc)

target_link_libraries(test
    glfw
)