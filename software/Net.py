# snntorch
import snntorch as snn
from snntorch import surrogate

# torch
import torch
import torch.nn as nn
import torch.nn.functional as F

# local
from bnn import *
from conf import *

class NetConv(nn.Module):
    def __init__(self, config):
        super().__init__()

        self.thr1 = config['threshold1']
        self.thr2 = config['threshold2']
        self.thr3 = config['threshold3']
        slope = config['slope']
        beta = config['beta']
        self.num_steps = config['num_steps']
        self.batch_norm = config['enable_batch_norm']
        p1 = config['dropout1']
        self.binarize = config['binarize']
        self.binarize_input = config['binarize_input']
        self.bias = config['enable_bias']
        self.reset_mechanism = 'zero' if config['on_spike_reset_to_zero'] else 'subtract'

        spike_grad = surrogate.fast_sigmoid(slope)
        # Initialize layers with spike operator
        self.bconv1 = BinaryConv2d(1, 16, 5, bias=self.bias)
        self.conv1 = nn.Conv2d(1, 16, 5, bias=self.bias)
        self.conv1_bn = nn.BatchNorm2d(16)
        
        self.lif1 = snn.Leaky(beta, threshold=self.thr1, reset_mechanism=self.reset_mechanism, spike_grad=spike_grad)
        self.bconv2 = BinaryConv2d(16, 64, 5, bias=self.bias)
        self.conv2 = nn.Conv2d(16, 64, 5, bias=self.bias)
        self.conv2_bn = nn.BatchNorm2d(64)
        self.lif2 = snn.Leaky(beta, threshold=self.thr2, reset_mechanism=self.reset_mechanism, spike_grad=spike_grad)
        self.bfc1 = BinaryLinear(64 * 4 * 4, 10, bias=self.bias)
        self.fc1 = nn.Linear(64 * 4 * 4, 10, bias=self.bias)
        self.lif3 = snn.Leaky(beta, threshold=self.thr3, reset_mechanism=self.reset_mechanism, spike_grad=spike_grad)
        self.dropout = nn.Dropout(p1)

    def forward(self, x):

        # Initialize hidden states and outputs at t=0
        mem1 = self.lif1.init_leaky()
        mem2 = self.lif2.init_leaky()
        mem3 = self.lif3.init_leaky()

        # Record the final layer
        spk3_rec = []
        mem3_rec = []

        # Binarized
        if self.binarize:

            for step in range(self.num_steps):

                if self.binarize_input:
                    x = binarize_activations(x)
                cur1 = F.avg_pool2d(self.bconv1(x), 2)
                if self.batch_norm:
                    cur1 = self.conv1_bn(cur1)
                spk1, mem1 = self.lif1(cur1, mem1)
                cur2 = F.avg_pool2d(self.bconv2(spk1), 2)
                if self.batch_norm:
                    cur2 = self.conv2_bn(cur2)
                spk2, mem2 = self.lif2(cur2, mem2)
                cur3 = self.dropout(self.bfc1(spk2.flatten(1)))
                spk3, mem3 = self.lif3(cur3, mem3)

                spk3_rec.append(spk3)
                mem3_rec.append(mem3)

            return torch.stack(spk3_rec, dim=0), torch.stack(mem3_rec, dim=0)

        # Full Precision
        else:

            for step in range(self.num_steps):

                cur1 = F.avg_pool2d(self.conv1(x), 2)
                if self.batch_norm:
                    cur1 = self.conv1_bn(cur1)
                spk1, mem1 = self.lif1(cur1, mem1)
                cur2 = F.avg_pool2d(self.conv2(spk1), 2)
                if self.batch_norm:
                    cur2 = self.conv2_bn(cur2)
                spk2, mem2 = self.lif2(cur2, mem2)
                cur3 = self.dropout(self.fc1(spk2.flatten(1)))
                spk3, mem3 = self.lif3(cur3, mem3)

                spk3_rec.append(spk3)
                mem3_rec.append(mem3)

            return torch.stack(spk3_rec, dim=0), torch.stack(mem3_rec, dim=0)

