//
//  ResultView.swift
//  Electricity Cost App
//
//  Created by David Mahbubi on 08/05/23.
//

import SwiftUI
import CoreData

struct ResultView: View {
    
    @Environment(\.managedObjectContext) var managedObjContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowEmptyAlert: Bool = false
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)]) var applianceGet: FetchedResults<Appliances>
    
    @Binding var electricityRate: String
    
    var body: some View {
        List {
            Section ("globalAverageCost") {
                HStack {
                    Text("daily")
                    Spacer()
                    Text(formatCurrencyNumber(number: applianceGet.map { countCostPerDay(avgUsageUnit: $0.avg_usage_unit!, avgUsage: $0.avg_usage, wattage: $0.wattage) }.reduce(0) { result, number in
                            return result + number
                        }
                    ))
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("monthly")
                    Spacer()
                    Text(formatCurrencyNumber(number: applianceGet.map { countCostPerMonth(avgUsageUnit: $0.avg_usage_unit!, avgUsage: $0.avg_usage, wattage: $0.wattage, avgUsageRepeat: $0.avg_usage_repeat!) }.reduce(0) { result, number in
                            return result + number
                        }
                    ))

                        .foregroundColor(.gray)
                }
            }
            ForEach(applianceGet) { appliance in
                Section("\(appliance.name!) (\(appliance.qty) item\(appliance.qty > 1 ? "s" : ""))") {
                    HStack {
                        Text("\(appliance.name!) load")
                        Spacer()
                        Text("\(appliance.wattage * appliance.qty) watt")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("avgDailyUsage")
                        Spacer()
                        Text("\(appliance.avg_usage) \(appliance.avg_usage_unit!)")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("costPerMinutes")
                        Spacer()
                        Text(formatCurrencyNumber(number: countCostPerMinute(wattage: appliance.wattage) * Float(appliance.qty)))
                        .foregroundColor(.gray)
                    }
                    HStack {
                        Text("costPerHour")
                        Spacer()
                        Text(formatCurrencyNumber(number: countCostPerHour(wattage: appliance.wattage) * Float(appliance.qty)))
                        .foregroundColor(.gray)
                    }
                    HStack {
                        Text("avgDailyCost")
                        Spacer()
                        Text(formatCurrencyNumber(number: countCostPerDay(avgUsageUnit: appliance.avg_usage_unit!, avgUsage: appliance.avg_usage, wattage: appliance.wattage) * Float(appliance.qty)))
                        .foregroundColor(.gray)
                    }
                    HStack {
                        Text("avgMonthlyCost")
                        Spacer()
                        Text(formatCurrencyNumber(number: countCostPerMonth(avgUsageUnit: appliance.avg_usage_unit!, avgUsage: appliance.avg_usage, wattage: appliance.wattage, avgUsageRepeat: appliance.avg_usage_repeat!) * Float(appliance.qty)))
                        .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("calculationResult")
        .onAppear {
            if applianceGet.isEmpty {
                isShowEmptyAlert = true
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .alert(isPresented: $isShowEmptyAlert) {
            Alert(title: Text("noAppliances"), message: Text("noAppliancesAlertMessage"))
        }
    }
    
    func formatCurrencyNumber(number: Float) -> String {
        let formatter = NumberFormatter()
        
        formatter.currencySymbol = "Rp. "
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        
        return formatter.string(from: NSNumber(value: number))!
    }
    
    func countCostPerHour(wattage: Int16) -> Float {
        let result: Float = Float(wattage) / 1000 * Float(electricityRate)!
        return result
    }
    
    func countCostPerMinute(wattage: Int16) -> Float {
        return countCostPerHour(wattage: wattage) / 60
    }
    
    func countCostPerDay(avgUsageUnit: String, avgUsage: Int16, wattage: Int16) -> Float {
        let usageInDay: Float = avgUsageUnit == "Minutes / Day" ? Float(avgUsage) / Float(60) : Float(avgUsage)
        return countCostPerHour(wattage: wattage) * usageInDay
    }
    
    func countCostPerMonth(avgUsageUnit: String, avgUsage: Int16, wattage: Int16, avgUsageRepeat: String) -> Float {
        let usageInMonth: Float = Float(avgUsageRepeat.split(separator: ",").count) * Float(4)
        return countCostPerDay(avgUsageUnit: avgUsageUnit, avgUsage: avgUsage, wattage: wattage) * usageInMonth
    }
}

struct ResultView_Previews: PreviewProvider {
    
    @State static private var electricityRate: String = ""
    
    static var previews: some View {
        ResultView(electricityRate: $electricityRate)
    }
}
