//
//  ContentView.swift
//  coreml_regression
//
//  Created by mystic on 2022/04/05.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State var prediction_result : String = "regression_test"
    @State var prediction_number : Double = 1
    var body: some View {
        let mlModel : regression_test = {
            do {
                let config = MLModelConfiguration()
                return try regression_test(configuration: config)
            } catch{
                print(error)
                fatalError("couldn't")
            }
        }()
        VStack {
            Text("current_number:\(Int(prediction_number))")
            Text("prediction:\(prediction_result)")
                .padding()
            
            HStack{
                Button {
                    let prediction = try?mlModel.prediction(fill: prediction_number)
                    prediction_result = String(Int(prediction!.solution))
                } label: {
                    Text("changebutton")
                }
                Spacer()
                Button {
                    prediction_number = prediction_number + 1
                } label: {
                    Text("Pluspredict")
                }

            }

        }.preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
