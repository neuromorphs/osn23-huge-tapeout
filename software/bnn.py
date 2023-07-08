import math

import torch
import torch.nn as nn
import torch.nn.functional as F

from functions import *
        
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
