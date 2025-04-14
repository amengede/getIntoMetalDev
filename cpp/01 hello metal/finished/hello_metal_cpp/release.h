//
//  release.h
//  hello_metal_cpp
//
//  Created by Dr. Colin Hirsch on 04/11/23.
//
#pragma once

#include <memory>

struct release_delete
{
    void operator()(auto* t) const
    {
        if(t != nullptr) {
            t->release();
        }
    }
};

template<typename T>
using release_ptr = std::unique_ptr<T, release_delete >;
