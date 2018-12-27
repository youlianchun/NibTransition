//
//  DragView.h
//  NibTransition
//
//  Created by YLCHUN on 2018/12/25.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

APPKIT_EXTERN NSPasteboardType NSPasteboardTypeXIB;

@interface DragView : NSBox
-(void)setDraggedType:(NSPasteboardType)type count:(NSUInteger)count callback:(void(^)(NSArray *contents))callback;
@end

NS_ASSUME_NONNULL_END
