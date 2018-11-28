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
    var portraitColumnCount: Int = 2
    var landscapeColumnCount: Int = 4
    var verticalSeparatorWidth: CGFloat = 1
    var horizontalSeparatorHeight: CGFloat = 1

    var models: TrackableArray<HeightCalculableDataSource> = [] {
        didSet {
            handleModelChange()
        }
    }

    private let verticalSeparatorIdentifier: String = "verticalSeparator"
    private let horizontalSeparatorIdentifier: String = "horizontalSeparator"
    private let separatorZIndex: Int = -10

    private var columnCount: Int = 0
    private var cellWidth: CGFloat = 0
    private var cellHeights: [CGFloat] = [CGFloat]()
    private var rowHeights: [CGFloat] = [CGFloat]()
    private var previousOffsetRatio: CGFloat?
    private var needsCompleteCalculation: Bool = true

    private var cellCount: Int {
        return cellHeights.count
    }

    private var verticalSeparatorCount: Int {
        let fullRowSeparatorCount = cellCount / columnCount * (columnCount - 1)

        let lastRowRemainderCellsCount = cellCount % columnCount
        if lastRowRemainderCellsCount != 0 {
            let lastRowSeparatorCount = lastRowRemainderCellsCount - 1
            return fullRowSeparatorCount + lastRowSeparatorCount
        } else {
            return fullRowSeparatorCount
        }
    }

    private var horizontalSeparatorCount: Int {
        let excludingMultiLineLastRowCount = cellCount - columnCount
        if excludingMultiLineLastRowCount < 0 {
            return 0
        } else {
            return excludingMultiLineLastRowCount
        }
    }

    private var cellAndVerticalSeparatorWidth: CGFloat {
        return cellWidth + verticalSeparatorWidth
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
        let contentWidth = collectionView?.bounds.size.width ?? 0
        let contentHeight = horizontalSeparatorHeight * CGFloat(rowHeights.count - 1) + rowHeights.reduce(0) { lhs, rhs in
            return lhs + rhs
        }
        let contentSize = CGSize(width: contentWidth, height: contentHeight);
        return contentSize
    }

    override func prepare() {
        super.prepare()
        if needsCompleteCalculation {
            needsCompleteCalculation = false

            columnCount = calculateColumnCount()
            cellWidth = calculateCellWidth()
            cellHeights = calculateCellHeights()
            rowHeights = calculateRowHeights()
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
        let (cellIndexPaths, verticalSeparatorIndexPaths, horizontalSeparatorIndexPaths) = calculateSeparatorAndCellIndexPaths(in: rect)

        for cellIndexPath in cellIndexPaths {
            if let attributes = layoutAttributesForItem(at: cellIndexPath) {
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
        let totalWidth = collectionView?.bounds.size.width ?? 0.0
        let separatorCount = columnCount - 1

        let contentWidth = totalWidth - verticalSeparatorWidth * CGFloat(separatorCount)
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

    private func calculateRowHeights() -> [CGFloat] {
        var rowHeights = [CGFloat]()
        for i in stride(from: 0, to: cellCount, by: columnCount) {

            let leftmostCellIndex = i
            let rightmostCellIndex = i + columnCount - 1

            let height = getMaxHeight(leftmostCellIndex: leftmostCellIndex, tentativeRightmostCellIndex: rightmostCellIndex, cellHeights: cellHeights)
            rowHeights.append(height)
        }
        return rowHeights
    }

    private func calculateSeparatorAndCellIndexPaths(in rect: CGRect) -> ([IndexPath], [IndexPath], [IndexPath]) {
        let extraOffset: CGFloat = 1
        let rect = CGRect(x: rect.origin.x - extraOffset,
                          y: rect.origin.y - extraOffset,
                          width: rect.width + (extraOffset * 2),
                          height: rect.height + (extraOffset * 2))
        let rowCount = rowHeights.count
        let separatorAndCellRowCount = rowCount * 2
        let separatorAndCellColumnCount = columnCount * 2

        var cellIndexes = [Int]()
        var verticalSeparatorIndexes = [Int]()
        var horizontalSeparatorIndexes = [Int]()

        var cellRowIndex = 0
        var cellColumnIndex = 0
        var separatorRowIndex = 0
        var separatorColumnIndex = 0

        var minRowVerticalSeparatorOrBlankIndexes = [Int]()
        var minRowHorizontalSeparatorOrCellIndexes = [Int]()

        var loopXPosition: CGFloat = -extraOffset
        for columnIndex in 0..<separatorAndCellColumnCount {
            let isSeparatorColumnIndex = (columnIndex % 2 == 0)

            if isSeparatorColumnIndex {
                loopXPosition += verticalSeparatorWidth
                if rect.minX <= loopXPosition || rect.maxX <= loopXPosition {
                    minRowVerticalSeparatorOrBlankIndexes.append(separatorColumnIndex)
                }
                separatorColumnIndex += 1
            } else {
                loopXPosition += cellWidth
                if rect.minX <= loopXPosition || rect.maxX <= loopXPosition {
                    minRowHorizontalSeparatorOrCellIndexes.append(cellColumnIndex)
                }
                cellColumnIndex += 1
            }
            if rect.maxX <= loopXPosition {
                break
            }
        }

        var loopYPosition: CGFloat = -extraOffset
        for rowIndex in 0..<separatorAndCellRowCount {
            let isSeparatorRowIndex = (rowIndex % 2 == 0)
            if isSeparatorRowIndex {
                loopYPosition += horizontalSeparatorHeight
                if rect.minY <= loopYPosition || rect.maxY <= loopYPosition {
                    for i in minRowHorizontalSeparatorOrCellIndexes {
                        let cellIndex = separatorRowIndex * columnCount + i
                        if cellIndex < cellHeights.count {
                            horizontalSeparatorIndexes.append(cellIndex)
                        }
                    }
                }
                separatorRowIndex += 1
            } else {
                loopYPosition += rowHeights[cellRowIndex]
                if rect.minY <= loopYPosition || rect.maxY <= loopYPosition {
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
        let verticalSeparatorIndexPaths = verticalSeparatorIndexes.map(mapToIndexPath)
        let horizontalSeparatorIndexPaths = horizontalSeparatorIndexes.map(mapToIndexPath)
        return (cellIndexPaths, verticalSeparatorIndexPaths, horizontalSeparatorIndexPaths)
    }

    private func handleModelChange() {
        guard collectionView != nil else {
            needsCompleteCalculation = true
            return
        }
        switch models.latestChange {
        case .insert(let indexes):
            appendHeights(at: indexes)
        case .delete(let indexes):
            removeHeights(at: indexes)
        case .set:
            break
        }
    }

    private func appendHeights(at indexes: [Int])  {
        let newMinCellIndex = indexes.min() ?? 0
        let newMaxCellIndex = indexes.max() ?? 0

        for index in indexes {
            let height = measurementCell?.heightForWidth(width: cellWidth, model: models[index]) ?? 0
            cellHeights.insert(height, at: index)
        }

        let currentLastRowIndex = newMinCellIndex / columnCount
        let currentLastRowRemainderCellsCount = newMinCellIndex % columnCount

        var currentLastRowHeight: CGFloat = 0.0
        if currentLastRowIndex < rowHeights.count {
            currentLastRowHeight = rowHeights[currentLastRowIndex]
        }

        let newFirstRowLeftmostCellIndex = newMinCellIndex
        let newFirstRowRightmostCelIndex = newMinCellIndex + (columnCount - 1) - currentLastRowRemainderCellsCount

        let newFirstRowHeight = getMaxHeight(leftmostCellIndex: newFirstRowLeftmostCellIndex, tentativeRightmostCellIndex: newFirstRowRightmostCelIndex, cellHeights: cellHeights, extraComparisonHeight: currentLastRowHeight)

        var newSecondRowOnwardHeights = [CGFloat]()
        let newSecondRowLeftmostCellIndex = newFirstRowRightmostCelIndex + 1
        for i in stride(from: newSecondRowLeftmostCellIndex, to: newMaxCellIndex + 1, by: columnCount) {

            let leftmostCellIndex = i
            let rightmostCellIndex = (columnCount - 1) + i

            let height = getMaxHeight(leftmostCellIndex: leftmostCellIndex, tentativeRightmostCellIndex: rightmostCellIndex, cellHeights: cellHeights)
            newSecondRowOnwardHeights.append(height)
        }

        let heights = Array(rowHeights[0..<currentLastRowIndex]) + [newFirstRowHeight] + newSecondRowOnwardHeights
        rowHeights = heights
    }

    private func removeHeights(at indexes: [Int]) {
        for index in indexes {
            cellHeights.remove(at: index)
        }

        let newMinCellIndex = indexes.min() ?? 0
        let deletionTopmostRowIndex = newMinCellIndex / columnCount

        var recalculatedRowHeights = [CGFloat]()
        let deletionTopmostLeftmostCellIndex = deletionTopmostRowIndex * columnCount
        for i in stride(from: deletionTopmostLeftmostCellIndex, to: cellHeights.count, by: columnCount) {

            let leftmostCellIndex = i
            let rightmostCellIndex = (columnCount - 1) + i

            let height = getMaxHeight(leftmostCellIndex: leftmostCellIndex, tentativeRightmostCellIndex: rightmostCellIndex, cellHeights: cellHeights)
            recalculatedRowHeights.append(height)
        }
        let heights = Array(rowHeights[0..<deletionTopmostRowIndex]) + recalculatedRowHeights
        rowHeights = heights
    }

    private func getMaxHeight(leftmostCellIndex: Int, tentativeRightmostCellIndex: Int, cellHeights: [CGFloat], extraComparisonHeight: CGFloat = 0.0) -> CGFloat {

        var rightmostCellIndex = tentativeRightmostCellIndex
        let cellLastIndex = cellHeights.count - 1

        let cellExistsAtRightmostIndex = rightmostCellIndex <= cellLastIndex
        if !cellExistsAtRightmostIndex {
            rightmostCellIndex = cellLastIndex
        }
        let maxCellHeight = ([extraComparisonHeight] + cellHeights[leftmostCellIndex...rightmostCellIndex]).max() ?? 0
        return maxCellHeight
    }

    private func frameForCell(at indexPath: IndexPath) -> CGRect {
        let index = indexPath.row

        let columnIndexCGFloat = CGFloat(index).truncatingRemainder(dividingBy: CGFloat(columnCount))
        let x = columnIndexCGFloat * cellAndVerticalSeparatorWidth

        let rowIndex = index / columnCount
        if rowIndex >= rowHeights.count {
            return CGRect.zero
        }
        let y = horizontalSeparatorHeight * CGFloat(rowIndex) + rowHeights[0..<rowIndex].reduce(0) { lhs, rhs in
            return lhs + rhs
        }
        let cellHeight = rowHeights[rowIndex]

        let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
        return frame
    }

    private func frameForVerticalSeparator(at indexPath: IndexPath) -> CGRect {
        let cellFrame = frameForCell(at: indexPath)
        var xOrigin = cellFrame.origin.x - verticalSeparatorWidth
        if xOrigin < 0 {
            xOrigin = cellFrame.origin.x
        }
        let verticalSeparatorFrame = CGRect(x: xOrigin, y: cellFrame.origin.y, width: verticalSeparatorWidth, height: cellFrame.height)
        return verticalSeparatorFrame
    }

    private func frameForHorizontalSeparator(at indexPath: IndexPath) -> CGRect {
        let cellFrame = frameForCell(at: indexPath)
        var yOrigin = cellFrame.origin.y - horizontalSeparatorHeight
        if yOrigin < 0 {
            yOrigin = cellFrame.origin.y
        }
        let horizontalSeparatorFrame = CGRect(x: cellFrame.origin.x, y: yOrigin, width: cellWidth, height: horizontalSeparatorHeight)
        return horizontalSeparatorFrame
    }

}
