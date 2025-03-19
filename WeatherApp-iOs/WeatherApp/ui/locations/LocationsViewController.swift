import UIKit
import SwiftUI
import Foundation
import Domain

final class LocationsViewController: UIViewController {
    
    private let buttonAdd = ButtonAdd()
    
    private let locationsViewModel = LocationsViewModel(getCoordByGeoUseCase: GetCoordByGeoUseCase())
        
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .baseBackground
        collectionView.register(LocationCollectionViewCell.self, forCellWithReuseIdentifier: LocationCollectionViewCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

private extension LocationsViewController {
    
    func setupView() {

        locationsViewModel.loadLocations()
        
        view.backgroundColor = .baseBackground
        
        addSubViews()
        setActions()
        setupConstraints()
    }
}

private extension LocationsViewController {
    
    func addSubViews() {
        self.collectionView.allowsMultipleSelection = false
        
        setupLongGestureRecognizerOnCollection()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(buttonAdd)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
    }
}

private extension LocationsViewController {
    
    func setActions() {
        self.buttonAdd.onClick = {
            let textFieldWindow = TextFieldAlert { text in
                if let text = text {
                    self.getLocation(city: text)
                }
            }
            self.present(textFieldWindow, animated: true, completion: nil)
        }
    }
    
    
    @objc private func onLocationLongPress(gestureRecogizer: UILongPressGestureRecognizer) {
        if (gestureRecogizer.state != .began) {
            return
        }
        let press = gestureRecogizer.location(in: collectionView)
        let deleteAlert = DeleteAlert(
            onPositiveClick: {
                if let indextPath = self.collectionView.indexPathForItem(at: press) {
                    self.locationsViewModel.deleteLocation(at: indextPath.item)
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: [indextPath])
                    }, completion: nil)
                }
            },
            onNegativeClick: nil
        )
        self.present(deleteAlert, animated: true, completion: nil)
    }
                                                              
    func getLocation(city: String) {
        if (!city.trimmingCharacters(in: .whitespaces).isEmpty) {
            Task {
                try await locationsViewModel.addLocation(city: city)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

private extension LocationsViewController {
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            buttonAdd.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            buttonAdd.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100)
        ])
    }
}

extension LocationsViewController: UIGestureRecognizerDelegate {
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLocationLongPress(gestureRecogizer: )))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressedGesture)
    }
}

extension LocationsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationsViewModel.getLocations().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCollectionViewCell.identifier, for: indexPath) as? LocationCollectionViewCell else { fatalError("Error LocationCollectionViewCell") }
        
        let item = locationsViewModel.getLocations()[indexPath.row]
        cell.configure(with: item.convertToLocationItemView())
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 164, height: 154)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let uiEdgeInsets = centerItemsInCollectionView(cellWidth: 164, numberOfItems: 2, spaceBetweenCell: 16, collectionView: collectionView)
        return uiEdgeInsets
    }
}
