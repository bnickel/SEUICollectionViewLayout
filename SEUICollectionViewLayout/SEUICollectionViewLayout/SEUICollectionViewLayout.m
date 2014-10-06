//
//  SEUICollectionViewLayout.m
//  SEUICollectionViewLayout
//
//  Created by Brian Nickel on 10/6/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

//  Created by Brian Nickel on 8/4/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "SEUICollectionViewLayout.h"

@interface SEUICollectionViewLayout ()
@property (nonatomic, strong) NSMutableDictionary *itemAttributesByIndexPath;
@property (nonatomic, strong) NSMutableDictionary *supplementaryViewAtributesByTypeByIndexPath;
@property (nonatomic, strong) NSMutableDictionary *UUIDToIndexPathMap;
@property (nonatomic, strong) NSMutableDictionary *indexPathToUUIDMap;
@property (nonatomic, strong) NSMutableDictionary *UUIDToSectionMap;
@property (nonatomic, strong) NSMutableDictionary *sectionToUUIDMap;

@property (nonatomic, copy) NSDictionary *previousSupplementaryViewAtributesByTypeByIndexPath;
@property (nonatomic, copy) NSDictionary *previousUUIDToIndexPathMap;
@property (nonatomic, copy) NSDictionary *previousIndexPathToUUIDMap;
@property (nonatomic, copy) NSDictionary *previousUUIDToSectionMap;
@property (nonatomic, copy) NSDictionary *previousSectionToUUIDMap;

@property (nonatomic, strong) NSMutableDictionary *indexPathsToInsertForSupplementaryViewKinds;
@property (nonatomic, strong) NSMutableDictionary *indexPathsToDeleteForSupplementaryViewKinds;
@property (nonatomic, strong) NSMutableDictionary *initialLayoutAttributesForAppearingSupplementaryViewKinds;
@property (nonatomic, strong) NSMutableDictionary *finalLayoutAttributesForDisappearingSupplementaryViewKinds;
@property (nonatomic, assign) BOOL _mutating;
@property (nonatomic, assign) BOOL _changingBounds;
@end

@implementation SEUICollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initializeStorageVariables];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initializeStorageVariables];
    }
    return self;
}

- (void)_initializeStorageVariables
{
    _itemAttributesByIndexPath = [NSMutableDictionary dictionary];
    _supplementaryViewAtributesByTypeByIndexPath = [NSMutableDictionary dictionary];
    _indexPathsToDeleteForSupplementaryViewKinds = [NSMutableDictionary dictionary];
    _indexPathsToInsertForSupplementaryViewKinds = [NSMutableDictionary dictionary];
    _initialLayoutAttributesForAppearingSupplementaryViewKinds = [NSMutableDictionary dictionary];
    _finalLayoutAttributesForDisappearingSupplementaryViewKinds = [NSMutableDictionary dictionary];
    _UUIDToIndexPathMap = [NSMutableDictionary dictionary];
    _indexPathToUUIDMap = [NSMutableDictionary dictionary];
    _UUIDToSectionMap = [NSMutableDictionary dictionary];
    _sectionToUUIDMap = [NSMutableDictionary dictionary];
}

#pragma mark - Delegate wrappers

- (id<NSCopying>)_uniqueIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [(id<UICollectionViewDelegateSEUILayout>)self.collectionView.delegate collectionView:self.collectionView layout:self uniqueIdentifierForItemAtIndexPath:indexPath];
}

- (id<NSCopying>)_uniqueIdentifierForSection:(NSUInteger)section
{
    return [(id<UICollectionViewDelegateSEUILayout>)self.collectionView.delegate collectionView:self.collectionView layout:self uniqueIdentifierForSection:section];
}

#pragma mark - Mutation methods

- (void)beginPreparingLayout
{
    NSAssert(!self._mutating, @"Called %@ twice.", NSStringFromSelector(_cmd));
    self._mutating = YES;
    
    self.previousSupplementaryViewAtributesByTypeByIndexPath = [self.supplementaryViewAtributesByTypeByIndexPath copy];
    self.previousUUIDToIndexPathMap = [self.UUIDToIndexPathMap copy];
    self.previousIndexPathToUUIDMap = [self.indexPathToUUIDMap copy];
    self.previousUUIDToSectionMap = [self.UUIDToSectionMap copy];
    self.previousSectionToUUIDMap = [self.sectionToUUIDMap copy];
    
    [self.itemAttributesByIndexPath removeAllObjects];
    [self.supplementaryViewAtributesByTypeByIndexPath removeAllObjects];
    [self.UUIDToIndexPathMap removeAllObjects];
    [self.indexPathToUUIDMap removeAllObjects];
    [self.UUIDToSectionMap removeAllObjects];
    [self.sectionToUUIDMap removeAllObjects];
    
    if (self.collectionView.delegate == nil) {
        return;
    }
    
    NSInteger sectionCount = self.collectionView.numberOfSections;
    
    for (NSInteger section = 0; section < sectionCount; section ++) {
        id<NSCopying> sectionUUID = [self _uniqueIdentifierForSection:section];
        NSParameterAssert(sectionUUID != nil);
        self.sectionToUUIDMap[@(section)] = sectionUUID;
        self.UUIDToSectionMap[sectionUUID] = @(section);
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            id<NSCopying> itemUUID = [self _uniqueIdentifierForItemAtIndexPath:indexPath];
            NSParameterAssert(itemUUID != nil);
            self.indexPathToUUIDMap[indexPath] = itemUUID;
            self.UUIDToIndexPathMap[itemUUID] = indexPath;
        }
    }
}

