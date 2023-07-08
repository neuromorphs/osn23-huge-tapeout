# snntorch
import snntorch as snn
from snntorch import spikegen
from snntorch import surrogate

# torch
import copy
import torch
import torch.nn as nn
from torch.utils.data import DataLoader

# misc
import numpy as np
import pandas as pd
import time
import logging

# local imports
from dataloader import *
from Net import *
from test_acc import *
from train import *
from earlystopping import *
from conf import *

def run(config):
    print(config)
    file_name = config['exp_name']

    for trial in range(config['num_trials']):
        # file names
        SAVE_CSV = config['save_csv']
        SAVE_MODEL = config['save_model']
        csv_name = file_name + '_t' + str(trial) + '.csv'
        log_name = file_name + '_t' + str(trial) + '.log'
        model_name = file_name + '_t' + str(trial) + '.pt'
        num_epochs = config['num_epochs']
        torch.manual_seed(config['seed'])

        # dataframes
        df_train_loss = pd.DataFrame()
        df_test_acc = pd.DataFrame(columns=['epoch', 'test_acc', 'train_time'])
        df_lr = pd.DataFrame()

        # initialize network
        net = None
        net_desc = config['model']
        if net_desc in globals():
            klass = globals()[net_desc]
            net = klass(config)
        else:
            net = eval(net_desc)
        if trial == 0:
            print(net)
        device = "cpu"
        if torch.cuda.is_available():
            device = "cuda:0"
            if torch.cuda.device_count() > 1:
                net = nn.DataParallel(net)
        net.to(device)

        # net params
        criterion = SF.mse_count_loss(correct_rate=config['correct_rate'], incorrect_rate=config['incorrect_rate'])
        optimizer, scheduler = optim_func(net, config)

        # early stopping condition
        if config['early_stopping']:
            early_stopping = EarlyStopping_acc(patience=config['patience'], verbose=True, path=model_name)
            early_stopping.early_stop = False
            early_stopping.best_score = None

        # load data
        trainset, testset = load_data(config)
        config['dataset_length'] = len(trainset)
        trainloader = DataLoader(trainset, batch_size=int(config["batch_size"]), shuffle=True)
        testloader = DataLoader(testset, batch_size=int(config["batch_size"]), shuffle=False)

        print(f"=======Trial: {trial}=======")

        for epoch in range(num_epochs):

            # train
            start_time = time.time()
            loss_list, lr_list = train(config, net, epoch, trainloader, testloader, criterion, optimizer, scheduler, device)
            epoch_time = time.time() - start_time

            # test
            test_acc = test_accuracy(config, net, testloader, device)
            print(f'Epoch: {epoch} \tTest Accuracy: {test_acc}')

            if config['df_lr']:
                df_lr = pd.concat([df_lr, pd.DataFrame(lr_list)])
            df_train_loss = pd.concat([df_train_loss, pd.DataFrame(loss_list)])
            test_data = pd.DataFrame([[epoch, test_acc, epoch_time]], columns = ['epoch', 'test_acc', 'train_time'])
            df_test_acc = pd.concat([df_test_acc, test_data])

            if SAVE_CSV:
                df_train_loss.to_csv('loss_' + csv_name, index=False)
                df_test_acc.to_csv('acc_' + csv_name, index=False)
                if config['df_lr']:
                    df_lr.to_csv('lr_' + csv_name, index=False)

            if config['early_stopping']:
                early_stopping(test_acc, net)

                if early_stopping.early_stop:
                    print("Early stopping")
                    early_stopping.early_stop = False
                    early_stopping.best_score = None
                    break

            if SAVE_MODEL and not config['early_stopping']:
                torch.save(net.state_dict(), model_name)

            if config['print_weights']:
                for name, param in net.named_parameters():
                    print(name, param)

            if config['post_quantize']:
                net_quantized = post_quantize(copy.deepcopy(net))
                test_acc_q = test_accuracy(config, net_quantized, testloader, device)
                print(f'Epoch: {epoch} \tTest Quantized Accuracy: {test_acc_q}')
                if (test_acc_q < test_acc * 0.5):
                    for name, param in net.named_parameters():
                        print(name, param)

        # net.load_state_dict(torch.load(model_name))


cfg = config.copy()
cfg['model'] = 'NetFC(config,sparsity=[0.125, 0.5])'
run(cfg)
