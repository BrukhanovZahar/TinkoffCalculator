//
//  HistoryTableViewCell.swift
//  TinkoffCalculator
//
//  Created by Захар Брюханов on 21.02.2024.
//

import Foundation
import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var expressionLabel: UILabel!
    @IBOutlet private weak var resultLabel: UILabel!
    
    func configure(with expression: String, result: String) {
        expressionLabel.text = expression
        resultLabel.text = result
    }
}