- (void)endPreparingLayout
{
    NSAssert(self._mutating, @"Called %@ twice.", NSStringFromSelector(_cmd));
    self._mutating = NO;
}

- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self._mutating, @"%@ must be called between %@ and %@", NSStringFromSelector(_cmd), NSStringFromSelector(@selector(beginPreparingLayout)), NSStringFromSelector(@selector(endPreparingLayout)));
    self.itemAttributesByIndexPath[indexPath] = layoutAttributes;
}

- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self._mutating, @"%@ must be called between %@ and %@", NSStringFromSelector(_cmd), NSStringFromSelector(@selector(beginPreparingLayout)), NSStringFromSelector(@selector(endPreparingLayout)));
    NSMutableDictionary *indexPaths = self.supplementaryViewAtributesByTypeByIndexPath[kind] ?: (self.supplementaryViewAtributesByTypeByIndexPath[kind] = [NSMutableDictionary dictionary]);
    indexPaths[indexPath] = layoutAttributes;
}

- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self._mutating, @"%@ must be called between %@ and %@", NSStringFromSelector(_cmd), NSStringFromSelector(@selector(beginPreparingLayout)), NSStringFromSelector(@selector(endPreparingLayout)));
    NSMutableDictionary *indexPaths = self.supplementaryViewAtributesByTypeByIndexPath[kind] ?: (self.supplementaryViewAtributesByTypeByIndexPath[kind] = [NSMutableDictionary dictionary]);
    indexPaths[indexPath] = layoutAttributes;
}

#pragma mark - Getters

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemAttributesByIndexPath[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return self.supplementaryViewAtributesByTypeByIndexPath[kind][indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return self.supplementaryViewAtributesByTypeByIndexPath[kind][indexPath];
}


#pragma mark - Updates

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    for (NSString *viewType in self.itemTrackingSupplementaryAndDecorationViewKinds) {
        [self mapUpdatedItemsForViewKind:viewType sectionLevel:NO];
    }
    
    for (NSString *viewType in self.sectionTrackingSupplementaryAndDecorationViewKinds) {
        [self mapUpdatedItemsForViewKind:viewType sectionLevel:YES];
    }
}

- (void)mapUpdatedItemsForViewKind:(NSString *)viewType sectionLevel:(BOOL)sectionLevel
{
    NSMutableDictionary *initialLayoutAttributesForAppearingHeaders = [NSMutableDictionary dictionary];
    NSMutableDictionary *finalLayoutAttributesForDisappearingHeaders = [NSMutableDictionary dictionary];
    NSMutableSet *indexPathsToInsert = [NSMutableSet setWithArray:[self.supplementaryViewAtributesByTypeByIndexPath[viewType] allKeys]];
    NSMutableSet *indexPathsToDelete = [NSMutableSet setWithArray:[self.previousSupplementaryViewAtributesByTypeByIndexPath[viewType] allKeys]];
    
    for (NSIndexPath *initialIndexPath in self.previousSupplementaryViewAtributesByTypeByIndexPath[viewType]) {
        BOOL found = NO;
        NSUInteger parts[initialIndexPath.length];
        [initialIndexPath getIndexes:parts];
        
        if (sectionLevel) {
            id finalSectionNumber = self.UUIDToSectionMap[self.previousSectionToUUIDMap[@(initialIndexPath.section)]];
            if (finalSectionNumber) {
                found = YES;
                parts[0] = [finalSectionNumber unsignedIntegerValue];
            }
        } else {
            NSIndexPath *mappedIndexPath = self.UUIDToIndexPathMap[self.previousIndexPathToUUIDMap[initialIndexPath]];
            if (mappedIndexPath) {
                found = YES;
                parts[0] = mappedIndexPath.section;
                parts[1] = mappedIndexPath.item;
            }
        }
        
        if (found) {
            NSIndexPath *finalIndexPath = [NSIndexPath indexPathWithIndexes:parts length:initialIndexPath.length];
            
            if ([finalIndexPath isEqual:initialIndexPath]) {
                [indexPathsToInsert removeObject:finalIndexPath];
                [indexPathsToDelete removeObject:initialIndexPath];
            } else {
                initialLayoutAttributesForAppearingHeaders[finalIndexPath] = self.previousSupplementaryViewAtributesByTypeByIndexPath[viewType][initialIndexPath];
                finalLayoutAttributesForDisappearingHeaders[initialIndexPath] = self.supplementaryViewAtributesByTypeByIndexPath[viewType][finalIndexPath];
            }
        }
    }
    
    self.indexPathsToInsertForSupplementaryViewKinds[viewType] = [indexPathsToInsert allObjects];
    self.indexPathsToDeleteForSupplementaryViewKinds[viewType] = [indexPathsToDelete allObjects];
    self.initialLayoutAttributesForAppearingSupplementaryViewKinds[viewType] = initialLayoutAttributesForAppearingHeaders;
    self.finalLayoutAttributesForDisappearingSupplementaryViewKinds[viewType] = finalLayoutAttributesForDisappearingHeaders;
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    [self.indexPathsToInsertForSupplementaryViewKinds removeAllObjects];
    [self.indexPathsToDeleteForSupplementaryViewKinds removeAllObjects];
    [self.initialLayoutAttributesForAppearingSupplementaryViewKinds removeAllObjects];
    [self.finalLayoutAttributesForDisappearingSupplementaryViewKinds removeAllObjects];
}

