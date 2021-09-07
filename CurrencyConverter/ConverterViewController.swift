//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by neoviso on 9/3/21.
//

import UIKit

class ConverterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    var currencyList = [CurrencyEntity]()
    //var currencyList = [CurrencyInfo(currencyName: "USD", isSell: true, currencyValue: 2.5), CurrencyInfo(currencyName: "EUR", isSell: true, currencyValue: 3.0), CurrencyInfo(currencyName: "RUB", isSell: true, currencyValue: 0.03), CurrencyInfo(currencyName: "BYN", isSell: true, currencyValue: 1), ]
    
    let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextField.delegate = self
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Обновить", style: .done, target: self, action: #selector(requestToAPI(sender:)))
        // Do any additional setup after loading the view.
    }
    
    @objc func requestToAPI(sender: UIBarButtonItem) {
        //valueTextField.text = "12345"
        //RELOAD DATA
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "BackgroundColor")]
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @IBAction func valueTextFieldDidChange(_ sender: UITextField) {
        if (valueTextField.text?.count != 0) {
            if ((valueTextField.text?.starts(with: ".")) == true) {
                valueTextField.text = "0" + valueTextField.text!
            }
            let number = NSNumber(value: Double(valueTextField.text!)!)
            resultLabel.text = String(formatter.string(from: number)!) + " USD" 
        }
        else {
            resultLabel.text = "0.00 USD"
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
