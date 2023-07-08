
import torch
import torch.nn as nn
from torch.autograd import Function


class BinarizeF(Function):
    @staticmethod
    def forward(ctx, input):
        output = input.new(input.size())
        output[input >= 0] = 1
        output[input < 0] = -1
        return output

    @staticmethod
    def backward(ctx, grad_output):
        grad_input = grad_output.clone()
        return grad_input

# aliases
binarize = BinarizeF.apply

def quantize(input):
    #0.5, 0.75, 1, 1.5, 2, 3, 4, 6, 8
    output = input.new(input.size())
    output[input < (6.0+8.0)/2] = 8
    output[input < (4.0+6.0)/2] = 6
    output[input < (4.0+3.0)/2] = 4
    output[input < (3.0+4.0)/2] = 3
    output[input < (2.0+3.0)/2] = 2
    output[input < (1.5+2.0)/2] = 1.5
    output[input < (1.0+1.5)/2] = 1.0
    output[input < (0.75+1.0)/2] = 0.75
    output[input < (0.5+0.75)/2] = 0.5
    #output = input
    #print(output)
    return output
    #return input
    #return torch.ones_like(input)
    #return torch.round(torch.maximum(input, torch.ones_like(input)))

def post_quantize(model):
    print("post quantize model")
    with torch.no_grad():
        for child in model.children():
            if type(child) == SparseBinaryLinear:
                print("sfc", child)
                child.weight = nn.Parameter(binarize(child.weight).to(child.weight.device) * child.mask.to(child.weight.device))
            if type(child) == BinaryLinear:
                print("bfc", child)
                child.weight = nn.Parameter(binarize(child.weight).to(child.weight.device))
            if type(child) == nn.BatchNorm1d:
                print("qbn", child)
                child.weight = nn.Parameter(quantize(child.weight).to(child.weight.device))
    # for n, p in model.named_parameters():
    #     print(n, p)
    return model
#net = NetFC(config)
#post_quantize(net)