- (NSArray *)indexPathsToInsertForSupplementaryViewOfKind:(NSString *)kind
{
    return self.indexPathsToInsertForSupplementaryViewKinds[kind];
}

- (NSArray *)indexPathsToDeleteForSupplementaryViewOfKind:(NSString *)kind
{
    return self.indexPathsToDeleteForSupplementaryViewKinds[kind];
}

- (NSArray *)indexPathsToInsertForDecorationViewOfKind:(NSString *)kind
{
    return [self indexPathsToInsertForSupplementaryViewOfKind:kind];
}

- (NSArray *)indexPathsToDeleteForDecorationViewOfKind:(NSString *)kind
{
    return [self indexPathsToDeleteForSupplementaryViewOfKind:kind];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (self._changingBounds) {
        if (self.animateBoundsChanges) {
            return [[self layoutAttributesForItemAtIndexPath:itemIndexPath] copy];
        }
    }
    
    return [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (self._changingBounds) {
        if (self.animateBoundsChanges) {
            UICollectionViewLayoutAttributes *attributes = [[self layoutAttributesForItemAtIndexPath:itemIndexPath] copy];
            attributes.hidden = YES;
            return attributes;
        }
    }
    
    return [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath originalSelector:(SEL)originalSelector
{
    if (self._changingBounds) {
        
        if (self.animateBoundsChanges) {
            return [[self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath] copy];
        }
        
        return ((id(*)(id,SEL,id,id))[UICollectionViewLayout instanceMethodForSelector:originalSelector])(self, originalSelector, elementKind, elementIndexPath);
    }
    
    UICollectionViewLayoutAttributes *attributes = [(self.initialLayoutAttributesForAppearingSupplementaryViewKinds[elementKind][elementIndexPath] ?: [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath]) copy];
    attributes.alpha = 0;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath originalSelector:(SEL)originalSelector
{
    if (self._changingBounds) {
        
        if (self.animateBoundsChanges) {
            UICollectionViewLayoutAttributes *attributes = [[self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath] copy];
            attributes.hidden = YES;
            return attributes;
        }
        
        return ((id(*)(id,SEL,id,id))[UICollectionViewLayout instanceMethodForSelector:originalSelector])(self, originalSelector, elementKind, elementIndexPath);
    }
    
    UICollectionViewLayoutAttributes *attributes = [(self.finalLayoutAttributesForDisappearingSupplementaryViewKinds[elementKind][elementIndexPath] ?: [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath]) copy];
    attributes.alpha = 0;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    return [self initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:decorationIndexPath originalSelector:_cmd];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    return [self finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:decorationIndexPath originalSelector:_cmd];
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    return [self initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:decorationIndexPath originalSelector:_cmd];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath
{
    return [self finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:decorationIndexPath originalSelector:_cmd];
}

#pragma mark - Size change

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
    self._changingBounds = YES;
    [super prepareForAnimatedBoundsChange:oldBounds];
}

- (void)finalizeAnimatedBoundsChange
{
    self._changingBounds = NO;
    [super finalizeAnimatedBoundsChange];
}

@end