class NetFC(nn.Module):
    def __init__(self, config, neurons=[256, 128], sparsity=[0.0, 0.0]):
        super().__init__()

        self.thr1 = config['threshold1']
        self.thr2 = config['threshold2']
        self.thr3 = config['threshold3']
        slope = config['slope']
        beta = config['beta']
        self.num_steps = config['num_steps']
        self.batch_norm = config['enable_batch_norm']
        p1 = config['dropout1']
        self.binarize = config['binarize']
        self.binarize_input = config['binarize_input']
        self.bias = config['enable_bias']
        self.reset_mechanism = 'zero' if config['on_spike_reset_to_zero'] else 'subtract'

        spike_grad = surrogate.fast_sigmoid(slope)
        # Initialize layers with spike operator
        if self.binarize:
            self.bfc1 = SparseBinaryLinear(MNIST_INPUT_RESOLUTION * MNIST_INPUT_RESOLUTION, neurons[0], sparsity[0], bias=(self.bias and not self.batch_norm))
        else:
            self.fc1 = nn.Linear(MNIST_INPUT_RESOLUTION * MNIST_INPUT_RESOLUTION, neurons[0], bias=(self.bias and not self.batch_norm))
        if self.batch_norm:
            self.bn1 = nn.BatchNorm1d(neurons[0])
        self.lif1 = snn.Leaky(beta, threshold=self.thr1, reset_mechanism=self.reset_mechanism, spike_grad=spike_grad)

        if self.binarize:
            self.bfc2 = SparseBinaryLinear(neurons[0], neurons[1], sparsity[1], bias=(self.bias and not self.batch_norm))
        else:
            self.fc2 = nn.Linear(neurons[0], neurons[1], bias=(self.bias and not self.batch_norm))
        if self.batch_norm:
            self.bn2 = nn.BatchNorm1d(neurons[1])
        self.lif2 = snn.Leaky(beta, threshold=self.thr2, reset_mechanism=self.reset_mechanism, spike_grad=spike_grad)

        if self.binarize:
            self.bfc3 = BinaryLinear(neurons[1], 10, bias=self.bias)
        else:
            self.fc3 = nn.Linear(neurons[1], 10, bias=self.bias)
        self.lif3 = snn.Leaky(beta, threshold=self.thr3, reset_mechanism=self.reset_mechanism, spike_grad=spike_grad)
        self.dropout = nn.Dropout(p1)

    def forward(self, x):

        # Initialize hidden states and outputs at t=0
        mem1 = self.lif1.init_leaky()
        mem2 = self.lif2.init_leaky()
        mem3 = self.lif3.init_leaky()

        # Record the final layer
        spk3_rec = []
        mem3_rec = []

        # Binarized
        if self.binarize:
            for step in range(self.num_steps):

                x = x.flatten(1)
                if self.binarize_input:
                    x = binarize_activations(x)
                cur1 = self.bfc1(x)
                if self.batch_norm:
                   cur1 = self.bn1(cur1)
                spk1, mem1 = self.lif1(cur1, mem1)
                cur2 = self.bfc2(spk1)
                if self.batch_norm:
                    cur2 = self.bn2(cur2)
                spk2, mem2 = self.lif2(cur2, mem2)
                cur3 = self.dropout(self.bfc3(spk2))
                spk3, mem3 = self.lif3(cur3, mem3)

                spk3_rec.append(spk3)
                mem3_rec.append(mem3)

            return torch.stack(spk3_rec, dim=0), torch.stack(mem3_rec, dim=0)

        # Full Precision
        else:

            for step in range(self.num_steps):

                cur1 = self.fc1(x.flatten(1))
                if self.batch_norm:
                    cur1 = self.bn1(cur1)
                spk1, mem1 = self.lif1(cur1, mem1)
                cur2 = self.fc2(spk1)
                if self.batch_norm:
                    cur2 = self.bn2(cur2)
                spk2, mem2 = self.lif2(cur2, mem2)
                cur3 = self.dropout(self.fc3(spk2))
                spk3, mem3 = self.lif3(cur3, mem3)

                spk3_rec.append(spk3)
                mem3_rec.append(mem3)

            return torch.stack(spk3_rec, dim=0), torch.stack(mem3_rec, dim=0)

