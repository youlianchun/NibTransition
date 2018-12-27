//
//  XMLParser.h
//  NibTransition
//
//  Created by YLCHUN on 2018/12/24.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLNode.h"

@interface XMLParser : NSObject
@end

@interface NSXMLParser (XMLNode);
+(void)parseWithData:(nonnull NSData *)data completion:(void(^ _Nonnull)(NSArray<XMLNode *> *xml, NSError *err))completion;
@end
