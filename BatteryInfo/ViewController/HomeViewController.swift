import Foundation
import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView = UITableView()
    private var simpleItems: [InfoItem] = []
    private var refreshTimer: Timer?
    private var showOSBuildVersion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        title = NSLocalizedString("CFBundleDisplayName", comment: "")
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if !BatteryDataController.checkRunTimePermission() {
            if !BatteryDataController.checkInstallPermission() {
                let alert = UIAlertController(title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("NeedRunTimePermissionMessage", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel))
                present(alert, animated: true)
                return
            } else {
                let alert = UIAlertController(title: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString("TemporaryNotSupportMessage", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel))
                present(alert, animated: true)
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAutoRefresh()
        loadBatteryData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()
    }
    
    @objc private func loadBatteryData() {
        BatteryDataController.getInstance.refreshBatteryInfo()
        simpleItems = BatteryDataController.getInstance.getSimplifiedHomeItems()
        
        DispatchQueue.main.async {
            if self.isViewLoaded && self.view.window != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    private func startAutoRefresh() {
        stopAutoRefresh()
        if SettingsUtils.instance.getAutoRefreshDataView() {
            refreshTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadBatteryData), userInfo: nil, repeats: true)
        }
    }
    
    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return simpleItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = simpleItems[indexPath.row].text
        return cell
    }
}
