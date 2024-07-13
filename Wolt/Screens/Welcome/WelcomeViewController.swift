//
//  WelcomeViewController.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import UIKit
import Combine

class WelcomeViewController<ViewModel: WelcomeViewModel>: UIViewController {

    let viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()
    private let networkImageViewLoader = NetworkImageViewLoader()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupNavigationBar() {
        navigationItem.title = "Wolt"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUIandConstraints()
        setUpViewModelToViewBindings()
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to the Wolt App!"
        label.font = .preferredFont(forTextStyle: .title1)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "We are glad to have you here. Wolt app requires location permission in order to show you amazing restaurants nearby."
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()


    private lazy var requestLocationServicesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable location services", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func setupUIandConstraints() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(imageView)
        view.addSubview(requestLocationServicesButton)

        networkImageViewLoader.loadImage(from: URL(string: "https://woltpartner.dk/wp-content/uploads/2021/08/BTQ_wolt_bike_couriers_6K_v03@2x.jpg")!)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                self.imageView.image = image
            }
            .store(in: &cancellables)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),


            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            requestLocationServicesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            requestLocationServicesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            requestLocationServicesButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            requestLocationServicesButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }

    @objc func locationButtonTapped() {
        if viewModel.isLocationPermissionGranted {
            viewModel.navigateToVenueListViewController()
        } else {
            viewModel.checkAndRequestLocationPermissions()
        }
    }

    // MARK: - Bindings
    func setUpViewModelToViewBindings() {
        viewModel.locationPermissionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .restricted, .denied:
                    self.viewModel.presentSettingsAlertController()
                    self.requestLocationServicesButton.setTitle("Enable location services", for: .normal)
                case .authorizedWhenInUse, .authorizedAlways:
                    self.requestLocationServicesButton.setTitle("Explore nearby restaurants", for: .normal)
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.locationPermissionDenied
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.requestLocationServicesButton.setTitle("Enable location services", for: .normal)
                self.viewModel.presentSettingsAlertController()
            }
            .store(in: &cancellables)

        viewModel.locationPermissionGranted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.requestLocationServicesButton.setTitle("Explore nearby restaurants", for: .normal)
            }
            .store(in: &cancellables)

        viewModel.nextViewControllerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] controller in
                guard let self = self else { return }
                self.navigationController?.pushViewController(controller, animated: true)
            }
            .store(in: &cancellables)

        viewModel.presentViewControllerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] controller in
                guard let self = self else { return }
                self.present(controller, animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }
}
