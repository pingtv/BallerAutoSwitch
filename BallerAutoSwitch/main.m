//
//  main.m
//  BallerAutoSwitch
//
//  Created by Ping Chen on 12/14/17.
//  Copyright © 2017 Ping Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BallerAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        //        signal(SIGPIPE, (void*)(int)SO_NOSIGPIPE); //dont break on sigpipe
        signal(SIGPIPE, SIG_IGN);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([BallerAppDelegate class]));
    }
}
