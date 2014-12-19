//
//  Manga+Parse.m
//  Raftel
//
//  Created by  on 12/19/14.
//  Copyright (c) 2014 Raftel. All rights reserved.
//

#import "Manga+Parse.h"
#import "Comment.h"
#import <objc/runtime.h>

const void *parseObjectKey = &parseObjectKey;
const void *parseReadingCountKey = &parseReadingCountKey;
const void *parseCommentsCountKey = &parseCommentsCountKey;

@implementation Manga (Parse)

- (void)queryReadingCountWithCompletionBlock:(void (^)(int))completionBlock {
    
}

- (void)createMangaIfNeededWithCompletionBlock:(void (^)(PFObject *))completionBlock {
    NSString *className = NSStringFromClass(self.class);
    NSString *key = NSStringFromSelector(@selector(url));
    NSString *value = self.url.absoluteString;
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:key equalTo:value];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                [self setParseObject:[objects firstObject]];
                if (completionBlock) {
                    completionBlock([objects firstObject]);
                }
            } else {
                PFObject *object = [PFObject objectWithClassName:className];
                object[key] = value;
                object[readingCountKey] = @(0);
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"succeeded");
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                if (objects.count > 0) {
                                    [self setParseObject:[objects firstObject]];
                                    if (completionBlock) {
                                        completionBlock([objects firstObject]);
                                    }
                                } else {
                                    
                                }
                            }
                        }];
                        
                    }
                }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)incrementReadingCountWithCompletionBlock:(void (^)(int))completionBlock {
    __weak typeof (self) selfie = self;
    [self createMangaIfNeededWithCompletionBlock:^(PFObject *mangaPFObject) {
        [mangaPFObject incrementKey:readingCountKey];
        [mangaPFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [selfie refreshPFObjectWithCompletionBlock:^(PFObject *mangaPFObject) {
                [selfie setParseObject:mangaPFObject];
                [selfie setReadingCount:[mangaPFObject[readingCountKey] intValue]];
                if (completionBlock) {
                    completionBlock([mangaPFObject[readingCountKey] intValue]);
                }
            }];
        }];
    }];
}

- (void)refreshPFObjectWithCompletionBlock:(void (^)(PFObject *))completionBlock {
    PFObject *object = [self parseObject];
    if (object) {
        [object fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (completionBlock) {
                completionBlock(object);
            }
        }];
    }
}

- (void)fetchCommentsWithCompletionBlock:(void (^)(NSArray *))completionBlock {
    
}

- (void)addComment:(NSString *)comment completionBlock:(void (^)())completionBlock {
    
}

- (void)countCommentsWithCompletionBlock:(void (^)(int))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass([Comment class])];
    [query whereKey:NSStringFromSelector(@selector(mangaURL)) equalTo:self.url.absoluteString];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            [self setCommentsCount:count];
            if (completionBlock) {
                completionBlock(count);
            }
        } else {
            // The request failed
        }
    }];
}

- (void)setParseObject:(PFObject *)parseObject {
    [self setReadingCount:[parseObject[readingCountKey] intValue]];
    objc_setAssociatedObject(self, parseObjectKey, parseObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PFObject *)parseObject {
    return objc_getAssociatedObject(self, parseObjectKey);
}

- (void)setReadingCount:(int)readingCount {
    objc_setAssociatedObject(self, parseReadingCountKey, @(readingCount), OBJC_ASSOCIATION_ASSIGN);
}

- (int)readingCount {
    return [objc_getAssociatedObject(self, parseReadingCountKey) intValue];
}

- (void)setCommentsCount:(int)commentsCount {
    objc_setAssociatedObject(self, parseCommentsCountKey, @(commentsCount), OBJC_ASSOCIATION_ASSIGN);
}

- (int)commentsCount {
    return [objc_getAssociatedObject(self, parseCommentsCountKey) intValue];
}

@end