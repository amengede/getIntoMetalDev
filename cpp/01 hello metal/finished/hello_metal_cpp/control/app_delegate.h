//
//  app_delegate.h
//  metal_test
//
//  Created by Andrew Mengede on 13/9/2023.
//
#pragma once

#include <memory>

#include "../config.h"
#include "../release.h"
#include "view_delegate.h"

class AppDelegate : public NS::ApplicationDelegate
{
    public:
        virtual void applicationWillFinishLaunching(NS::Notification* notification) override;
        virtual void applicationDidFinishLaunching(NS::Notification* notification) override;
        virtual bool applicationShouldTerminateAfterLastWindowClosed(NS::Application* sender) override;

    private:
        release_ptr<NS::Window> window;
        release_ptr<MTK::View> mtkView;
        release_ptr<MTL::Device> device;
        std::unique_ptr<ViewDelegate> viewDelegate;
};
