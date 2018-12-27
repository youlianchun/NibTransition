//
//  NibTransition.m
//  NibTransition
//
//  Created by YLCHUN on 2018/12/24.
//  Copyright © 2018 YLCHUN. All rights reserved.
//

#import "NibTransition.h"
#import "XMLParser.h"
#import "XMLNode.h"

static NSArray<XMLNode *> *loadViewsFromXib(XMLNode *xib) {
    if (!xib) return nil;
    
    XMLNode *objects = [xib filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"objects"];
    }].firstObject;
    
    NSArray<XMLNode *> *views = [objects filtrateSubNodes:^BOOL(XMLNode *node) {
        return ![node.name isEqualToString:@"placeholder"];
    }];
    return views;
}


static void t2c(XMLNode *cell) {
    XMLNode *contentView = [cell filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"tableViewCellContentView"];
    }].firstObject;
    
    XMLNode *constraints = [contentView filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"constraints"];
    }].firstObject;
    
    NSDictionary *attributes;
    
    NSString *cellId = cell[@"id"];
    NSString *viewId = contentView[@"id"];
    [cell replaceAttributeVal:viewId to:cellId];
    
    [cell changeName:@"collectionViewCell"];
    attributes = @{@"opaque":@"NO",
                   @"clipsSubviews":@"YES",
                   @"multipleTouchEnabled":@"YES",
                   @"contentMode":@"center",
                   @"id":cellId,
                   @"customClass":@"UICollectionViewCell"};
    [cell changeAttributes:attributes];
    
    [contentView changeName:@"view"];
    attributes = @{@"key":@"contentView",
                   @"opaque":@"NO",
                   @"clipsSubviews":@"YES",
                   @"multipleTouchEnabled":@"YES",
                   @"contentMode":@"center"};
    [contentView changeAttributes:attributes];
    
    if (constraints) {
        [cell addSubNode:constraints];
    }
}

void c2t(XMLNode *cell) {
    XMLNode *contentView = [cell filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"view"];
    }].firstObject;
    
    XMLNode *constraints = [cell filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"constraints"];
    }].firstObject;
    
    NSDictionary *attributes;
    
    NSString *cellId = cell[@"id"];
    NSString *viewId = [NSString stringWithFormat:@"%@-v", cellId];
    [cell replaceAttributeVal:cellId to:viewId];
    
    [cell changeName:@"tableViewCell"];
    attributes = @{@"contentMode":@"scaleToFill",
                   @"selectionStyle":@"default",
                   @"indentationWidth":@"10",
                   @"id":cellId,
                   @"customClass":@"UITableViewCell"};
    [cell changeAttributes:attributes];
    
    
    [contentView changeName:@"tableViewCellContentView"];
    attributes = @{@"key":@"contentView",
                   @"opaque":@"NO",
                   @"clipsSubviews":@"YES",
                   @"multipleTouchEnabled":@"YES",
                   @"contentMode":@"center",
                   @"tableViewCell":cellId,
                   @"id":viewId
                   };
    
    [contentView changeAttributes:attributes];
    
    if (constraints) {
        [contentView addSubNode:constraints];
    }
    
}

static void t2v(XMLNode *cell) {
    XMLNode *contentView = [cell filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"tableViewCellContentView"];
    }].firstObject;
    
    XMLNode *constraints = [contentView filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"constraints"];
    }].firstObject;
    
    NSArray<XMLNode *> *nodes = [cell filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"viewLayoutGuide"] || [node.name isEqualToString:@"point"];
    }];
    
    NSString *cellId = cell[@"id"];
    NSString *viewId = contentView[@"id"];
    [cell replaceAttributeVal:cellId to:viewId];
    
    [contentView changeName:@"view"];
    NSDictionary *attributes = @{@"contentMode":@"scaleToFill",
                                 @"id":viewId};
    [contentView changeAttributes:attributes];
    [cell.superNode addSubNode:contentView];
    
    [cell removeFromSuper];

    [contentView addSubNode:constraints];
    
    XMLNode *freeformSimulatedSizeMetrics = [XMLNode nodeWithName:@"freeformSimulatedSizeMetrics" attributes:@{@"key":@"simulatedDestinationMetrics"}];
    
    [contentView addSubNode:freeformSimulatedSizeMetrics];
    [contentView addSubNodes:nodes];
}

static void c2v(XMLNode *cell) {
    XMLNode *contentView = [cell filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"view"];
    }].firstObject;
    
    NSArray<XMLNode *> *nodes = [cell filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"constraints"] || [node.name isEqualToString:@"viewLayoutGuide"] || [node.name isEqualToString:@"point"];
    }];

    NSString *cellId = cell[@"id"];
    
    [contentView changeName:@"view"];
    NSDictionary *attributes = @{@"contentMode":@"scaleToFill",
                                 @"id":cellId};
    [contentView changeAttributes:attributes];
    [cell.superNode addSubNode:contentView];
    
    [cell removeFromSuper];
    
    XMLNode *freeformSimulatedSizeMetrics = [XMLNode nodeWithName:@"freeformSimulatedSizeMetrics" attributes:@{@"key":@"simulatedDestinationMetrics"}];
    [contentView addSubNode:freeformSimulatedSizeMetrics];
    
    [contentView addSubNodes:nodes];
}

