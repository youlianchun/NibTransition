//
//  XMLNode.m
//  NibTransition
//
//  Created by YLCHUN on 2018/12/24.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "XMLNode.h"

@implementation XMLNode
{
    __weak XMLNode *_superNode;
    NSMutableArray *_subNodes;
    NSMutableDictionary *_attributes;
}

@synthesize superNode = _superNode;
@synthesize name = _name;
@synthesize attributes = _attributes;
@synthesize subNodes = _subNodes;

+(instancetype)nodeWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    XMLNode *node = [self new];
    if (node) {
        node->_name = [name mutableCopy];
        node->_attributes = [attributes mutableCopy];
    }
    return node;
}

-(void)addSubNode:(XMLNode *)node {
    if (!node) return;
    if (!_subNodes) {
        _subNodes = [NSMutableArray array];
    }
    [node removeFromSuper];
    node->_superNode = self;
    [_subNodes addObject:node];
}

-(void)addSubNodes:(NSArray<XMLNode *> *)nodes {
    for (XMLNode *node in [nodes copy]) {
        [self addSubNode:node];
    }
}

-(void)removeFromSuper {
    if (_superNode) {
        [_superNode->_subNodes removeObject:self];
        _superNode = nil;
    }
}

- (void)setObject:(nullable NSString *)val forKeyedSubscript:(NSString *)key {
    _attributes[key] = val;
}

- (nullable NSString *)objectForKeyedSubscript:(NSString *)key {
    return _attributes[key];
}

- (void)setObject:(XMLNode *)node atIndexedSubscript:(NSUInteger)idx {
    if (!node) return;
    [_subNodes[idx] removeFromSuper];
    _subNodes[idx] = node;
    node->_superNode = self;
}

- (XMLNode *)objectAtIndexedSubscript:(NSUInteger)idx {
    return _subNodes[idx];
}

-(NSString *)attributesString {
    NSMutableArray *arr = [NSMutableArray array];
    [self.attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *attribute = [NSString stringWithFormat:@"%@=\"%@\"", key, obj];
        [arr addObject:attribute];
    }];
    if (arr.count > 0) {
        return [arr componentsJoinedByString:@" "];
    }
    return @"";
}

-(NSString *)xmlString {
    NSMutableString *mStr = [NSMutableString string];
    [mStr appendFormat:@"<%@ ", self.name];
    [mStr appendString:[self attributesString]];
    if (self.subNodes.count > 0) {
        [mStr appendString:@">\n"];
        for (XMLNode *node in self.subNodes) {
            [mStr appendFormat:@"%@\n", [node xmlString]];
        }
        [mStr appendFormat:@"</%@>", self.name];
    }else {
        [mStr appendString:@"/>"];
    }
    return [mStr copy];
}

-(void)enumerateNodeWithNames:(nonnull NSArray<NSString *> *)names usingBlock:(void(^ _Nonnull)(NSUInteger idx, XMLNode *_Nonnull node, BOOL *_Nonnull stop))usingBlock {
    if (names.count == 0 || !usingBlock) return;
    __block BOOL stop = NO;
    if ([names containsObject:_name]) {
        NSUInteger idx = [names indexOfObject:_name];
        usingBlock(idx, self, &stop);
        if (stop) return;
    }
    if (_subNodes.count > 0) {
        for (XMLNode *node in [_subNodes copy]) {
            [node enumerateNodeWithNames:names usingBlock:^(NSUInteger idx, XMLNode * _Nonnull node, BOOL * _Nonnull stopPtr) {
                usingBlock(idx, node, stopPtr);
                stop = *stopPtr;
            }];
            if (stop) break;
        }
    }
}

-(NSArray<XMLNode *> *)filtrateSubNodes:(BOOL(^)(XMLNode *node))filtrate {
    NSMutableArray *arr = [NSMutableArray array];
    for (XMLNode *node in [_subNodes copy]) {
        if (filtrate(node)) {
            [arr addObject:node];
        }
    }
    return [arr copy];
}

-(void)changeName:(NSString *)name {
    _name = name;
}

-(void)changeAttributes:(NSDictionary *)attributes {
    _attributes = [attributes mutableCopy];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    XMLNode *node = [XMLNode nodeWithName:self.name attributes:self.attributes];
    if (self.subNodes.count > 0) {
        for (XMLNode *tmp in self.subNodes) {
            [node addSubNode:[tmp mutableCopy]];
        }
    }
    return node;
}

-(void)replaceAttributeVal:(NSString *)val to:(NSString *)nval {
    if (self.subNodes.count > 0) {
        for (XMLNode *node in self.subNodes) {
            [node replaceAttributeVal:val to:nval];
        }
    }
    for (NSString *key in _attributes.allKeys) {
        if ([_attributes[key] isEqualToString:val]) {
            _attributes[key] = nval;
        }
    }
}

@end
