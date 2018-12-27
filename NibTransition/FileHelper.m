//
//  FileHelper.m
//  NibTransition
//
//  Created by YLCHUN on 2018/12/26.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "FileHelper.h"

static NSString *confPath() {
    static  NSString *confPath;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [NSBundle mainBundle].bundlePath;
        confPath = [bundlePath stringByAppendingPathComponent:@"conf"];
    });
    return confPath;
}

void setDefPath(NSString *path) {
    if (path.length > 0) {
        [[path dataUsingEncoding:NSUTF8StringEncoding] writeToFile:confPath() atomically:NO];
    }
}

NSString *getDefPath(void) {
    NSData *data = [NSData dataWithContentsOfFile:confPath()];
    NSString *path = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (data.length > 0) {
        NSFileManager *manager = NSFileManager.defaultManager;
        if ([manager isWritableFileAtPath:path]) {
            return path;
        }
    }
    NSFileManager *manager = NSFileManager.defaultManager;
    NSURL *desktop = [manager URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask].firstObject;
    return desktop.path;
}

NSString *getFileName(NSString *file) {
    return [file componentsSeparatedByString:@"/"].lastObject;
}

NSString *appendingFileName(NSString *prefix, NSString *fileName, NSString *suffix) {
    if (prefix.length > 0) {
        fileName = [prefix stringByAppendingString:fileName];
    }
    if (suffix.length > 0) {
        NSMutableArray<NSString *> *names = [[fileName componentsSeparatedByString:@"."] mutableCopy];
        if (names.count > 0) {
            names[0] = [names[0] stringByAppendingString:suffix];
        }
        fileName = [names componentsJoinedByString:@"."];
    }
    return fileName;
}

NSString *getFilePath(NSString *path, NSString *name) {
    return [path stringByAppendingPathComponent:name];
}
