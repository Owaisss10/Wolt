//
//  VenueListViewController.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import UIKit
import Combine

class VenueListViewController<ViewModel: VenueListViewModel>: UITableViewController {

    // MARK: - Variables

    let viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    // TODO: Takew this to view model
    private var currentRestaurants = [Restaurant]()
    /// Screen empty state
    private var errorState: ErrorState?

    private func showLoadingIndicator() {
        activityIndicator.color = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    // Define the header view as a private variable
    private lazy var headerView: CurrentLocationTableHeaderView = {
        let header = CurrentLocationTableHeaderView(
            frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100)
        )
        return header
    }()

    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupNavigationBar() {
        navigationItem.title = "Nearby restaurants"
        // A loading activity indicator is shown at the right of navigation bar
        activityIndicator.hidesWhenStopped = true
        let activityIndicatorBarButton = UIBarButtonItem(
            customView: activityIndicator
        )
        navigationItem.rightBarButtonItem = activityIndicatorBarButton
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        tableView.separatorStyle = .singleLine

        tableView.register(VenueTableViewCell.self, forCellReuseIdentifier: VenueTableViewCell.reuseIdentifier)

        tableView.tableHeaderView = headerView

        setupNavigationBar()
        setUpViewModelToViewBindings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopUpdatingLocation()
    }

    private func updateBackgroundView() {
        if errorState != nil {
            let errorStateView = ErrorStateView(
                frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100)
            )
            errorStateView.title = errorState?.title
            errorStateView.body = errorState?.message
            tableView.backgroundView = errorStateView
        } else {
            tableView.backgroundView = nil
        }
    }

    // MARK: - Bindings
    func setUpViewModelToViewBindings() {
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [self] in
                if $0 {
                    showLoadingIndicator()
                } else {
                    hideLoadingIndicator()
                }
            }
            .store(in: &cancellables)

        viewModel.currentAreaName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.headerView.title = $0
            }
            .store(in: &cancellables)

        viewModel.restaurantsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if (self?.currentRestaurants != $0) {
                    self?.currentRestaurants = $0
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)

        viewModel.errorStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorState in
                self?.errorState = errorState
                self?.updateBackgroundView()
            }
            .store(in: &cancellables)

        viewModel.nextViewControllerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] controller in
                self?.navigationController?.pushViewController(controller, animated: true)
            }
            .store(in: &cancellables)
    }

    // MARK: - Table view datasource

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.restaurantsPublisher.value.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: VenueTableViewCell.reuseIdentifier
        ) as? VenueTableViewCell else {
            fatalError("VenueTableViewCell not configured properly")
        }
        cell.delegate = self
        cell.configure(restaurant: viewModel.restaurantsPublisher.value[indexPath.row])
        return cell

    }

    // MARK: - Table view delegate
//    override func tableView(
//        _ tableView: UITableView,
//        didSelectRowAt indexPath: IndexPath
//    ) {
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
}

extension VenueListViewController: VenueTableViewCellDelegate {
    func didToggleFavorite(for cell: VenueTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
print("spike, cell index", indexPath)
        var restaurant = viewModel.restaurantsPublisher.value[indexPath.row]
//        restaurant.isFavorite = !restaurant.isFavorite
        print("spike, cell restaurant", restaurant.isFavorite)

        viewModel.saveFavoriteState(for: restaurant.venue?.id, isFavorite: !restaurant.isFavorite)
        cell.favoriteButton.isFavorite.toggle()
    }
}
