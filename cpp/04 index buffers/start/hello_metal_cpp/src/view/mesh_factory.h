//
//  mesh_factory.hpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 18/12/2023.
//

#pragma once
#include "../config.h"

namespace MeshFactory {
    MTL::Buffer* build_triangle(MTL::Device* device);
}
