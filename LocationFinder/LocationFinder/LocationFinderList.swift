import UIKit
import MapKit
import CoreLocation

class TreasureList: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    let locationManager = CLLocationManager()
    let mapView = MKMapView()
    let tableView = UITableView()
    var saveButton: UIButton!
    var searchBar: UISearchBar!
    
    // Array of tuples containing the names and coordinates of the treasures
    var treasures = [
        ("McDonald's", CLLocationCoordinate2D(latitude: 43.6628917, longitude: -79.3835274)),
        ("Starbucks", CLLocationCoordinate2D(latitude: 43.651070, longitude: -79.397440)),
        ("Tim Hortons", CLLocationCoordinate2D(latitude: 43.657703, longitude: -79.384209))
    ]
    
    // Variable to keep track of the selected treasure index
    var selectedTreasureIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up searchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Enter location name"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        // Set up mapView
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        
        // Add tap gesture recognizer to mapView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        // Set up tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TreasureCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Set up save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Location", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveLocation), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        // Set the delegate for the location manager to the current view controller
        locationManager.delegate = self
        
        // Request the user's permission to use location services when the app is in use
        locationManager.requestWhenInUseAuthorization()
        
        // Show map centered on Canada
        showMapCenteredOnCanada()
        
        // Add annotations for treasures
        addTreasureAnnotations()
        
        setupConstraints()
    }
    
    // MARK: - Auto Layout
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.4),
            
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
            
            saveButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treasures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell with the identifier "TreasureCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "TreasureCell", for: indexPath)
        
        // Get the treasure name for the current row
        let treasure = treasures[indexPath.row]
        
        // Set the cell's text label to the treasure name
        cell.textLabel?.text = treasure.0
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Store the selected treasure index
        selectedTreasureIndex = indexPath.row
        
        // Open map for the selected treasure
        openMap(for: selectedTreasureIndex!)
    }
    
    // MARK: - Location handling
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
    
    // MARK: - Map handling
    
    func showMapCenteredOnCanada() {
        // Central Canada
        let centerCoordinate = CLLocationCoordinate2D(latitude: 56.1304, longitude: -106.3468)
        
        // area distance (zoom rate)
        let regionDistance: CLLocationDistance = 2000000 // 2000 km
        
        // Define map region and center
        let regionSpan = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        
        // Settings to open the map
        mapView.setRegion(regionSpan, animated: true)
    }
    
    func addTreasureAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        for treasure in treasures {
            let annotation = MKPointAnnotation()
            annotation.title = treasure.0
            annotation.coordinate = treasure.1
            mapView.addAnnotation(annotation)
        }
    }
    
    func openMap(for treasureIndex: Int) {
      let treasure = treasures[treasureIndex]
      let latitude = treasure.1.latitude
      let longitude = treasure.1.longitude
      
      // Create URL for Apple Maps with navigation enabled (optional)
      let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d"
      guard let url = URL(string: urlString) else { return }
      
      // Open the URL in the Maps application
      UIApplication.shared.open(url, options: [:]) { (success) in
        if !success {
          print("Failed to open Maps app")
        }
      }
    }

    
    @objc func saveLocation() {
        guard let selectedTreasureIndex = selectedTreasureIndex else { return }
        let treasure = treasures[selectedTreasureIndex]
        print("Location saved: \(treasure.0) at \(treasure.1.latitude), \(treasure.1.longitude)")
        // Save the location as needed, e.g., save to user defaults or a database
    }
    
    @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let alertController = UIAlertController(title: "New Location", message: "Enter a name for this location:", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Location name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let locationName = alertController.textFields?.first?.text, !locationName.isEmpty {
                self.treasures.append((locationName, coordinate))
                self.addTreasureAnnotations()
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            if let response = response {
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                for item in response.mapItems {
                    let annotation = MKPointAnnotation()
                    annotation.title = item.name
                    annotation.coordinate = item.placemark.coordinate
                    self.mapView.addAnnotation(annotation)
                }
                
                // Move the map to the searched location
                let coordinate = response.boundingRegion.center
                let regionDistance: CLLocationDistance = 1000
                let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                self.mapView.setRegion(regionSpan, animated: true)
            } else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
