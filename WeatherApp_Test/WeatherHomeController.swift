//
//  ViewController.swift
//  WeatherApp_Test
//
//  Created by SMBA on 16/09/2020.
//  Copyright © 2020 SMBA. All rights reserved.
//


import UIKit
import PureLayout
import SideMenu
import CoreLocation

class WeatherHomeController: UIViewController, CLLocationManagerDelegate {
    
    lazy var rightBarButton: UIBarButtonItem = {
        let imageButton = UIImage(named: "search")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: imageButton, style: .done, target: self, action:#selector(handleSearchTapped))
        return button
    }()
    
    lazy var leftBarButton: UIBarButtonItem = {
        let imageButton = UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: imageButton, style: .done, target: self, action:#selector(handleMenuOpened))
        return button
    }()
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .purple
        return view
    }()
    let savedPlaceLabel: UILabel = {
        let label = UILabel()
        label.text = "Kein Ort gespeichert"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let favoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "Bitte fügen Sie mindestens einen Ort zu Ihren Favoriten hinzu."
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution  = .fillEqually
        return stackView
    }()
    
    let searchButton:  UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ort/PLZ suchen", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.backgroundColor = UIColor.purple
        button.setTitleColor(.white, for: .normal)
        let buttonImage = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = .white
        button.setImage(buttonImage, for: .normal)
        return button
    }()
    lazy var locationButton:  UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Aktueller Standort", for: .normal)
        button.layer.borderColor = UIColor.purple.cgColor
        button.setTitleColor(.purple, for: .normal)
        button.addTarget(self, action: #selector(handleRequestLocation), for: .touchUpInside)
        button.layer.borderWidth = 1
        return button
    }()
    let wetterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "Wetter"
        return label
    }()
    
    var sideNavigationController: SideMenuNavigationController?
    var  locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        locationManager = CLLocationManager()
        
}
        
fileprivate func setupViews() {
    self.view.backgroundColor = .white
    navigationItem.titleView = wetterLabel
    navigationItem.rightBarButtonItem = rightBarButton
    navigationItem.leftBarButtonItem = leftBarButton
    guard let navController = navigationController?.navigationBar else { return }
    navController.addSubview(separatorView)
    separatorView.autoPinEdge(.trailing, to: .trailing, of: navController)
    separatorView.autoPinEdge(.leading, to: .leading, of: navController)
    separatorView.autoPinEdge(.bottom, to: .bottom, of: navController)
    separatorView.autoSetDimension(.height, toSize: 1.4)
    
    view.addSubview(savedPlaceLabel)
    savedPlaceLabel.autoAlignAxis(.vertical, toSameAxisOf: self.view)
    savedPlaceLabel.autoAlignAxis(.horizontal, toSameAxisOf: self.view, withOffset: -250.0)
    savedPlaceLabel.autoSetDimension(.height, toSize: 50)
    
    view.addSubview(favoritesLabel)
    favoritesLabel.autoPinEdge(.top, to: .bottom, of: savedPlaceLabel, withOffset: 20)
    favoritesLabel.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 40)
    favoritesLabel.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -40)
    favoritesLabel.autoSetDimension(.height, toSize: 50)
    
    view.addSubview(stackView)
    stackView.insertArrangedSubview(searchButton, at: 0)
    stackView.insertArrangedSubview(locationButton, at: 1)
    stackView.autoPinEdge(.top, to: .bottom, of: favoritesLabel, withOffset: 40)
    stackView.autoPinEdge(.leading, to: .leading, of: savedPlaceLabel)
    stackView.autoPinEdge(.trailing, to: .trailing, of: savedPlaceLabel)
    stackView.autoSetDimension(.height, toSize: 90)
}

@objc func handleSearchTapped() {
    sideMenuSetup(withBool: false)
    guard let sideMenuNavigationController = sideNavigationController else { return }
    self.present(sideMenuNavigationController, animated: true, completion: nil)
}
@objc func handleMenuOpened() {
    sideMenuSetup(withBool: true)
    guard let sideMenuNavigationController = sideNavigationController else { return }
    self.present(sideMenuNavigationController, animated: true, completion: nil)
}
    
func sideMenuSetup(withBool:Bool) {
    let sideMenuVc = UIViewController()
    let side = UIViewController()
    sideMenuVc.view.backgroundColor = UIColor.black
    side.view.backgroundColor = UIColor.red
    sideNavigationController = .init(rootViewController: sideMenuVc)
    sideNavigationController?.leftSide = withBool;
    sideNavigationController?.menuWidth = self.view.bounds.width * 0.9
    SideMenuManager.default.addPanGestureToPresent(toView: view)
    SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)
    SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left)
    SideMenuManager.default.leftMenuNavigationController = sideNavigationController
    SideMenuManager.default.rightMenuNavigationController = sideNavigationController
}
@objc func handleRequestLocation() {
    guard let locationManager = self.locationManager else { return }
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .denied:
        self.showAlertWhenLocationDenied()
    default:
        ()
    }
}
func showAlertWhenLocationDenied() {
    let alertViewController = UIAlertController(title: "Ortung deaktiviert.", message: "Um Ihren Standort ermitteln zu können, muss die GPS-Funktion aktiv sein.\n Um GPS zu aktivieren, öffnen Sie bitte Einstellungen > Datenschutz > Ortungsdienste.", preferredStyle: .alert)
    alertViewController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    self.present(alertViewController, animated: true, completion: nil)
}
}





