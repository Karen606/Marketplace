//
//  ReportsViewController.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 03.10.24.
//

import UIKit
import Combine

class ReportsViewController: UIViewController {
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var reportsCollectionView: UICollectionView!
    private let viewModel = ReportsViewModel.shared
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.fetchData()
    }
    
    func setupUI() {
        setNavigationBackButton()
        setNavigationMenuButton()
        reportsCollectionView.dataSource = self
        reportsCollectionView.delegate = self
        reportsCollectionView.register(UINib(nibName: "ReportCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReportCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        let itemWidth = ((view.frame.size.width - 76) / 2)
        layout.itemSize = CGSize(width: itemWidth, height: 114)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        layout.scrollDirection = .vertical
        reportsCollectionView.collectionViewLayout = layout
    }
    
    func subscribe() {
        viewModel.$reports
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reports in
                guard let self = self else { return }
                self.reportsCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @IBAction func choosePeriod(_ sender: UIButton) {
    }
}

extension ReportsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reports.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReportCollectionViewCell", for: indexPath) as! ReportCollectionViewCell
        cell.setupData(report: viewModel.reports[indexPath.row], index: indexPath.item)
        if indexPath.item < 3 {
            cell.backgroundColor = #colorLiteral(red: 0.3138786554, green: 0.6180545688, blue: 1, alpha: 1)
        } else {
            let row = indexPath.item / 2
            let column = indexPath.item % 2
            if (row % 2 == 0 && column == 0) || (row % 2 != 0 && column == 1) {
                cell.backgroundColor = #colorLiteral(red: 0.4437744617, green: 0.750282824, blue: 0.3307319283, alpha: 1)
            } else {
                cell.backgroundColor = #colorLiteral(red: 0.6509803922, green: 0.6549019608, blue: 0.3568627451, alpha: 1)
            }
        }
        return cell
    }
}
