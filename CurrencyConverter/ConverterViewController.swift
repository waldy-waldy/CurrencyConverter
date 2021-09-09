//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by neoviso on 9/3/21.
//

import UIKit

import MBProgressHUD
import Alamofire
import CoreData

var currencyCodeFrom = "USD"
var currencyCodeTo = "BYN"
var currencyValue = 1000.00

class CurrentCurr {
    var codeFrom: String
    var codeTo: String
    var value: Double
    
    init(codeFrom: String, codeTo: String, value: Double) {
        self.codeFrom = codeFrom
        self.codeTo = codeTo
        self.value = value
    }
}

class ConverterViewController: UIViewController, UITextFieldDelegate {

    //OUTLETS
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var currencyFromButton: UIButton!
    @IBOutlet weak var currencyToButton: UIButton!
    @IBOutlet weak var currencyRateFrom: UILabel!
    @IBOutlet weak var currencyRateTo: UILabel!
    @IBOutlet weak var currencyRateFromTo: UILabel!
    @IBOutlet weak var currencyRateToFrom: UILabel!
    
    //VARIABLES
    
    var segueType = "From"
    var currencyList = [CurrencyEntity]()
    var currentCurrencyList = [CurrentCurrency]()
    var currencyValueFrom = 0.00
    var currencyValueTo = 0.00
    var currencyValueFromTo = 0.00
    var currencyValueToFrom = 0.00
    let url = "https://www.floatrates.com/daily/byn.json"
    let formatter = NumberFormatter()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextField.delegate = self
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Обновить", style: .done, target: self, action: #selector(requestToAPI(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        takeData()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let val = valueTextField.text ?? "0.00"
        reloadCurrentData(codeFrom: currencyCodeFrom, codeTo: currencyCodeTo, value: Double(val)!)
    }
    
    func takeData() {
        getCurrentItem()
        currencyValueFrom = getItemByCode(code: currencyCodeFrom)
        currencyValueTo = getItemByCode(code: currencyCodeTo)
        valueTextField.text = String(currencyValue)
        currencyValueFromTo = currencyValueFrom/currencyValueTo
        currencyValueToFrom = currencyValueTo/currencyValueFrom
        currencyFromButton.setTitle(currencyCodeFrom, for: .normal)
        currencyToButton.setTitle(currencyCodeTo, for: .normal)
        currencyRateFrom.text = currencyCodeFrom + " -> " + String(format: "%.4f", currencyValueFrom)
        currencyRateTo.text = currencyCodeTo + " -> " + String(format: "%.4f", currencyValueTo)
        currencyRateFromTo.text = currencyCodeFrom + " -> " + currencyCodeTo + " = " + String(format: "%.4f", currencyValueFromTo)
        currencyRateToFrom.text = currencyCodeTo + " -> " + currencyCodeFrom + " = " + String(format: "%.4f", currencyValueToFrom)
        if (valueTextField.text?.count != 0) {
            let resultValue = Double(valueTextField.text!)! * currencyValueFromTo
            let number = NSNumber(value: resultValue)
            resultLabel.text = String(formatter.string(from: number)!) + " " + currencyCodeTo
        }
        else {
            resultLabel.text = "0.00 " + currencyCodeTo
        }
    }
    
    //API
    
    @objc func requestToAPI(sender: UIBarButtonItem) {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading..."
        AF.request(self.url).responseJSON { [self] response in
            switch response.result {
                case .success(let value):
                    if let data = value as? [String: Any] {
                        clearItems()
                        createItem(newItem: CurrencyInfo(code: "BYN", rate: 1.00, name: "Belarussian Ruble"))
                        for item in data.keys {
                            let info = data[item] as? [String: Any]
                            let code = info?["code"] as! String
                            let name = info?["name"] as! String
                            let rate = info?["inverseRate"] as! Double
                            let currencyTemp = CurrencyInfo(code: code, rate: rate, name: name)
                            createItem(newItem: currencyTemp)
                        }
                    }
                    loadingNotification.hide(animated: true)
                    takeData()
                case .failure(_):
                    loadingNotification.hide(animated: true)
            }
        }
    }

    //TEXT FIELD
    
    @IBAction func valueTextFieldDidChange(_ sender: UITextField) {
        var resultValue = Double()
        if (valueTextField.text?.count != 0) {
            if ((valueTextField.text?.starts(with: ".")) == true) {
                valueTextField.text = "0" + valueTextField.text!
            }
            resultValue = Double(valueTextField.text!)! * currencyValueFromTo
            let number = NSNumber(value: resultValue)
            resultLabel.text = String(formatter.string(from: number)!) + " " + currencyCodeTo
        }
        else {
            resultLabel.text = "0.00 " + currencyCodeTo
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = "0123456789."
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: string)
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let arrayOfString = newString.components(separatedBy: ".")
        
        var isOneDough = true
        var isTwoCharAfterDough = true
        
        if arrayOfString.count > 2 {
            isOneDough = false
        }
        if arrayOfString.count == 2 {
            if arrayOfString[1].count > 2 {
                isTwoCharAfterDough = false
            }
        }
        
        return allowedCharacterSet.isSuperset(of: typedCharacterSet) && isOneDough && isTwoCharAfterDough
    }
        
    //CORE DATA
    
    func reloadCurrentData(codeFrom: String, codeTo: String, value: Double) {
        do {
            currentCurrencyList = try context.fetch(CurrentCurrency.fetchRequest())
            if (currentCurrencyList.count > 0) {
                context.delete(currentCurrencyList.first!)
            }
            let tempItem = CurrentCurrency(context: context)
            tempItem.codeFrom = codeFrom
            tempItem.codeTo = codeTo
            tempItem.lastValue = value
            
            do {
                try context.save()
            }
            catch {
                context.rollback()
            }
        }
        catch {
            context.rollback()
        }
    }
    
    func getCurrentItem() {
        do {
            currentCurrencyList = try context.fetch(CurrentCurrency.fetchRequest())
            if (currentCurrencyList.count == 0) {
                let tempItem = CurrentCurrency(context: context)
                tempItem.codeFrom = "USD"
                tempItem.codeTo = "BYN"
                tempItem.lastValue = 1000.00
                do {
                    try context.save()
                }
                catch {
                    context.rollback()
                }
            }
            currentCurrencyList = try context.fetch(CurrentCurrency.fetchRequest())
            if (currentCurrencyList.count > 0) {
                currencyCodeFrom = (currentCurrencyList.first?.codeFrom)!
                currencyCodeTo = (currentCurrencyList.first?.codeTo)!
                currencyValue = currentCurrencyList.first!.lastValue
            }
            else {
                currencyCodeFrom = "USD"
                currencyCodeTo = "BYN"
                currencyValue = 1000.00
            }
        }
        catch {
            currencyCodeFrom = "USD"
            currencyCodeTo = "BYN"
            currencyValue = 1000.00
            
        }
    }
    
    func getItemByCode(code: String) -> Double {
        var rate = 0.00
        do {
            currencyList = try context.fetch(CurrencyEntity.fetchRequest())
            let curr = currencyList.first(where: { $0.code == code})
            rate = curr!.rate
        }
        catch {
                
        }
        return rate
    }
    
    func clearItems() {
        do {
            let items = try context.fetch(CurrencyEntity.fetchRequest()) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
        
    func createItem(newItem: CurrencyInfo) {
        let tempItem = CurrencyEntity(context: context)
        tempItem.code = newItem.code
        tempItem.rate = newItem.rate
        
        do {
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
    
    //SEGUE
    
    @IBAction func fromToBtnDidTap(_ sender: UIButton) {
        
        switch sender.tag {
        
        case 1:
            segueType = "From"
        case 2:
            segueType = "To"
        default:
            print("3")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CurrencyListViewController {
            destination.toFromString = segueType
        }
    }
}
