//
//  DragView.m
//  NibTransition
//
//  Created by YLCHUN on 2018/12/25.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "DragView.h"

NSPasteboardType NSPasteboardTypeXIB = @"xib";

@interface DragView()<NSDraggingDestination>
@end

@implementation DragView
{
    void(^_callback)(NSArray *contents);
    NSPasteboardType _pasteboardType;
    NSPasteboardType _pasteboardType_Ex;
    NSUInteger _count;
}

-(void)registerDrag {
    [self unregisterDraggedTypes];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:_pasteboardType, nil]];
}

-(void)dealloc {
    [self unregisterDraggedTypes];
}

-(void)draggingExited:(id<NSDraggingInfo>)sender {
    self.borderColor = [NSColor lightGrayColor];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = sender.draggingPasteboard;
    if (![pboard.types containsObject:_pasteboardType]) {
        return NSDragOperationNone;
    }
    NSArray *list = [pboard propertyListForType:_pasteboardType];
    if (_count > 0 && list.count > _count) {
        return NSDragOperationNone;
    }
    if (_pasteboardType_Ex) {
        for (NSString *str in list) {
            if (![str hasSuffix:_pasteboardType_Ex]) {
                return NSDragOperationNone;
            }
        }
    }
    
    self.borderColor = [NSColor blackColor];
    return NSDragOperationCopy;
}


-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    self.borderColor = [NSColor lightGrayColor];
    NSPasteboard *pboard = sender.draggingPasteboard;
    NSArray *list = [pboard propertyListForType:_pasteboardType];
    [self onDragged:list];
    return YES;
}

-(void)onDragged:(NSArray *)contents {
    !_callback?:_callback(contents);
}

-(void)setDraggedType:(NSPasteboardType)type count:(NSUInteger)count callback:(void(^)(NSArray *contents))callback {
    if (!callback) {
        return;
    }
    _count = count;
    if (type == NSPasteboardTypeXIB) {
        _pasteboardType = NSFilenamesPboardType;
        _pasteboardType_Ex = type;
    }else {
        _pasteboardType = type;
    }
    _callback = callback;
    [self registerDrag];
    
    self.boxType = NSBoxCustom;
    self.borderColor = [NSColor lightGrayColor];
    self.borderType = NSLineBorder;
    self.borderWidth = 1;
}

@end
