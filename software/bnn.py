import math

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Function
from torch.autograd import Variable


class BinaryLinear(nn.Linear):
    def forward(self, input):
        binary_weight = binarize(self.weight)
        if self.bias is None:
            return F.linear(input, binary_weight)
        else:
            return F.linear(input, binary_weight, self.bias)

    def reset_parameters(self):
        # Glorot initialization
        in_features, out_features = self.weight.size()
        stdv = math.sqrt(1.5 / (in_features + out_features))
        self.weight.data.uniform_(-stdv, stdv)
        if self.bias is not None:
            self.bias.data.zero_()

        self.weight.lr_scale = 1. / stdv

class SparseBinaryLinear(nn.Linear):
    def __init__(self, in_features, out_features, sparsity=0, bias=True, device=None, dtype=None):
        super(SparseBinaryLinear, self).__init__(in_features, out_features, bias, device, dtype)
        self.mask = torch.bernoulli(torch.ones_like(self.weight) * (1-sparsity))
        self.register_buffer('weight_mask_const', self.mask)
        print(self.mask.mean())

    def forward(self, input):
        input = binarize_activations(input)
        binary_weight = binarize(self.weight).mul(Variable(self.weight_mask_const))
        #print(self.weight_mask_const.mean(), binary_weight.mean())
        if self.bias is None:
            return F.linear(input, binary_weight)
        else:
            return F.linear(input, binary_weight, self.bias)

    def reset_parameters(self):
        # Glorot initialization 
        in_features, out_features = self.weight.size()
        stdv = math.sqrt(1.5 / (in_features + out_features))
        self.weight.data.uniform_(-stdv, stdv)
        if self.bias is not None:
            self.bias.data.zero_()

        self.weight.lr_scale = 1. / stdv

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

def binarize_activations(input):
    output = input.new(input.size())
    output[input >= 0.5] = 1
    output[input < 0.5] = 0
    return output

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
                #print("sfc", child)
                child.weight = nn.Parameter(binarize(child.weight).to(child.weight.device) * child.mask.to(child.weight.device))
            if type(child) == BinaryLinear:
                #print("bfc", child)
                child.weight = nn.Parameter(binarize(child.weight).to(child.weight.device))
            if type(child) == nn.BatchNorm1d:
                #print("qbn", child)
                child.weight = nn.Parameter(quantize(child.weight).to(child.weight.device))
    # for n, p in model.named_parameters():
    #     print(n, p)
    return model
