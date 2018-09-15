# DynamicHeightCollectionViewLayout

Smooth scrolling solution to UICollectionView with varying height cells. When the cells in a row have different heights, the height of the shorter cells will be adjusted to the height of the tallest cell.

This approach uses manual mathematical calculations (without any call to `systemLayoutSizeFittingSize:`) to allow calculations from background thread if necessary.

The use of auto layout outlet collection in the Interface Builder makes it possible to achieve this system -- there is no need to write separate constants (or magic numbers), which greatly reduces maintenance cost. Calculated heights are cached wherever appropriate to minimize redundant calculations.

## Features

<img src="demo.gif" width="375" height="667" style="background-color: #f4f4f4;">

* Layout switching
* Append (single or multiple) new data with animation
* Remove (single or multiple) existing data with animation
* Customizable column count for portrait and/or landscape mode
* Customizable separator size

## Requirement

Any Xcode that can compile Swift 4.1.

## Installation

Drag the 'DynamicHeightCollectionViewLayout' folder into your project.

## Usage
(Please see demo project under 'Demo' for more details)

* Create an instance of `DynamicHeightCollectionViewLayout` and specify the type of cell that you want to use for measurement
```
lazy var gridLayout: DynamicHeightCollectionViewLayout<GridCollectionViewCell> = {
    let layout = DynamicHeightCollectionViewLayout<GridCollectionViewCell>()
    layout.measurementCell = gridMeasurementCell // gridMeasurementCell is subclass of UICollectionViewCell initialized from nib
    ...
```

* (OPTIONAL) Customize the number of column and size of separator according to your requirement. Specifying separator size of 0 will hide them entirely)
```
    ...
    layout.portraitColumnCount = 2
    layout.landscapeColumnCount = 4
    layout.verticalSeparatorWidth = 1
    layout.horizontalSeparatorHeight = 0
    return layout
}()
```

* Assign a specific model to your `DynamicHeightCollectionViewLayout` instance, which will become the data source of the height calculation in the next point
```
var models: ChangeTracerArray<T> = ChangeTracerArray() { // replace 'T' with your Type here
        didSet {
            gridLayout.models = models
        }
    }
...
```

* Conform your `UICollectionViewCell` subclass to `HeightCalculable`, and implement the corresponding method to manually calculate the height of the cell given a specific width

## Limitations

The following limitations may be addressed in the future if necessary:
* The layout class can only process one kind of cell
* The cell models have to be stored in `ChangeTracerArray` instead of the standard `Collection` type
