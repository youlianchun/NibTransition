//
//  XMLNode.h
//  NibTransition
//
//  Created by YLCHUN on 2018/12/24.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMLNode : NSObject<NSCopying>
@property (nonatomic, readonly) XMLNode *superNode;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, readonly) NSArray<XMLNode *> *subNodes;


+(instancetype)nodeWithName:(nonnull NSString *)name attributes:(nonnull NSDictionary *)attributes;

- (void)setObject:(nullable NSString *)val forKeyedSubscript:(nonnull NSString *)key;
- (nullable NSString *)objectForKeyedSubscript:(nonnull NSString *)key;
- (void)setObject:(XMLNode *)node atIndexedSubscript:(NSUInteger)idx;
- (XMLNode *)objectAtIndexedSubscript:(NSUInteger)idx;

-(void)addSubNode:(XMLNode *)node;
-(void)addSubNodes:(NSArray<XMLNode *> *)nodes;
-(void)removeFromSuper;

-(NSString *)xmlString;

-(void)enumerateNodeWithNames:(nonnull NSArray<NSString *> *)names usingBlock:(void(^ _Nonnull)(NSUInteger idx, XMLNode *_Nonnull node, BOOL *_Nonnull stop))usingBlock;
-(NSArray<XMLNode *> *)filtrateSubNodes:(BOOL(^)(XMLNode *node))filtrate;

-(void)changeName:(nonnull NSString *)name;
-(void)changeAttributes:(nonnull NSDictionary *)attributes;

-(void)replaceAttributeVal:(nonnull NSString *)val to:(nonnull NSString *)nval;
@end

