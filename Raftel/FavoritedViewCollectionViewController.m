//
//  FavoritedViewCollectionViewController.m
//  Raftel
//
//  Created by  on 12/8/14.
//  Copyright (c) 2014 Raftel. All rights reserved.
//

#import "FavoritedViewCollectionViewController.h"
#import "SearchResultCell.h"
#import "DBManager.h"
#import "Manga.h"
#import <UIImageView+WebCache.h>

static CGFloat const cellSpacing = 10;

static int const column = 3;

static NSString *const favoriteCellIdentifier = @"searchResult";

@interface FavoritedViewCollectionViewController ()

@property (nonatomic, strong) YapDatabaseConnection *readConnection;
@property (nonatomic, strong) YapDatabaseViewMappings *databaseViewMappings;

@end

@implementation FavoritedViewCollectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Collections", nil);
    
    self.readConnection = [[[DBManager sharedManager] database] newConnection];
    
    self.readConnection.objectCacheLimit = 500; // increase object cache size
    self.readConnection.metadataCacheEnabled = NO; // not using metadata on this connection
    
    self.databaseViewMappings = [[YapDatabaseViewMappings alloc] initWithGroups:@[@""] view:kUserFavoriteView];
    
    [self.readConnection beginLongLivedReadTransaction];
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        [self.databaseViewMappings updateWithTransaction:transaction];
    }];
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SearchResultCell class]) bundle:nil] forCellWithReuseIdentifier:favoriteCellIdentifier];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.databaseViewMappings numberOfSections];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.databaseViewMappings numberOfItemsInSection:section];
}

#pragma mark <UICollectionViewDelegate>

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = (SearchResultCell *)[collectionView dequeueReusableCellWithReuseIdentifier:favoriteCellIdentifier forIndexPath:indexPath];
    
    __block Manga *manga;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        manga = [[transaction ext:kUserFavoriteView] objectAtIndexPath:indexPath withMappings:self.databaseViewMappings];
    }];
    [cell.imageView sd_setImageWithURL:manga.coverURL];
    [cell.searchName setText:manga.name];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floorf((CGRectGetWidth(self.collectionView.frame)-(column+1)*cellSpacing)/column);
    return CGSizeMake(width, 200);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return cellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return cellSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(cellSpacing, cellSpacing, cellSpacing, cellSpacing);
}

@end
