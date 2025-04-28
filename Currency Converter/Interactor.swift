//
//  Interactor.swift
//  Currency Converter
//
//  Created by Ali Hassan on 25/04/2025.
//

protocol CurrencyBussinessLogic {
    func getCurrencyCodes() async -> [String]
    func fetchExchangeRates(for currencies: [String]) async throws -> [String: Double]
    func convertCurrency(fromText: String?, fromCurrency: String, toCurrency: String, rates: [String: Double])
}


class Interactor: CurrencyBussinessLogic{
    var worker: Worker?
    var presenter: CurrencyPresenterLogic?
    init(){
        worker = Worker()
    }
    
    func getCurrencyCodes() async -> [String]{
        return await worker?.getCurrencyCodes() ?? []
    }
    
    func fetchExchangeRates(for currencies: [String]) async throws -> [String: Double]{
        return try await worker?.fetchExchangeRates(for: currencies) ?? [:]
    }
    
    func convertCurrency(fromText: String?, fromCurrency: String, toCurrency: String, rates: [String: Double]){
        let value = worker?.convertCurrency(fromText: fromText, fromCurrency: fromCurrency, toCurrency: toCurrency, rates: rates) ?? ""
        presenter?.presentConverted(value: value)
    }
}

