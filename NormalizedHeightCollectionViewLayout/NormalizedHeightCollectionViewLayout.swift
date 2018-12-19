//
//  NormalizedHeightCollectionViewLayout.swift
//  NormalizedHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/09/11.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

class NormalizedHeightCollectionViewLayout: UICollectionViewFlowLayout {

    var measurementCell: HeightCalculable?
    var portraitColumnCount: Int = 1
    var landscapeColumnCount: Int = 1
    var verticalSeparatorWidth: CGFloat = 0
    var horizontalSeparatorHeight: CGFloat = 0
    var footerHeight: CGFloat = 44.0

    // TODO: [COLLECTION_LAYOUT_EXPANSION] Refactor to make conditionals easier to maintain
    var prefersHorizontallyAttachedCells: Bool = false
    var prefersVerticallyOverlappingCells: Bool = false

    var verticalSeparatorIdentifier: String = "verticalSeparator"
    var horizontalSeparatorIdentifier: String = "horizontalSeparator"

    var models: [HeightCalculableDataSource] = []

    private var columnCount: Int = 0
    private var cellWidth: CGFloat = 0
    private var cellHeights: [CGFloat] = [CGFloat]()
    private var normalizedCellFrames: [CGRect] = [CGRect]()
    private var contentSize: CGSize = CGSize.zero
    private var previousOffsetRatio: CGFloat?
    private var needsCompleteCalculation: Bool = true

    private var rowCount: Int {
        let rowCount = ceil(CGFloat(cellHeights.count) / CGFloat(columnCount))
        return Int(rowCount)
    }

    private var separatorZIndex: Int {
        if prefersHorizontallyAttachedCells {
            return 10
        } else {
            return -10
        }
    }

