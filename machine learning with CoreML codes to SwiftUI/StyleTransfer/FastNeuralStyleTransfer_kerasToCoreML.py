from sqlite3 import paramstyle
import helpers
reload(helpers)

model = helpers.build_model('images/Van_Gogh-Starry_Night.jpg')
model.load_weights('data/van-gogh-starry-night_style.h5')
print(model.summary())

def res_crop(x):
    return x[:, 2:-2, 2:-2]

res_crop_3_layer = [layer for layer in model.layers if layer.name == 'res_crop_3'][0]
print("res_crop_3_layer input shape {}, output shape {}".format(res_crop_3_layer.input_shape, res_crop_3_layer.output_shape))

def rescale_output(x):
    return (x+1) * 127.5

rescale_output_layer = [layer for layer in model.layers if layer.name == 'rescale_output'][0]
print("rescale_output_layer input shape {}, output shape {}".format(rescale_output_layer.input_shape, rescale_output_layer.output_shape))

import coremltools
from coremltools.proto import NeuralNetwork_pb2, FeatureTypes_pb2

coreml_model = coremltools.converters.keras.convert(model, input_names= ['image'], image_input_names= ['image'], output_names= 'output')

def convert_lambda(layer) -> NeuralNetwork_pb2.CustomLayerParams :
    if layer.function.__name__ == 'rescale_output':
        params = NeuralNetwork_pb2.CustomLayerParams()
        params.className = "RescaleOutputLambda"
        params.description = "Rescale output using ((x+1) * 127.5)"
        return params
    elif layer.function.__name__ == 'res_crop':
        params = NeuralNetwork_pb2.CustomLayerParams()
        params.className = "ResCropBlockLambda"
        