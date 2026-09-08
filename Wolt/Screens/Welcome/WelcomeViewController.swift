//
//  WelcomeViewController.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import UIKit
import Combine

class WelcomeViewController<ViewModel: WelcomeViewModel>: UIViewController {
    
    // MARK: - Variables
    let viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()
    private let networkImageViewLoader = NetworkImageViewLoader()
    
    // MARK: - init
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUIandConstraints()
        setUpViewModelToViewBindings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        networkImageViewLoader.cancelImageLoad()
    }

    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to the Wolt App!"
        label.font = Constants.UI.Fonts.title1
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "We are glad to have you here. Wolt app requires location permission in order to show you amazing restaurants nearby."
        label.font = Constants.UI.Fonts.body
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var requestLocationServicesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable location services", for: .normal)
        button.titleLabel?.font = Constants.UI.Fonts.headline
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Setup UI
    private func setupUIandConstraints() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(imageView)
        view.addSubview(requestLocationServicesButton)
        
        networkImageViewLoader.loadImage(from: URL(string: Constants.UI.woltWelcomePageImage)!)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                self.imageView.image = image
            }
            .store(in: &cancellables)
        
        titleLabel.addConstraints(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: Constants.UI.topPadding,
            paddingLeading: Constants.UI.horizontalPadding,
            paddingTrailing: Constants.UI.horizontalPadding
        )
        
        bodyLabel.addConstraints(
            top: titleLabel.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: Constants.UI.verticalPadding,
            paddingLeading: Constants.UI.horizontalPadding,
            paddingTrailing: Constants.UI.horizontalPadding
        )
        
        imageView.addConstraints(
            top: bodyLabel.bottomAnchor,
            paddingTop: Constants.UI.topPadding,
            widthAnchor: view.widthAnchor,
            widthMultiplier: 0.8,
            heightAnchor: view.widthAnchor,
            heightMultiplier: 0.8,
            centerX: view.centerXAnchor,
            centerY: view.centerYAnchor
        )
        
        requestLocationServicesButton.addConstraints(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            paddingBottom: 30,
            height: Constants.UI.buttonHeight,
            widthAnchor: view.widthAnchor,
            widthMultiplier: 0.8,
            centerX: view.centerXAnchor
        )
    }

    // MARK: - Functions
    private func setupNavigationBar() {
        navigationItem.title = nil
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
