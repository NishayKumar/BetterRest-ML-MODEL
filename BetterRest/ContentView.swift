//
//  ContentView.swift
//  BetterRest
//
//  Created by Nishay Kumar on 31/08/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State var sleepAmound: Double = 8.0
    @State var wakeUp = defaultTime
    @State var coffeeAmount = 1
    
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showingAlert = false
    
    static var defaultTime: Date {
        var component = DateComponents()
        component.hour = 7
        component.minute = 0
        return Calendar.current.date(from: component) ?? Date.now
    }
    
    
    var body: some View {
        NavigationStack{
            Form {
                VStack(alignment: .leading, spacing: 5){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 5){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmound.formatted()) hours", value: $sleepAmound, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 5){
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("\(coffeeAmount) cup", value: $coffeeAmount, in: 1...20)
                }
    //            Text(Date.now.formatted(date: .abbreviated, time: .shortened))
                
                    Section(footer: Text("Press to calcualte the amount of sleep needed")){
                        HStack{
                            Spacer()
                            Button("CALCULATE") {
                                calcuateBedTime()
                            }
                            .font(.title2)
                            .buttonStyle(.bordered)
                            Spacer()
                        }
                    }
                
                    
                    
                    
            }
            .navigationTitle("BetterRest")
            .toolbar {
                
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
        
        
    }
    
    
    func calcuateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 *  60
            let minute = (components.minute ?? 0) * 60
            
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmound, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
