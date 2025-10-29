cmake_minimum_required(VERSION 3.28.0)
project(my_project VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 20)

add_executable(my_project
    src/main.cpp

    src/backend/glfw_adapter.mm
    src/backend/mtlm.cpp

    src/control/app.cpp

    src/model/camera.cpp

    src/view/image.cpp
    src/view/mesh.cpp
    src/view/mesh_factory.cpp
    src/view/pipeline_factory.cpp
    src/view/renderer.cpp
    src/view/vertex_formats.cpp
)

find_package(glfw3 3.3 REQUIRED)

target_include_directories(my_project
    PRIVATE
    dependencies
)

find_library(METAL Metal)
find_library(FOUNDATION Foundation)
find_library(QUARTZCORE QuartzCore)
find_library(APPKIT AppKit)

target_link_libraries(my_project 
    stdc++ 
    "-framework Metal" 
    "-framework Foundation" 
    "-framework QuartzCore"
    "-framework AppKit" objc)

target_link_libraries(my_project
    glfw
)