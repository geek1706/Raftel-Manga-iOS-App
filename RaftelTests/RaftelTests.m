//
//  RaftelTests.m
//  RaftelTests
//
//  Created by  on 12/6/14.
//  Copyright (c) 2014 Raftel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Manga.h"
#import "Mangapanda.h"
#import "MangaGenre.h"
#import "MangaChapter.h"
#import "MangaPage.h"
#import "MangaSearchResult.h"

@interface RaftelTests : XCTestCase

@end

@implementation RaftelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseOnePiece {
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.mangapanda.com/103/one-piece.html"]];
    XCTAssertNotNil(urlData);
    NSString *urlContentString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    
    Mangapanda *panda = [[Mangapanda alloc] init];
    
    Manga *mangaObject = [panda mangaWithContentURLString:urlContentString];
    XCTAssertNotNil(mangaObject);
    XCTAssertEqualObjects(mangaObject.name, @"One Piece");
    XCTAssertEqualObjects(mangaObject.source, @"mangapanda");
    XCTAssertEqualObjects(mangaObject.alternateName, @"One Piece");
    XCTAssertEqualObjects(mangaObject.year, @"1997");
    XCTAssertTrue(mangaObject.ongoing.boolValue);
    XCTAssertEqualObjects(mangaObject.author, @"Oda, Eiichiro");
    XCTAssertEqualObjects(mangaObject.artist, @"Oda, Eiichiro");
    XCTAssertEqualObjects(mangaObject.synopsis, @"Seeking to be the greatest pirate in the world, young Monkey D. Luffy, endowed with stretching powers from the legendary &amp;quot;Gomu Gomu&amp;quot; Devil's fruit, travels towards the Grand Line in search of One Piece, the greatest treasure in the world.");
    XCTAssertNotNil(mangaObject.coverURL);
    //XCTAssertEqual((int)mangaObject.chapters.count, 769);
    XCTAssertGreaterThan((int)mangaObject.chapters.count, 767);
    XCTAssertEqual((int)mangaObject.genre.count, 6);
    
    MangaGenre *action = [mangaObject.genre firstObject];
    XCTAssertEqualObjects(action.name, @"Action");
    XCTAssertEqualObjects(action.URL.absoluteString, @"http://www.mangapanda.com/popular/action");
    
    MangaChapter *chapter1 = [mangaObject.chapters firstObject];
    XCTAssertNotNil(chapter1);
    NSData *chapterData = [NSData dataWithContentsOfURL:chapter1.url];
    XCTAssertNotNil(chapterData);
    NSString *chapterContentString = [[NSString alloc] initWithData:chapterData encoding:NSUTF8StringEncoding];
    NSArray *pages = [chapter1 pagesWithContentURLString:chapterContentString];
    XCTAssertNotNil(pages);
    XCTAssertEqual((int)pages.count, 54);
    MangaPage *page1 = [pages firstObject];
    NSData *page1Data = [NSData dataWithContentsOfURL:page1.url];
    XCTAssertNotNil(page1Data);
    NSString *page1ContentString = [[NSString alloc] initWithData:page1Data encoding:NSUTF8StringEncoding];
    NSURL *page1ImageURL = [page1 imageURLWithContentURLString:page1ContentString];
    XCTAssertNotNil(page1);
    XCTAssertEqualObjects(page1.url.absoluteString, @"http://www.mangapanda.com/103-2039-1/one-piece/chapter-1.html");
    XCTAssertEqualObjects(page1ImageURL.absoluteString, @"http://i38.mangapanda.com/one-piece/1/one-piece-1668160.jpg");
}

- (void)testParseJunjou {    
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.mangapanda.com/junjou-drop"]];
    XCTAssertNotNil(urlData);
    
    NSString *urlContentString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    
    Mangapanda *panda = [[Mangapanda alloc] init];
    Manga *mangaObject = [panda mangaWithContentURLString:urlContentString];
    XCTAssertNotNil(mangaObject);
    XCTAssertEqualObjects(mangaObject.name, @"Junjou Drop");
    XCTAssertEqualObjects(mangaObject.source, @"mangapanda");
    XCTAssertEqualObjects(mangaObject.alternateName, @"Romantic Drop");
    XCTAssertEqualObjects(mangaObject.year, @"2011");
    XCTAssertFalse(mangaObject.ongoing.boolValue);
    XCTAssertEqualObjects(mangaObject.author, @"NAKAHARA Aya");
    XCTAssertEqualObjects(mangaObject.artist, @"NAKAHARA Aya");
    XCTAssertEqualObjects(mangaObject.synopsis, @"Recently rejected Saki Momota is having a hard time getting over her first love. While picking up her younger brother from school, Saki bumps into Akai Ryuuichi; the class delinquent whos rumored to be able to shoot lazer-beams from his eyes. Could this day get any worse?");
    XCTAssertNotNil(mangaObject.coverURL);
    XCTAssertEqual((int)mangaObject.chapters.count, 4);
    XCTAssertEqual((int)mangaObject.genre.count, 3);
    
    MangaGenre *action = [mangaObject.genre firstObject];
    XCTAssertEqualObjects(action.name, @"Comedy");
    XCTAssertEqualObjects(action.URL.absoluteString, @"http://www.mangapanda.com/popular/comedy");
}

- (void)testSearch {
    NSURL *searchURL = [Mangapanda searchURLForKeyword:@"One Piece"];
    XCTAssertNotNil(searchURL);
    
    NSData *urlData = [NSData dataWithContentsOfURL:searchURL];
    XCTAssertNotNil(urlData);
    
    NSString *urlContentString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    
    Mangapanda *panda = [[Mangapanda alloc] init];
    NSArray *searches = [panda searchItemsWithContentURLString:urlContentString];
    XCTAssertNotNil(searches);
    XCTAssertEqual((int)searches.count, 3);
    
    MangaSearchResult *firstResult = [searches firstObject];
    XCTAssertEqualObjects(firstResult.name, @"One Piece");
    XCTAssertEqualObjects(firstResult.url.absoluteString, @"http://www.mangapanda.com/103/one-piece.html");
    XCTAssertNotNil(firstResult.imageURL);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}


@end
