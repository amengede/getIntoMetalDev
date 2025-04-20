//
//  app_delegate.cpp
//  metal_test
//
//  Created by Andrew Mengede on 13/9/2023.
//
#include "app_delegate.h"

void AppDelegate::applicationWillFinishLaunching(NS::Notification* notification)
{
    NS::Application* app = reinterpret_cast<NS::Application*>(notification->object());
    app->setActivationPolicy(NS::ActivationPolicy::ActivationPolicyRegular);
}

void AppDelegate::applicationDidFinishLaunching(NS::Notification* notification)
{
    CGRect frame = (CGRect){ {100.0, 100.0}, {640.0, 480.0} };

    window.reset(NS::Window::alloc()->init(
        frame,
        NS::WindowStyleMaskClosable|NS::WindowStyleMaskTitled,
        NS::BackingStoreBuffered,
        false));

    device.reset(MTL::CreateSystemDefaultDevice());

    mtkView.reset(MTK::View::alloc()->init(frame, device.get()));
    mtkView->setColorPixelFormat(MTL::PixelFormat::PixelFormatBGRA8Unorm_sRGB);
    mtkView->setClearColor(MTL::ClearColor::Make(1.0, 1.0, 0.6, 1.0));

    viewDelegate = std::make_unique<ViewDelegate>(device.get());
    mtkView->setDelegate(viewDelegate.get());

    window->setContentView(mtkView.get());
    window->setTitle(NS::String::string("Window", NS::StringEncoding::UTF8StringEncoding));
    window->makeKeyAndOrderFront(nullptr);

    NS::Application* app = reinterpret_cast<NS::Application*>(notification->object());
    app->activateIgnoringOtherApps(true);
}

bool AppDelegate::applicationShouldTerminateAfterLastWindowClosed(NS::Application* sender)
{
    return true;
}