    override init() {
        super.init()
        register(UINib(nibName: "PlainCollectionReusableView", bundle: nil), forDecorationViewOfKind: verticalSeparatorIdentifier)
        register(UINib(nibName: "PlainCollectionReusableView", bundle: nil), forDecorationViewOfKind: horizontalSeparatorIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register(UINib(nibName: "PlainCollectionReusableView", bundle: nil), forDecorationViewOfKind: verticalSeparatorIdentifier)
        register(UINib(nibName: "PlainCollectionReusableView", bundle: nil), forDecorationViewOfKind: horizontalSeparatorIdentifier)
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func prepare() {
        super.prepare()
        if needsCompleteCalculation {
            needsCompleteCalculation = false

            columnCount = calculateColumnCount()
            cellWidth = calculateCellWidth()
            cellHeights = calculateCellHeights()
            normalizedCellFrames = calculateNormalizedCellFrames()
            contentSize = calculateContentSize()
        }
    }

    override func prepareForTransition(from oldLayout: UICollectionViewLayout) {
        super.prepareForTransition(from: oldLayout)

        let oldCellWidth = cellWidth
        let newCellWidth = calculateCellWidth()
        let isCellWidthChanged = (newCellWidth != oldCellWidth)
        if isCellWidthChanged {
            needsCompleteCalculation = true
        }
        guard let collectionView = collectionView else {
            return
        }
        let topInset = collectionView.contentInset.top
        let topOffset = collectionView.contentOffset.y + topInset
        previousOffsetRatio = topOffset / oldLayout.collectionViewContentSize.height
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        invalidateLayout()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        let (cellIndexPaths, footerIndexPaths, verticalSeparatorIndexPaths, horizontalSeparatorIndexPaths) = calculateContentIndexPaths(in: rect)

        for cellIndexPath in cellIndexPaths {
            if let attributes = layoutAttributesForItem(at: cellIndexPath) {
                layoutAttributes.append(attributes)
            }
        }
        for footerIndexPath in footerIndexPaths {
            if let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: footerIndexPath) {
                layoutAttributes.append(attributes)
            }
        }
        for verticalSeparatorIndexPath in verticalSeparatorIndexPaths {
            if let attributes = layoutAttributesForDecorationView(ofKind: verticalSeparatorIdentifier, at: verticalSeparatorIndexPath) {
                layoutAttributes.append(attributes)
            }
        }
        for horizontalSeparatorIndexPath in horizontalSeparatorIndexPaths {
            if let attributes = layoutAttributesForDecorationView(ofKind: horizontalSeparatorIdentifier, at: horizontalSeparatorIndexPath) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = frameForCell(at: indexPath)
        return attributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        attributes.frame = frameForFooter(at: indexPath)
        return attributes
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        attributes.zIndex = separatorZIndex

        switch elementKind {
        case verticalSeparatorIdentifier:
            attributes.frame = frameForVerticalSeparator(at: indexPath)
            return attributes
        case horizontalSeparatorIdentifier:
            attributes.frame = frameForHorizontalSeparator(at: indexPath)
            return attributes
        default:
            return nil
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView?.bounds
        let isBoundsWidthChanged = (newBounds.width != oldBounds?.width)
        if isBoundsWidthChanged {
            needsCompleteCalculation = true
        }
        return isBoundsWidthChanged
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView,
            let offsetRatio = previousOffsetRatio else {
                return proposedContentOffset
        }
        previousOffsetRatio = nil
        let topInset = collectionView.contentInset.top
        let topOffset = (offsetRatio * collectionViewContentSize.height) - topInset

        let forecastedContentHeight = topOffset + collectionView.bounds.height
        if forecastedContentHeight > collectionViewContentSize.height {
            let maxTopOffet = collectionViewContentSize.height - collectionView.bounds.height
            return CGPoint(x: proposedContentOffset.x, y: maxTopOffet)

        } else {
            return CGPoint(x: proposedContentOffset.x, y: topOffset)
        }
    }

    func reloadHeights()  {
        needsCompleteCalculation = true
    }

    func insertHeights(at indexPaths: [IndexPath])  {
        guard collectionView != nil else {
            needsCompleteCalculation = true
            return
        }
        // TODO: [COLLECTION_LAYOUT_EXPANSION] Support multiple sections if needed
        let mapToIndex = { (indexPath: IndexPath) -> Int in
            return indexPath.item
        }
        let indexes = indexPaths.map(mapToIndex)

        for index in indexes {
            let height = measurementCell?.heightForWidth(width: cellWidth, model: models[index]) ?? 0
            cellHeights.insert(height, at: index)
        }

        let newMinCellIndex = indexes.min() ?? 0
        normalizedCellFrames = calculateNormalizedCellFrames(from: newMinCellIndex)
        contentSize = calculateContentSize()
    }

    func removeHeights(at indexPaths: [IndexPath]) {
        guard collectionView != nil else {
            needsCompleteCalculation = true
            return
        }
        // TODO: [COLLECTION_LAYOUT_EXPANSION] Support multiple sections if needed
        let mapToIndex = { (indexPath: IndexPath) -> Int in
            return indexPath.item
        }
        let indexes = indexPaths.map(mapToIndex)
        let sortedReversedIndexes = Array(indexes.sorted().reversed())

        for index in sortedReversedIndexes {
            cellHeights.remove(at: index)
        }
        let newMinCellIndex = indexes.min() ?? 0
        normalizedCellFrames = calculateNormalizedCellFrames(from: newMinCellIndex)
        contentSize = calculateContentSize()
    }

    private func calculateColumnCount() -> Int {
        let width = collectionView?.bounds.size.width ?? 0
        let height = collectionView?.bounds.size.height ?? 0
        if width < height {
            return portraitColumnCount
        } else {
            return landscapeColumnCount
        }
    }

    private func calculateCellWidth() -> CGFloat {
        let totalWidth = collectionView?.bounds.size.width ?? 0
        let separatorCount = columnCount - 1

        var contentWidth = totalWidth - verticalSeparatorWidth * CGFloat(separatorCount)
        if prefersHorizontallyAttachedCells {
            contentWidth = totalWidth
        }
        let width = contentWidth / CGFloat(columnCount)
        return width
    }

    private func calculateCellHeights() -> [CGFloat] {
        let cellHeights = models.map { model -> CGFloat in
            let height = measurementCell?.heightForWidth(width: cellWidth, model: model) ?? 0
            return height
        }
        return cellHeights
    }

    private func calculateNormalizedCellFrames() -> [CGRect] {
        let frames = calculateNormalizedCellFrames(from: 0)
        return frames
    }

    private func calculateContentSize() -> CGSize {
        let contentWidth = collectionView?.bounds.size.width ?? 0
        var totalRowHeight: CGFloat = 0
        for i in stride(from: 0, to: cellHeights.count, by: columnCount) {
            let rowHeight = normalizedCellFrames[i].height
            totalRowHeight += rowHeight
        }

        let totalSeparatorHeight = horizontalSeparatorHeight * CGFloat(rowCount - 1)
        var contentHeight = totalRowHeight + totalSeparatorHeight + footerHeight
        if prefersVerticallyOverlappingCells {
            contentHeight = totalRowHeight - totalSeparatorHeight + footerHeight
        }
        let contentSize = CGSize(width: contentWidth, height: contentHeight)
        return contentSize
    }

    private func calculateContentIndexPaths(in rect: CGRect) -> (cellIndexPaths: [IndexPath], footerIndexPaths: [IndexPath], verticalSeparatorIndexPaths: [IndexPath], horizontalSeparatorIndexPaths: [IndexPath]) {
        if rowCount == 0 {
            return ([], [], [], [])
        }

        let cellColumnCount = columnCount
        let separatorColumnCount = columnCount - 1
        let cellRowCount = rowCount
        let separatorRowCount = rowCount - 1
        let footerCount = 1

        let horizontalElementCount = cellColumnCount + separatorColumnCount
        let verticalElementCount = cellRowCount + separatorRowCount + footerCount

        var cellIndexes = [Int]()
        var verticalSeparatorIndexes = [Int]()
        var horizontalSeparatorIndexes = [Int]()
        var footerIndexes = [Int]()

        var cellRowIndex = 0
        var cellColumnIndex = 0
        var separatorRowIndex = 1 // intentionally skipping first index (because its frame is located outside of the collection view)
        var separatorColumnIndex = 1 // intentionally skipping first index (because its frame is located outside of the collection view)

        var minRowVerticalSeparatorOrBlankIndexes = [Int]()
        var minRowHorizontalSeparatorOrCellIndexes = [Int]()

        var loopXPosition: CGFloat = 0
        for columnIndex in 0..<horizontalElementCount {
            let isSeparatorColumnIndex = (columnIndex % 2 != 0)

            if isSeparatorColumnIndex {
                if prefersHorizontallyAttachedCells {
                    loopXPosition += verticalSeparatorWidth / 2
                } else {
                    loopXPosition += verticalSeparatorWidth
                }
                if rect.minX <= loopXPosition {
                    minRowVerticalSeparatorOrBlankIndexes.append(separatorColumnIndex)
                }
                separatorColumnIndex += 1
            } else {
                loopXPosition += cellWidth
                if rect.minX <= loopXPosition {
                    minRowHorizontalSeparatorOrCellIndexes.append(cellColumnIndex)
                }
                cellColumnIndex += 1
            }
            if rect.maxX <= loopXPosition {
                break
            }
        }

        var loopYPosition: CGFloat = 0
        for rowIndex in 0..<verticalElementCount {
            // TODO: [COLLECTION_LAYOUT_EXPANSION] Support multiple footers if needed
            let lastIndex = verticalElementCount - 1
            guard rowIndex != lastIndex else {
                loopYPosition += footerHeight
                if rect.minY <= loopYPosition {
                    footerIndexes.append(0)
                }
                break
            }

            let isSeparatorRowIndex = (rowIndex % 2 != 0)
            if isSeparatorRowIndex {
                if !prefersVerticallyOverlappingCells {
                    loopYPosition += horizontalSeparatorHeight
                }
                if rect.minY <= loopYPosition {
                    for i in minRowHorizontalSeparatorOrCellIndexes {
                        let cellIndex = separatorRowIndex * columnCount + i
                        if cellIndex < cellHeights.count {
                            horizontalSeparatorIndexes.append(cellIndex)
                        }
                    }
                }
                separatorRowIndex += 1
            } else {
                loopYPosition += normalizedCellFrames[cellRowIndex * columnCount].height
                if prefersVerticallyOverlappingCells {
                    loopYPosition -= horizontalSeparatorHeight
                }
                if rect.minY <= loopYPosition {
                    for i in minRowVerticalSeparatorOrBlankIndexes {
                        let cellIndex = cellRowIndex * columnCount + i
                        if cellIndex < cellHeights.count {
                            verticalSeparatorIndexes.append(cellIndex)
                        }
                    }
                    for i in minRowHorizontalSeparatorOrCellIndexes {
                        let cellIndex = cellRowIndex * columnCount + i
                        if cellIndex < cellHeights.count {
                            cellIndexes.append(cellIndex)
                        }
                    }
                }
                cellRowIndex += 1
            }
            if rect.maxY <= loopYPosition {
                break
            }
        }

        let mapToIndexPath = { (index: Int) -> IndexPath in
            return IndexPath(row: index, section: 0)
        }
        let cellIndexPaths = cellIndexes.map(mapToIndexPath)
        let footerIndexPaths = footerIndexes.map(mapToIndexPath)
        let verticalSeparatorIndexPaths = verticalSeparatorIndexes.map(mapToIndexPath)
        let horizontalSeparatorIndexPaths = horizontalSeparatorIndexes.map(mapToIndexPath)
        return (cellIndexPaths, footerIndexPaths, verticalSeparatorIndexPaths, horizontalSeparatorIndexPaths)
    }

    private func calculateNormalizedCellFrames(from cellIndex: Int) -> [CGRect] {
        let reloadTopmostRowIndex = cellIndex / columnCount
        let reloadTopmostLeftmostCellIndex = reloadTopmostRowIndex * columnCount

        var startingYOrigin: CGFloat = 0
        if normalizedCellFrames.count > 0 && reloadTopmostLeftmostCellIndex > 0 {
            let previousRowRightmostCell = normalizedCellFrames[reloadTopmostLeftmostCellIndex - 1]
            startingYOrigin = previousRowRightmostCell.origin.y + previousRowRightmostCell.height
        }
        var newFrames = [CGRect]()
        var loopHeight: CGFloat = startingYOrigin

        for leftmostCellIndex in stride(from: reloadTopmostLeftmostCellIndex, to: cellHeights.count, by: columnCount) {

            let rightmostCellIndex = leftmostCellIndex + columnCount - 1
            let maxHeight = calculateMaxHeight(leftmostCellIndex: leftmostCellIndex, tentativeRightmostCellIndex: rightmostCellIndex, cellHeights: cellHeights)

            for cellIndex in leftmostCellIndex..<(leftmostCellIndex + columnCount) {
                if cellIndex >= cellHeights.count {
                    break
                }
                let columnIndexCGFloat = CGFloat(cellIndex).truncatingRemainder(dividingBy: CGFloat(columnCount))
                let cellAndVerticalSeparatorWidth = cellWidth + verticalSeparatorWidth
                var x = columnIndexCGFloat * cellAndVerticalSeparatorWidth
                if prefersHorizontallyAttachedCells {
                    x = columnIndexCGFloat * cellWidth
                }

                let rowIndex = cellIndex / columnCount
                let totalCellHeightBeforeThisIndex = loopHeight
                let totalSeparatorHeightBeforeThisIndex = horizontalSeparatorHeight * CGFloat(rowIndex)
                var y = totalCellHeightBeforeThisIndex + totalSeparatorHeightBeforeThisIndex
                if prefersVerticallyOverlappingCells {
                    y = totalCellHeightBeforeThisIndex - totalSeparatorHeightBeforeThisIndex - horizontalSeparatorHeight
                }
                let cellHeight = maxHeight

                let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                newFrames.append(frame)
            }
            loopHeight += maxHeight
        }
        let recalculatedFrames = Array(normalizedCellFrames[0..<reloadTopmostLeftmostCellIndex]) + newFrames
        return recalculatedFrames
    }

    private func calculateMaxHeight(leftmostCellIndex: Int, tentativeRightmostCellIndex: Int, cellHeights: [CGFloat]) -> CGFloat {
        var rightmostCellIndex = tentativeRightmostCellIndex
        let cellLastIndex = cellHeights.count - 1

        let cellExistsAtRightmostIndex = rightmostCellIndex <= cellLastIndex
        if !cellExistsAtRightmostIndex {
            rightmostCellIndex = cellLastIndex
        }
        let maxCellHeight = (cellHeights[leftmostCellIndex...rightmostCellIndex]).max() ?? 0
        return maxCellHeight
    }

    private func frameForCell(at indexPath: IndexPath) -> CGRect {
        if indexPath.item >= normalizedCellFrames.count {
            return CGRect.zero
        }
        return normalizedCellFrames[indexPath.item]
    }

    private func frameForFooter(at indexPath: IndexPath) -> CGRect {
        let totalSize = collectionViewContentSize
        let footerFrame = CGRect(x: 0, y: totalSize.height - footerHeight, width: totalSize.width, height: footerHeight)
        return footerFrame
    }

    private func frameForVerticalSeparator(at indexPath: IndexPath) -> CGRect {
        let cellFrame = frameForCell(at: indexPath)
        var x = cellFrame.origin.x - verticalSeparatorWidth
        if prefersHorizontallyAttachedCells {
            x = cellFrame.origin.x - (verticalSeparatorWidth / 2)
        }
        let verticalSeparatorFrame = CGRect(x: x, y: cellFrame.origin.y, width: verticalSeparatorWidth, height: cellFrame.height)
        return verticalSeparatorFrame
    }

    private func frameForHorizontalSeparator(at indexPath: IndexPath) -> CGRect {
        let cellFrame = frameForCell(at: indexPath)
        var y = cellFrame.origin.y - horizontalSeparatorHeight
        if prefersVerticallyOverlappingCells {
            y = cellFrame.origin.y
        }
        let horizontalSeparatorFrame = CGRect(x: cellFrame.origin.x, y: y, width: cellWidth, height: horizontalSeparatorHeight)
        return horizontalSeparatorFrame
    }

}
