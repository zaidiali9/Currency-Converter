//
//  Worker.swift
//  Currency Converter
//
//  Created by Ali Hassan on 25/04/2025.
//

import Foundation


protocol CurrencyWorkerLogic {
    func getCurrencyCodes() async -> [String]
    func fetchExchangeRates(for currencies: [String]) async throws -> [String: Double]
    func convertCurrency(fromText: String?, fromCurrency: String, toCurrency: String, rates: [String: Double]) -> String
}
class Worker: CurrencyWorkerLogic{
    func getCurrencyCodes() async -> [String] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openexchangerates.org"
        components.path = "/api/currencies.json"
        components.queryItems = [
            URLQueryItem(name: "prettyprint", value: "false"),
            URLQueryItem(name: "show_alternative", value: "false"),
            URLQueryItem(name: "show_inactive", value: "false"),
            URLQueryItem(name: "app_id", value: "7a68cf9b023945969d58b7daca9e7609")
        ]
        
        guard let url = components.url else {
            print("Invalid URL")
            return []
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let currencies = try JSONDecoder().decode([String: String].self, from: data)
            return Array(currencies.keys).sorted()
        } catch {
            print("Error fetching currencies: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func fetchExchangeRates(for currencies: [String]) async throws -> [String: Double] {
        let symbolsString = currencies.joined(separator: ",")
        let url = URL(string: "https://openexchangerates.org/api/latest.json")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        components.queryItems = [
            URLQueryItem(name: "app_id", value: "e362032741424a1fabb86ddb4cbd5eea"),
            URLQueryItem(name: "base", value: "USD"),
            URLQueryItem(name: "symbols", value: symbolsString),
            URLQueryItem(name: "prettyprint", value: "false"),
            URLQueryItem(name: "show_alternative", value: "false")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)

        return decoded.rates.filter { currencies.contains($0.key) }
    }
    
    func convertCurrency(fromText: String?, fromCurrency: String, toCurrency: String, rates: [String: Double]) -> String {
        guard
            let fromRate = rates[fromCurrency],
            let toRate = rates[toCurrency],
            let text = fromText,
            let amount = Double(text)
        else {
            return "Invalid input"
        }
        
        let usdAmount = amount / fromRate
        let convertedAmount = usdAmount * toRate
        
        return String(format: "%.2f", convertedAmount)
    }

}
