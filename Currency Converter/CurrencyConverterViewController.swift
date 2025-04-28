//
//  CurrencyConverterViewController.swift
//  Currency Converter
//
//  Created by Ali Hassan on 28/04/2025.
//

import UIKit

protocol CurrencyDisplayLogic {
    func showConvertedValue(value: String)
}

class CurrencyConverterViewController: UIViewController {
    
    // IBOutlet
    @IBOutlet weak var currencyFrom: UIButton!
    @IBOutlet weak var codeLabelfrom: UILabel!
    @IBOutlet weak var fromText: UITextField!
    @IBOutlet weak var currencyTo: UIButton!
    @IBOutlet weak var codeLabelto: UILabel!
    @IBOutlet weak var toText: UITextField!
    
    @IBAction func convertCurrency(_ sender: Any) {
        intractor?.convertCurrency(fromText: self.fromText.text, fromCurrency: self.fromCurrency, toCurrency: self.toCurrency, rates: self.currencyRates)
    }
    
    // Required Data
    var currencyCodes: [String] = []
    var currencyRates: [String: Double] = [:]
    
    var toCurrency: String = ""
    var fromCurrency: String = "USD"  // Default set to USD
    
    var intractor: CurrencyBussinessLogic?
    
    func setup() {
        let presenter = Presenter()
        let interactor = Interactor()
        presenter.viewController = self
        interactor.presenter = presenter
        self.intractor = interactor
    }
    private func configureButtonMenus() {
        var uiActions1 = [UIAction]()
        var uiActions2 = [UIAction]()
        
        for code in self.currencyCodes {
            let action1 = UIAction(
                title: code,
                state: (code == self.fromCurrency) ? .on : .off,
                handler: optionClosure1
            )
            let action2 = UIAction(
                title: code,
                state: (code == self.toCurrency) ? .on : .off,
                handler: optionClosure2
            )
            uiActions1.append(action1)
            uiActions2.append(action2)
        }
        
        currencyFrom.menu = UIMenu(children: uiActions1)
        currencyFrom.showsMenuAsPrimaryAction = true
        
        currencyTo.menu = UIMenu(children: uiActions2)
        currencyTo.showsMenuAsPrimaryAction = true
    }

    private lazy var optionClosure1: (UIAction) -> Void = { action in
        self.fromCurrency = action.title
        self.codeLabelfrom.text = action.title
    }
    
    private lazy var optionClosure2: (UIAction) -> Void = { action in
        self.toCurrency = action.title
        self.codeLabelto.text = action.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.fromText.delegate = self
        self.toText.delegate = self
        
        addDoneButtonOnNumpad(textField: self.fromText)
        addDoneButtonOnNumpad(textField: self.toText)
        
        Task {
            if let intractor {
                self.currencyCodes = await intractor.getCurrencyCodes()
            }
            
            
            setDefaultCurrencies()
            configureButtonMenus()

            do {
                if let intractor {
                    self.currencyRates = try await intractor.fetchExchangeRates(for: self.currencyCodes)
                }
            } catch {
                print("Failed to fetch rates: \(error)")
            }
        }
    }
    
    private func setDefaultCurrencies() {
        self.fromCurrency = "USD"
        self.codeLabelfrom.text = "USD"
        
        // Detect device region and set default 'toCurrency'
        let regionCode = Locale.current.region?.identifier ?? "US"
        let currency = currencyCode(for: regionCode) ?? "USD"
        
        if currencyCodes.contains(currency) {
            self.toCurrency = currency
            self.codeLabelto.text = currency
        } else {
            // If region's currency code is not available, fallback to USD
            self.toCurrency = "USD"
            self.codeLabelto.text = "USD"
        }
    }
    
    private func currencyCode(for regionCode: String) -> String? {
        // Find currency code for a given region code
        let localeIdentifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: regionCode])
        let locale = Locale(identifier: localeIdentifier)
        return locale.currency?.identifier
    }
}

extension CurrencyConverterViewController: CurrencyDisplayLogic {
    func showConvertedValue(value: String) {
        self.toText.text = value
    }
}

extension CurrencyConverterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func addDoneButtonOnNumpad(textField: UITextField) {
        let keypadToolbar: UIToolbar = UIToolbar()
        keypadToolbar.items = [
            UIBarButtonItem(title: "Done", style: .done, target: textField, action: #selector(UITextField.resignFirstResponder)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        ]
        keypadToolbar.sizeToFit()
        textField.inputAccessoryView = keypadToolbar
    }
}
