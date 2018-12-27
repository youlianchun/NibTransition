//
//  NibTransition.h
//  NibTransition
//
//  Created by YLCHUN on 2018/12/24.
//  Copyright © 2018 YLCHUN. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum NibTransitionType {
    NibTransitionType_u,
    NibTransitionType_c,
    NibTransitionType_t,
    NibTransitionType_v,
} NibTransitionType;

APPKIT_EXTERN void xibTransition(NSData *xib, NibTransitionType toType, void(^callback)(NSData *xib));
NS_ASSUME_NONNULL_END
