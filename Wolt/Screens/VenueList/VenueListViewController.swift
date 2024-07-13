//
//  VenueListViewController.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import UIKit
import Combine

class VenueListViewController<ViewModel: VenueListViewModelProtocol>: UITableViewController {

    // MARK: - Variables

    let viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

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
        navigationItem.title = "Wolt"
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
        tableView.tableHeaderView = headerView
        tableView.register(
            VenueTableViewCell.self,
            forCellReuseIdentifier: VenueTableViewCell.reuseIdentifier
        )

        setupNavigationBar()
        setUpViewModelToViewBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startUpdatingLocation(every: 10)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopUpdatingLocation()
    }

    private func updateBackgroundView(state: ErrorState?) {
        if state != nil {
            let errorStateView = ErrorStateView(
                frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100)
            )
            errorStateView.title = state?.title
            errorStateView.body = state?.message
            tableView.backgroundView = errorStateView
        } else {
            tableView.backgroundView = nil
        }
    }

    // MARK: - Bindings
    func setUpViewModelToViewBindings() {
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                if $0 {
                    self.showLoadingIndicator()
                } else {
                    self.hideLoadingIndicator()
                }
            }
            .store(in: &cancellables)

        viewModel.currentAreaName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.headerView.title = $0
            }
            .store(in: &cancellables)

        viewModel.restaurantsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.errorStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorState in
                guard let self = self else { return }
                self.updateBackgroundView(state: errorState)
            }
            .store(in: &cancellables)
    }

    // MARK: - Table view datasource

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.currentRestaurants.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: VenueTableViewCell.reuseIdentifier
        ) as? VenueTableViewCell {
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(restaurant: viewModel.currentRestaurants[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension VenueListViewController: VenueTableViewCellDelegate {
    func didToggleFavorite(for cell: VenueTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let restaurant = viewModel.currentRestaurants[indexPath.row]
        viewModel.toggleFavoriteRestaurant(restaurant: restaurant)
        guard let venueId = restaurant.venue?.id else { return }
        restaurant.isFavorite ? viewModel.deleteFavoriteVenue(venueId: venueId) : viewModel.saveFavoriteVenue(venueId: venueId)
        cell.favoriteButton.isFavorite.toggle()
    }
}
