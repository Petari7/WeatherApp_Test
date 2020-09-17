//
//  CitiesSearchTableTableViewController.swift
//  WeatherApp_Test
//
//  Created by SMBA on 16/09/2020.
//  Copyright © 2020 SMBA. All rights reserved.
//

import UIKit
import MapKit

class CitiesSearchTableTableViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    var  searchController: UISearchController? = nil
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        mapView = MKMapView()
        self.tableView.tableFooterView = UIView()
        searchController = UISearchController(searchResultsController:  nil)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.becomeFirstResponder()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.titleView = searchController?.searchBar
        searchController?.searchBar.placeholder = "Ort/PLZ"
        self.definesPresentationContext = true
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
    return self.searchController?.searchBar.text?.isEmpty == true ? 0 : self.matchingItems.count
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cellId")
        tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
       
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.country
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedItem = matchingItems[indexPath.row].placemark
        
    }
}



extension CitiesSearchTableTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if(searchController.searchBar.text?.count == 0) {
        self.matchingItems.removeAll()
        self.tableView.reloadData()
        }
        guard let mapView = mapView, let searchText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
        guard let response = response else { return }
        self.matchingItems = response.mapItems
        self.tableView.reloadData()
        }
        
    }
  
}

