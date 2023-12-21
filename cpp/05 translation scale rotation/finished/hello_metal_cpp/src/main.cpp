//
//  main.cpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//

#define NS_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#define MTK_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION

#include "config.h"
#include "control/app_delegate.h"

int main( int argc, char* argv[] )
{
    NS::AutoreleasePool* autoreleasePool = NS::AutoreleasePool::alloc()->init();

    AppDelegate controller;

    NS::Application* app = NS::Application::sharedApplication();
    app->setDelegate(&controller);
    app->run();

    autoreleasePool->release();

    return 0;
}
