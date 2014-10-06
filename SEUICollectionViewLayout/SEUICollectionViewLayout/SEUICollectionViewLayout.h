//
//  SEUICollectionViewLayout.h
//  SEUICollectionViewLayout
//
//  Created by Brian Nickel on 8/4/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEUICollectionViewLayout : UICollectionViewLayout

@property (nonatomic, copy) NSArray *sectionTrackingSupplementaryAndDecorationViewKinds;
@property (nonatomic, copy) NSArray *itemTrackingSupplementaryAndDecorationViewKinds;
@property (nonatomic, assign) BOOL animateBoundsChanges;

- (void)beginPreparingLayout;
- (void)endPreparingLayout;

- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol UICollectionViewDelegateSEUILayout <UICollectionViewDelegate>

- (id<NSCopying>)collectionView:(UICollectionView *)collectionView layout:(SEUICollectionViewLayout *)collectionViewLayout uniqueIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;
- (id<NSCopying>)collectionView:(UICollectionView *)collectionView layout:(SEUICollectionViewLayout *)collectionViewLayout uniqueIdentifierForSection:(NSUInteger)section;

@end