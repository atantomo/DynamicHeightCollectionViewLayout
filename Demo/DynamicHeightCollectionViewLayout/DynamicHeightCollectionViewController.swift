//
//  DynamicHeightCollectionViewController.swift
//  DynamicHeightCollectionViewLayout
//
//  Created by Andrew Tantomo on 2018/09/11.
//  Copyright © 2018 Andrew Tantomo. All rights reserved.
//

import UIKit

class DynamicHeightCollectionViewController: UIViewController {

    @IBOutlet var bottomButtonContainer: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toggleButton: RoundedButton!
    @IBOutlet var deleteButton: RoundedButton!

    @IBOutlet var toggleButtonWidthConstraint: NSLayoutConstraint!

    private var models: ChangeTracerArray<HeightCalculableDataSource> = ChangeTracerArray() {
        didSet {
            gridLayout.models = models
            listLayout.models = models
        }
    }

    private lazy var gridLayout: DynamicHeightCollectionViewLayout = {
        let layout = DynamicHeightCollectionViewLayout()
        layout.measurementCell = gridMeasurementCell
        layout.portraitColumnCount = 2
        layout.landscapeColumnCount = 4
        layout.verticalSeparatorWidth = 1
        layout.horizontalSeparatorHeight = 0
        return layout
    }()

    private lazy var listLayout: DynamicHeightCollectionViewLayout = {
        let layout = DynamicHeightCollectionViewLayout()
        layout.measurementCell = listMeasurementCell
        layout.portraitColumnCount = 1
        layout.landscapeColumnCount = 2
        layout.verticalSeparatorWidth = 1
        layout.horizontalSeparatorHeight = 1
        return layout
    }()

    private lazy var gridMeasurementCell: GridCollectionViewCell = {
        let nib = UINib(nibName: "GridCollectionViewCell", bundle: nil)
        guard let cell = nib.instantiate(withOwner: self, options: nil).first as? GridCollectionViewCell else {
            fatalError()
        }
        return cell
    }()

    private lazy var listMeasurementCell: ListCollectionViewCell = {
        let nib = UINib(nibName: "ListCollectionViewCell", bundle: nil)
        guard let cell = nib.instantiate(withOwner: self, options: nil).first as? ListCollectionViewCell else {
            fatalError()
        }
        return cell
    }()

    private lazy var identifier: String = {
        return gridCellIdentifier
    }()

    private let gridCellIdentifier: String = "gridCell"
    private let listCellIdentifier: String = "listCell"

    private var isReadyForTransition: Bool = true

    override func viewDidLoad() {
        models = ChangeTracerArray(SampleEntity.models)

        setupCollectionView()
        setupButtons()
        setupShadow()

        NotificationCenter.default.addObserver(self, selector: #selector(deleteCell(sender:)), name: Resources.NotificationName.deleteCell, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCell(sender:)), name: Resources.NotificationName.updateCell, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Resources.NotificationName.deleteCell, object: nil)
        NotificationCenter.default.removeObserver(self, name: Resources.NotificationName.updateCell, object: nil)
    }

    @IBAction func toggleLayoutButtonTapped(_ sender: UIButton) {
        guard isReadyForTransition else {
            return
        }
        isReadyForTransition = false

        let image: UIImage
        let nextIdentifier: String
        let nextLayout: DynamicHeightCollectionViewLayout

        let isCurrentlyDisplayingGrid = (collectionView.collectionViewLayout == gridLayout)
        if isCurrentlyDisplayingGrid {
            image = Resources.Image.grid
            nextIdentifier = listCellIdentifier
            nextLayout = listLayout
        } else {
            image = Resources.Image.list
            nextIdentifier = gridCellIdentifier
            nextLayout = gridLayout
        }

        toggleButton.setImage(image, for: UIControlState.normal)
        identifier = nextIdentifier
        UIView.performWithoutAnimation { [weak self] in
            self?.collectionView.reloadSections(IndexSet(integer: 0))
        }
        collectionView.setCollectionViewLayout(nextLayout, animated: true) { [weak self] _ in
            self?.isReadyForTransition = true
            self?.syncDeleteButton()
        }
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let newModels = SampleEntity.models
        models.append(contentsOf: newModels)

        guard case let .insert(indexes) = models.latestChange else {
            return
        }
        let indexPaths = indexes.map { index in
            return IndexPath(item: index, section: 0)
        }
        collectionView.insertItems(at: indexPaths)
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let indexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        let indexes = indexPaths.map { indexPath in
            return indexPath.item
        }
        models.remove(at: indexes)
        collectionView.deleteItems(at: indexPaths)

        deleteButton.isEnabled = false
    }

    @objc
    func deleteCell(sender: Notification) {
        guard let button = sender.object as? UIButton,
            let position = button.superview?.convert(button.center, to: collectionView),
            let indexPath = collectionView.indexPathForItem(at: position) else {
                return
        }
        models.remove(at: [indexPath.item])
        collectionView.deleteItems(at: [indexPath])
    }

    @objc
    func updateCell(sender: Notification) {
        guard let button = sender.object as? UIButton,
            let position = button.superview?.convert(button.center, to: collectionView),
            let indexPath = collectionView.indexPathForItem(at: position) else {
                return
        }
        models.update(at: indexPath.item, element: SampleEntity.updatedModel)
        collectionView.reloadItems(at: [indexPath])
    }

    private func setupCollectionView() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 52, right: 0)
        collectionView.allowsMultipleSelection = true

        collectionView.register(UINib(nibName: "GridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: gridCellIdentifier)
        collectionView.register(UINib(nibName: "ListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: listCellIdentifier)

        collectionView.setCollectionViewLayout(gridLayout, animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupButtons() {
        let halfRadius = toggleButtonWidthConstraint.constant / 2
        toggleButton.configureCornerRadius(radius: halfRadius)
        deleteButton.isEnabled = false
    }

    private func setupShadow() {
        let configure = { (view: UIView) -> Void in
            view.layer.masksToBounds = false
            view.layer.shadowRadius = 2.0
            view.layer.shadowColor = UIColor.lightGray.cgColor
            view.layer.shadowOffset = CGSize(width: 2, height: 2)
            view.layer.shadowOpacity = 0.3
        }
        configure(collectionView)
        configure(bottomButtonContainer)
    }

    private func syncDeleteButton() {
        guard let selectedCount = collectionView.indexPathsForSelectedItems?.count else {
            deleteButton.isEnabled = false
            return
        }
        let hasSelectedItems = (selectedCount > 0)
        deleteButton.isEnabled = hasSelectedItems
    }

}

extension DynamicHeightCollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let cell = dequeuedCell as? GridCollectionViewCell,
            let model = models[indexPath.item] as? CellModel {
            cell.topLabel.text = model.topText
            cell.leftLabel.text = model.leftText
            cell.rightLabel.text = model.rightText

            return cell
        }
        if let cell = dequeuedCell as? ListCollectionViewCell,
            let model = models[indexPath.item] as? CellModel {
            cell.topLabel.text = model.topText
            cell.leftLabel.text = model.leftText
            cell.rightLabel.text = model.rightText

            return cell
        }
        return dequeuedCell
    }

}

extension DynamicHeightCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        syncDeleteButton()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        syncDeleteButton()
    }

}

