import UIKit
import MapKit

// MARK: - NoteDatailViewController

class NoteDateilViewController: UIViewController {
    
    // MARK: - Properties
    
    private var note: Note?
    private var isEditingNote: Bool {
        return note != nil
    }
    
    private let titleTextField = UITextField()
    private let bodyTextView = UITextView()
    private let mapView = MKMapView()
    private var selectedCoordinate: CLLocationCoordinate2D?
    
    // MARK: - Initialization
    
    init(note: Note? = nil) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
        if let note = note {
            selectedCoordinate = note.coordinate
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = isEditingNote ? "Редактировать" : "Добавить"
        
        setupViews()
        setupNavigationBar()
        populateData()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        titleTextField.placeholder = "Заголовок"
        titleTextField.borderStyle = .roundedRect
        
        bodyTextView.layer.borderColor = UIColor.systemGray4.cgColor
        bodyTextView.layer.borderWidth = 1
        bodyTextView.layer.cornerRadius = 8
        
        mapView.isUserInteractionEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(gesture)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleTextField)
        view.addSubview(bodyTextView)
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),

            bodyTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bodyTextView.heightAnchor.constraint(equalToConstant: 100),

            mapView.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mapView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveNote))
        
        if isEditingNote {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                                               target: self,
                                                               action: #selector(deleteNote))
        }
    }
    
    private func populateData() {
        if let note = note {
            titleTextField.text = note.title
            bodyTextView.text = note.body
            selectedCoordinate = note.coordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = note.coordinate
            mapView.addAnnotation(annotation)
            mapView.setRegion(MKCoordinateRegion(center: note.coordinate,
                                                 latitudinalMeters: 1000,
                                                 longitudinalMeters: 1000), animated: true)
        } else {
            if let currentLocation = LocationManager.shared.currentLocation {
                mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate,
                                                     latitudinalMeters: 1000,
                                                     longitudinalMeters: 1000), animated: true)
                
            } else {
                print("Текущая локация недоступна.")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func mapTapped(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        selectedCoordinate = coordinate
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    @objc func saveNote() {
        guard let title = titleTextField.text, !title.isEmpty,
              let body = bodyTextView.text, !body.isEmpty,
              let coordinate = selectedCoordinate else {
            let ac = UIAlertController(title: "Ошибка", message: "Пожалуйста, заполните все поля и выберите местоположение на карте.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        var notes = NotesStore.shared.load()
        
        if var existingNote = note {
            existingNote.title = title
            existingNote.body = body
            existingNote.latitude = coordinate.latitude
            existingNote.longitude = coordinate.longitude
            
            if let index = notes.firstIndex(of: note!) {
                notes[index] = existingNote
            }
        } else {
            let newNote = Note(title: title,
                               body: body,
                               latitude: coordinate.latitude,
                               longitude: coordinate.longitude)
            notes.append(newNote)
        }
        
        NotesStore.shared.save(notes: notes)
        LocationManager.shared.notes = notes
        LocationManager.shared.updateMonitoredRegions()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteNote() {
        guard let note = note else { return }

        var notes = NotesStore.shared.load()
        notes.removeAll { $0.id == note.id }

        LocationManager.shared.notes = notes
        NotesStore.shared.save(notes: notes)

        navigationController?.popViewController(animated: true)
    }
}
