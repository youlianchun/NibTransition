//
//  FileHelper.h
//  NibTransition
//
//  Created by YLCHUN on 2018/12/26.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import <Cocoa/Cocoa.h>

APPKIT_EXTERN void setDefPath(NSString *path);
APPKIT_EXTERN NSString *getDefPath(void);
APPKIT_EXTERN NSString *getFileName(NSString *file);
APPKIT_EXTERN NSString *appendingFileName(NSString *prefix, NSString *fileName, NSString *suffix);
APPKIT_EXTERN NSString *getFilePath(NSString *path, NSString *name);
