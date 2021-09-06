//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by neoviso on 9/3/21.
//

import UIKit

class Currency {
    var sectionName: String?
    var currencyList: [String]?
    
    init(sectionName: String, currencyList: [String]) {
        self.sectionName = sectionName
        self.currencyList = currencyList
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedRow: IndexPath?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CurrencyTableCell = self.tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyTableCell
        let text = currency[indexPath.section].currencyList?[indexPath.row]
        cell.currencyLabel.text = text
        cell.tintColor = UIColor(named: "PrimaryColor")
        /*
        if text == "USD" {
            cell.accessoryType = .checkmark
        }
        */
        
        cell.accessoryType = self.selectedRow == indexPath ? .checkmark : .none
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationController?.title = "Choose currency"
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return currency[section].currencyList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = UIColor(named: "PrimaryColor")
        
        let lbl = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width - 15, height: 40))
        lbl.text = currency[section].sectionName
        lbl.textColor = UIColor(named: "BackgroundColor")
        view.addSubview(lbl)
        return view
    }
    
    //  DELETE
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    /*
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return currency.count
    }
    
    @IBOutlet weak var tableView: UITableView!
    var currency = [Currency]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currency.append(Currency.init(sectionName: "Latest", currencyList: ["USD", "BYN"]))
                
        currency.append(Currency.init(sectionName: "All", currencyList: ["USD", "BYN", "EUR", "RUB"]))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }


}

