//
//  SEToolbarCollectionViewLayout.m
//  Toolbar
//
//  Created by Brian Nickel on 11/5/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "SEToolbarCollectionViewLayout.h"

NSString * const SEToolbarMoreItem = @"SEToolbarMoreItem";

@interface SEToolbarCollectionViewLayout ()
@property (nonatomic, strong, readonly) NSMutableArray *visibleAttributes;
@end

@implementation SEToolbarCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    _maxItemsToShowIfNotAllFit = NSIntegerMax;
    _minimumItemSpacing = 10;
    _visibleAttributes = [NSMutableArray array];
    self.animateBoundsChanges = NO;
}

#pragma mark - Setters

- (void)setMaxItemsToShowIfNotAllFit:(NSInteger)maxItemsToShowIfNotAllFit
{
    if (_maxItemsToShowIfNotAllFit != maxItemsToShowIfNotAllFit) {
        _maxItemsToShowIfNotAllFit = maxItemsToShowIfNotAllFit;
        [self invalidateLayout];
    }
}

- (void)setMinimumItemSpacing:(CGFloat)minimumItemSpacing
{
    if (_minimumItemSpacing != minimumItemSpacing) {
        _minimumItemSpacing = minimumItemSpacing;
        [self invalidateLayout];
    }
}

#pragma mark - Delegate wrappers

- (CGFloat)widthForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [(id)self.collectionView.delegate collectionView:self.collectionView layout:self widthForItemAtIndexPath:indexPath];
}

- (CGFloat)widthForMoreItem
{
    return [(id)self.collectionView.delegate collectionView:self.collectionView layoutWidthForMoreItem:self];
}

#pragma mark - UICollectionViewLayout methods

- (void)arrangeAttributes:(NSArray *)attributes widths:(CGFloat[])widths contentSize:(CGSize)contentSize
{
    CGFloat spacing = contentSize.width;
    if (attributes.count > 0) {
        for (NSInteger i = 0; i < attributes.count; i ++) {
            spacing -= widths[i];
        }
        spacing /= (attributes.count - 1);
    } else {
        spacing = 0;
    }
    
    CGFloat offset = 0;
    for (NSInteger i = 0; i < attributes.count; i ++) {
        [attributes[i] setFrame:CGRectMake(round(offset), 0, widths[i], contentSize.height)];
        offset += widths[i] + spacing;
    }
}

- (void)prepareLayout
{
    NSAssert(self.collectionView.numberOfSections <= 1, @"This layout only works with one section.");
    
    [self beginPreparingLayout];
    
    [self.visibleAttributes removeAllObjects];
    
    if (self.collectionView.numberOfSections == 0) {
        _numberOfVisibleItems = 0;
        [self endPreparingLayout];
        return;
    }
    
    const CGSize contentSize = self.collectionView.bounds.size;
    const NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    CGFloat widths[itemCount];
    CGFloat totalWidth = 0;
    
    for (NSInteger item = 0; item < itemCount && totalWidth <= contentSize.width; item ++) {
        
        const CGFloat width = [self widthForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
        
        widths[item] = width;
        
        if (item != 0) {
            totalWidth += self.minimumItemSpacing;
        }
        
        totalWidth += width;
    }
    
    if (totalWidth <= contentSize.width) {
        
        for (NSInteger item = 0; item < itemCount; item ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            [self setLayoutAttributes:attributes forItemAtIndexPath:indexPath];
            [self.visibleAttributes addObject:attributes];
        }
        
        _numberOfVisibleItems = self.visibleAttributes.count;
        
    } else {
        
        const CGFloat moreItemWidth = [self widthForMoreItem];
        totalWidth = moreItemWidth;
        
        NSInteger item;
        for (item = 0; item < itemCount && totalWidth + widths[item] + self.minimumItemSpacing < contentSize.width && item < self.maxItemsToShowIfNotAllFit; item ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            [self setLayoutAttributes:attributes forItemAtIndexPath:indexPath];
            [self.visibleAttributes addObject:attributes];
            totalWidth += self.minimumItemSpacing + widths[item];
        }
        
        widths[item] = moreItemWidth;
        
        NSIndexPath *moreIndexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:0];
        UICollectionViewLayoutAttributes *moreAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SEToolbarMoreItem withIndexPath:moreIndexPath];
        [self setLayoutAttributes:moreAttributes forSupplementaryViewOfKind:SEToolbarMoreItem atIndexPath:moreIndexPath];
        [self.visibleAttributes addObject:moreAttributes];
        
        _numberOfVisibleItems = self.visibleAttributes.count - 1;
    }
    
    [self arrangeAttributes:self.visibleAttributes widths:widths contentSize:contentSize];
    [self endPreparingLayout];
}

- (CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.visibleAttributes copy];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return !CGRectEqualToRect(newBounds, self.collectionView.bounds);
}

@end
