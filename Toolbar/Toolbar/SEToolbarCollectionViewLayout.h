//
//  SEToolbarCollectionViewLayout.h
//  Toolbar
//
//  Created by Brian Nickel on 11/5/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <SEUICollectionViewLayout/SEUICollectionViewLayout.h>

extern NSString * const SEToolbarMoreItem;

@interface SEToolbarCollectionViewLayout : SEUICollectionViewLayout
@property (nonatomic, assign) NSInteger maxItemsToShowIfNotAllFit;
@property (nonatomic, assign) CGFloat minimumItemSpacing;
@property (nonatomic, readonly) NSInteger numberOfVisibleItems;
@end

@protocol UICollectionViewDelegateToolbarLayout <UICollectionViewDelegateSEUILayout>
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SEToolbarCollectionViewLayout *)collectionViewLayout widthForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)collectionView:(UICollectionView *)collectionView layoutWidthForMoreItem:(SEToolbarCollectionViewLayout *)collectionViewLayout;
@end