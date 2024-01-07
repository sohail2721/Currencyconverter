//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Muhammad Sohail on 07/01/2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var result: Double?
    @State private var ratesResponse: RatesResponse?
    @State var usdRate: Double = 0.0
    @State private var selectedCurrencyIndex = 0
    let currencies = ["USD 🇺🇸", "AUD 🇦🇺", "CAD 🇨🇦", "PKR 🇵🇰", "MXN 🇲🇽"]
    let actCurrencies = ["USD", "AUD", "CAD", "PKR", "MXN"]
    var body: some View {
       
        VStack {
            Text("Currency Converter") // Pakistan flag emoji
                            .font(.system(size: 20))
            HStack{
                Text("EUR 🇬🇧")
                                .font(.system(size: 20))
                TextField("EUR",text: $userInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onReceive(Just(userInput)) { input in
                        // Filter out non-numeric characters
                        let filteredInput = input.filter { "0123456789".contains($0) }
                        userInput = filteredInput
                    }
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
                
            }
            HStack{
                
//                Text("PKR 🇵🇰")
//                    .font(.system(size: 20))
                Picker(selection: $selectedCurrencyIndex, label: Text("")) {
                               ForEach(0..<4) {
                                   Text(self.currencies[$0])
                               }
                           }
                           .pickerStyle(MenuPickerStyle())
                           .frame(width: 100)
//                           .padding()
                Text(result.map { String(format: "%.2f", $0) } ?? "")
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .frame(width: 158,height: 25)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    )
                    .foregroundColor(.white)
                    .onChange(of: userInput){ newValue in
                    convert()
                            
                       
                }
                    .onChange(of: selectedCurrencyIndex){ newValue in
                        
                        getData()
                        convert()
                    }
            }
            .onAppear{
                getData()
                
            }
                Spacer()
            

        }
                
        .padding()
        .frame(width: 350,height: 250)
    }
    
    func convert()  {
        if let inputValue = Double(userInput) {
            result = inputValue * usdRate
        } else {
            // Handle invalid input (non-numeric)
            result = nil
        }
    }
    
   

    func getData() {
        guard let urlString = "http://data.fixer.io/api/latest?access_key=0121e85cd588bb4c0adc85aaa8a5d538&symbols=USD,AUD,CAD,PKR,MXN&format=1".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    ratesResponse = try decoder.decode(RatesResponse.self, from: data)

                    // Extract and store the rate of USD
                    if let usdRateValue = ratesResponse?.rates[actCurrencies[selectedCurrencyIndex]] {
                        usdRate = usdRateValue
                        print("Rate: \(usdRateValue)")
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

struct RatesResponse: Codable {
    let success: Bool
    let timestamp: Int?
    let base: String?
    let date: String
    let rates: [String: Double]
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