static void v2t(XMLNode *view) {
    XMLNode *point = [view filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"point"];
    }].firstObject;
    
    XMLNode *freeformSimulatedSizeMetrics = [view filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"freeformSimulatedSizeMetrics"];
    }].firstObject;
    [freeformSimulatedSizeMetrics removeFromSuper];
    
    XMLNode *rect = [[view filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"rect"];
    }].firstObject mutableCopy];
    
    NSDictionary *attributes;
    NSString *viewId = view[@"id"];
    NSString *cellId = [NSString stringWithFormat:@"%@-cell", viewId];
    
    attributes = @{@"contentMode":@"scaleToFill",
                   @"selectionStyle":@"default",
                   @"indentationWidth":@"10",
                   @"id":cellId,
                   @"customClass":@"UITableViewCell"};
    XMLNode *cell = [XMLNode nodeWithName:@"tableViewCell" attributes:attributes];
    [cell addSubNode:rect];
    
    [view.superNode addSubNode:cell];
    [cell addSubNode:view];
    [cell addSubNode:point];
    
    [view changeName:@"tableViewCellContentView"];
    
    attributes = @{@"key":@"contentView",
                   @"opaque":@"NO",
                   @"clipsSubviews":@"YES",
                   @"multipleTouchEnabled":@"YES",
                   @"contentMode":@"center",
                   @"tableViewCell":cellId,
                   @"id":viewId
                   };
    [view changeAttributes:attributes];
    
}

static void v2c(XMLNode *view) {
    
    XMLNode *subviews = [view filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"subviews"];
    }].firstObject;
    
    XMLNode *freeformSimulatedSizeMetrics = [view filtrateSubNodes:^BOOL(XMLNode *node) {
        return [node.name isEqualToString:@"freeformSimulatedSizeMetrics"];
    }].firstObject;
    [freeformSimulatedSizeMetrics removeFromSuper];
    
    NSDictionary *attributes;
    NSString *viewId = view[@"id"];
    
    [view changeName:@"collectionViewCell"];
    attributes = @{@"opaque":@"NO",
                   @"clipsSubviews":@"YES",
                   @"multipleTouchEnabled":@"YES",
                   @"contentMode":@"center",
                   @"id":viewId,
                   @"customClass":@"UICollectionViewCell"};
    [view changeAttributes:attributes];
    
    attributes = @{@"key":@"contentView",
                   @"opaque":@"NO",
                   @"clipsSubviews":@"YES",
                   @"multipleTouchEnabled":@"YES",
                   @"contentMode":@"center"};
    XMLNode *contentView = [XMLNode nodeWithName:@"view" attributes:attributes];
    [view addSubNode:contentView];
    
    [contentView addSubNode:subviews];
}

static XMLNode *nibTransition(XMLNode *nib, NibTransitionType toType) {
    XMLNode *xib = [nib mutableCopy];
    NSArray<XMLNode *> *views = loadViewsFromXib(xib);
    for (XMLNode *view in views) {
        if ([view.name isEqualToString:@"tableViewCell"]) {
            switch (toType) {
                case NibTransitionType_t:
                    break;
                case NibTransitionType_c:
                    t2c(view);
                    break;
                case NibTransitionType_v:
                    t2v(view);
                    break;
                default:
                    break;
            }
        }
        else if ([view.name isEqualToString:@"collectionViewCell"]) {
            switch (toType) {
                case NibTransitionType_t:
                    c2t(view);
                    break;
                case NibTransitionType_c:
                    break;
                case NibTransitionType_v:
                    c2v(view);
                    break;
                default:
                    break;
            }
        }
        else if ([view.name isEqualToString:@"view"]) {
            switch (toType) {
                case NibTransitionType_t:
                    v2t(view);
                    break;
                case NibTransitionType_c:
                    v2c(view);
                    break;
                case NibTransitionType_v:
                    break;
                default:
                    break;
            }
        }
    }
    return xib;
}


void xibTransition(NSData *xib, NibTransitionType toType, void(^callback)(NSData *xib)) {
    if (!callback) return;
    [NSXMLParser parseWithData:xib completion:^(NSArray<XMLNode *> *xml, NSError *err) {
        XMLNode *xib = xml.firstObject;
        XMLNode *nib = nibTransition(xib, toType);
        static NSString *info = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
        NSString *nibStr = [NSString stringWithFormat:@"%@\n%@", info, [nib xmlString]];
        NSData *data = [nibStr dataUsingEncoding:NSUTF8StringEncoding];
        callback(data);
    }];
}

