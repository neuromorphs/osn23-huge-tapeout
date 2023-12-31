# snntorch
import snntorch as snn
from snntorch import spikegen
from snntorch import surrogate
from snntorch import functional as SF

# torch
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import torch.nn.functional as F
from torch.optim.lr_scheduler import StepLR

# misc
import os
import numpy as np
import math
import itertools
import matplotlib.pyplot as plt
import pandas as pd
import shutil
import time
from tqdm import tqdm

# local imports
from dataloader import *
from test import *
from test_acc import *
from tha import *

def train(config, net, epoch, trainloader, testloader, criterion, optimizer, scheduler, device):
    net.train()
    loss_accum = []
    lr_accum = []

    # TRAIN
    progress_bar = tqdm(trainloader)
    loss_current = None

    #for data, labels in trainloader:
    for data, labels in progress_bar:
        data, labels = data.to(device), labels.to(device)

        spk_rec2, _ = net(data)
        loss = criterion(spk_rec2, labels)
        optimizer.zero_grad()
        loss.backward()
        if loss_current is None:
            loss_current = loss.item()
        else:
            loss_current = 0.9 * loss_current + 0.1 * loss.item()
        progress_bar.set_description(f"loss: {loss_current:.4f}")

        if config['grad_clip']:
            nn.utils.clip_grad_norm_(net.parameters(), 1.0)
        if config['weight_clip']:
            with torch.no_grad():
                for param in net.parameters():
                    param.clamp_(-1, 1)

        optimizer.step()
        scheduler.step()
        thr_annealing(config, net)


        loss_accum.append(loss.item()/config['num_steps'])
        lr_accum.append(optimizer.param_groups[0]["lr"])


    return loss_accum, lr_accum