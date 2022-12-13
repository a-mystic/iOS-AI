import CreateML
import Foundation

let dataFile = URL(fileURLWithPath: "/Users/mystic/Downloads/linear_regression.csv")
let data = try MLDataTable(contentsOf: dataFile)
print(data.size)

let (trainData, testData) = data.randomSplit(by: 0.8, seed: 0)
let params = MLBoostedTreeRegressor.ModelParameters(maxIterations:500)
let model = try MLBoostedTreeRegressor(trainingData: trainData, targetColumn: "solution", parameters : params)
let saveModel = MLModelMetadata(author: "mystic", shortDescription: ".", license: ".")
try model.write(to: URL(fileURLWithPath: "/Users/mystic/Downloads/linear_regression.mlmodel"), metadata: saveModel)
//print(try model.predictions(from: testData))
//print(testData)
