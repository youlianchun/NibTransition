//
//  XMLParser.m
//  NibTransition
//
//  Created by YLCHUN on 2018/12/24.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "XMLParser.h"


@interface XMLParser() <NSXMLParserDelegate>
@end

@implementation XMLParser
{
    XMLNode *_begin;
    __weak XMLNode *_last;
    
    void(^_completion)(NSArray<XMLNode *> *xml, NSError *err);
}

-(instancetype)initWithCompletion:(void(^)(NSArray<XMLNode *> *xml, NSError *err))completion {
    self = [super init];
    if (self) {
        _completion = completion;
    }
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _begin = [XMLNode nodeWithName:@"root" attributes:@{}];
    _last = _begin;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
    
    XMLNode *node = [XMLNode nodeWithName:elementName attributes:attributeDict];
    [_last addSubNode:node];
    _last = node;
}

//-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
//    NSLog(@"%@", string);
//}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _last = _last.superNode;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    !_completion?:_completion([_begin.subNodes copy], nil);
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    !_completion?:_completion(nil, parseError);
}

@end


@implementation NSXMLParser(XMLNode)

+(void)parseWithData:(nonnull NSData *)data completion:(void(^ _Nonnull)(NSArray<XMLNode *> *xml, NSError *err))completion {
    __block XMLParser *xp = [[XMLParser alloc] initWithCompletion:^(NSArray<XMLNode *> *xml, NSError *err) {
        completion(xml, err);
        xp = nil;
    }];
    NSXMLParser *parser = [[self alloc] initWithData:data];
    parser.delegate = xp;
    if (![parser parse]) {
        xp = nil;
    }
}

@end
