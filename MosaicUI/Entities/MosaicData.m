//
//  MosaicModule.m
//  MosaicUI
//
//  Created by Ezequiel Becerra on 10/21/12.
//  Copyright (c) 2012 betzerra. All rights reserved.
//

#import "MosaicData.h"

@implementation MosaicData
@synthesize imageFilename, title, size;

-(id)initWithDictionary:(NSDictionary *)aDict{
    self = [self init];
    if (self){
        self.imageFilename = [aDict objectForKey:@"imageFilename"];
        self.size = [[aDict objectForKey:@"size"] integerValue];
        self.title = [aDict objectForKey:@"title"];
    }
    return self;
}

-(NSString *)description{
    NSString *retVal = [NSString stringWithFormat:@"%@ %@", [super description], self.title];
    return retVal;
}

- (BOOL)isEqual:(id)anObject {
    if (![anObject isKindOfClass:[MosaicData class]]) return NO;
    MosaicData *otherObject = (MosaicData *)anObject;
    return [self.title isEqual:otherObject.title] && [self.imageFilename isEqual:otherObject.imageFilename];
}

- (NSUInteger)hash {
    return [[self description] hash];
}

@end
