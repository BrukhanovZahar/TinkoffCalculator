//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Захар Брюханов on 09.02.2024.
//

import UIKit

struct Calculation {
    let expression: [CalculationHistoryItem]
    let result: Double
    let date: Date
}

class CalculationsListViewController: UIViewController {
    
    var calculations: [Calculation] = []
    @IBOutlet weak var tableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Прошлые вычисления"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .systemGray5
        let tableHeaderView = UIView()
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")
        
        calculations.sort { $0.date > $1.date }
    }
    
    private func expressionToString(_ expression: [CalculationHistoryItem]) -> String {
        var result = ""
        
        for operand in expression {
            switch operand{
                case let .number(value):
                    result += String(value) + " "
                case let .operation(value):
                    result += value.rawValue + " "
            }
        }
        
        return result
    }
    
}

extension CalculationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

extension CalculationsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return calculations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        let historyItem = calculations[indexPath.row]
        cell.configure(with: expressionToString(historyItem.expression), result: String(historyItem.result))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            headerView.backgroundColor = .systemGray5
            
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 0, width: headerView.frame.width-10, height: headerView.frame.height-20)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            
            label.text = formatter.string(from: calculations[section].date as Date)
            
            label.font = .systemFont(ofSize: 16)
            label.textColor = .black
            
            headerView.addSubview(label)
            
            return headerView
    }
}
