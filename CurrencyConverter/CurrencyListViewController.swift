//
//  CurrencyListViewController.swift
//  CurrencyConverter
//
//  Created by neoviso on 9/8/21.
//

import UIKit
import CoreData

class Currency {
    var sectionName: String?
    var currencyList: [CurrencyMainInfo]?
    
    init(sectionName: String, currencyList: [CurrencyMainInfo]) {
        self.sectionName = sectionName
        self.currencyList = currencyList
    }
}

class CurrencyMainInfo {
    var code: String
    var name: String
    var date: Date?
    
    init(code: String, name: String, date: Date?){
        self.code = code
        self.name = name
        self.date = date
    }
}

class CurrencyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //VARIABLES
    
    var allCurrency = [String]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedRow: IndexPath?
    var toFromString: String = ""
    var currencyList = [CurrencyEntity]()
    var currencyLatestList = [LatestCurrency]()
    @IBOutlet weak var tableView: UITableView!
    var currency = [Currency]()
    var selectedCode = ""
    
    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currency.append(Currency.init(sectionName: "Недавние", currencyList: []))
                
        currency.append(Currency.init(sectionName: "Все валюты", currencyList: []))
        
        if (toFromString == "From") {
            selectedCode = currencyCodeFrom
        }
        else {
            selectedCode = currencyCodeTo
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Очистить недавние", style: .done, target: self, action: #selector(clearLatest(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationController?.title = "Choose currency"
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        getAllItems()
        getAllLatestItems()
    }
    
    //CORE DATA
    
    func getAllItems() {
        do {
            currency[1].currencyList?.removeAll()
            currencyList = try context.fetch(CurrencyEntity.fetchRequest())
            for item in currencyList {
                print(item.code)
                currency[1].currencyList?.append(CurrencyMainInfo(code: item.code!, name: item.name!, date: nil))
                allCurrency.append(item.code!)
            }
            currency[1].currencyList = currency[1].currencyList?.sorted(by: { $0.code < $1.code })
        }
        catch {
                
        }
    }
    
    func getAllLatestItems() {
        do {
            currency[0].currencyList?.removeAll()
            currencyLatestList = try context.fetch(LatestCurrency.fetchRequest())
            for item in currencyLatestList {
                if (allCurrency.contains(item.code!)) {
                    currency[0].currencyList?.append(CurrencyMainInfo(code: item.code!, name: item.name!, date: item.date))
                }
            }
            currency[0].currencyList = currency[0].currencyList?.sorted(by: { $0.date! > $1.date! })
        }
        catch {
                
        }
    }
    
    func createLatestItem(newItem: CurrencyMainInfo) {
        let tempItem = LatestCurrency(context: context)
        tempItem.code = newItem.code
        tempItem.name = newItem.name
        tempItem.date = Date()
        
        do {
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
    
    func updateCreateItem(newItem: CurrencyMainInfo) {
        let tmpCurr = currencyLatestList.first(where: {$0.code == newItem.code})
        if (tmpCurr != nil) {
            deleteItem(deleteItem: tmpCurr!)
        }
        createLatestItem(newItem: newItem)
    }
    
    func deleteItem(deleteItem: LatestCurrency) {
         context.delete(deleteItem)
             
         do {
             try context.save()
         }
         catch {
            context.rollback()
         }
    }
    
    func deleteItemByCode(deleteItemString: String) {
        let tmpCurr = currencyLatestList.first(where: {$0.code == deleteItemString})! as LatestCurrency
        if (tmpCurr != nil) {
            deleteItem(deleteItem: tmpCurr)
        }
             
         do {
             try context.save()
         }
         catch {
            context.rollback()
         }
    }
    
    func reloadCurrentData(codeFrom: String?, codeTo: String?) {
        do {
            let currentCurrencyList = try context.fetch(CurrentCurrency.fetchRequest())
            if (currentCurrencyList.count > 0){
                let tmp = currentCurrencyList.first! as! CurrentCurrency
                if (codeTo != nil) {
                    tmp.codeTo = codeTo
                }
                else {
                    tmp.codeFrom = codeFrom
                }
                do {
                    try context.save()
                }
                catch {
                    context.rollback()
                }
            }
        }
        catch {
            context.rollback()
        }
    }
    
    //TABLE VIEW
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CurrencyTableCell = self.tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyTableCell
        cell.currencyLabel.text = currency[indexPath.section].currencyList?[indexPath.row].code
        cell.currencyNameLabel.text = currency[indexPath.section].currencyList?[indexPath.row].name
        cell.tintColor = UIColor(named: "PrimaryColor")
        if (cell.currencyLabel.text == selectedCode) {
            cell.accessoryType = .checkmark
            self.selectedRow = indexPath
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 && currency[section].currencyList!.count > 5) {
            return 5
        }
        else {
            return currency[section].currencyList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (currency[section].currencyList!.count > 0) {
            return 40
        }
        else {
            return 0
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
        let cell = tableView.cellForRow(at: indexPath) as? CurrencyTableCell
        if (toFromString == "From") {
            currencyCodeFrom = (cell?.currencyLabel.text)!
            reloadCurrentData(codeFrom: currencyCodeFrom, codeTo: nil)
        }
        else {
            currencyCodeTo = (cell?.currencyLabel.text)!
            reloadCurrentData(codeFrom: nil, codeTo: currencyCodeTo)
        }
        let tempCurrency = CurrencyMainInfo(code: cell!.currencyLabel.text!, name: cell!.currencyNameLabel.text!, date: Date())
        updateCreateItem(newItem: tempCurrency)
        navigationController?.popViewController(animated: true)
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return currency.count
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row > 5 {
            return UITableViewCell.EditingStyle.none
        }
        else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let cell = tableView.cellForRow(at: indexPath) as? CurrencyTableCell
            deleteItemByCode(deleteItemString: (cell?.currencyLabel.text)!)
            getAllLatestItems()
            tableView.reloadData()
        }
    }
    
    @objc func clearLatest(sender: UIBarButtonItem) {
        do {
            currency[0].currencyList?.removeAll()
            currencyLatestList = try context.fetch(LatestCurrency.fetchRequest())
            for item in currencyLatestList {
                context.delete(item)
            }
            tableView.reloadData()
            try context.save()
        }
        catch {
            context.rollback()
        }
        
    }
}
