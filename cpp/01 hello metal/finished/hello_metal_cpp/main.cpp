//
//  main.cpp
//  hello_metal_cpp
//
//  Created by Andrew Mengede on 15/9/2023.
//
#include "config.h"
#include "control/app_delegate.h"
#include "release.h"

int main( int argc, char* argv[] )
{
    const release_ptr<NS::AutoreleasePool> autoreleasePool(NS::AutoreleasePool::alloc()->init());

    AppDelegate controller;

    NS::Application* app = NS::Application::sharedApplication();
    app->setDelegate(&controller);
    app->run();

    return 0;
}
