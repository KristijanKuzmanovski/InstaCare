//
//  RequestCellTableViewCell.swift
//  InstaCare
//
//  Created by Dzin on 21.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit

class RequestCellTableViewCell: UITableViewCell {

    static let id = "cell"
    
    static func nib() -> UINib{
        return UINib(nibName: "RequestCellTableViewCell", bundle: Bundle(for: RequestCellTableViewCell.self))
    }
    
    public func configure (with name: String, request: String, date: String){
        Lname.text = name
        Lrequest.text = request
        Ldate.text = date
    }
    
    @IBOutlet weak var Lname: UILabel!
    @IBOutlet weak var Lrequest: UILabel!
    @IBOutlet weak var Ldate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
