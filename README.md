# L1-MvDA-VC

The repository contains the MatLab code of "Robust multi-view discriminant analysis with view-consistency". This paper can be available at https://www.sciencedirect.com/science/article/pii/S0020025522002158.

代码说明
1、运行步骤
创建路径E:\MatLab2019a\work\RMvDA；将文件复制粘贴到该路径下；运行demo_MNISTUSPS_original.m。

2、文件说明
Data文件夹：保存原始数据，以MNIST-USPS为例
result文件夹：保存数据数据结果，保存为.mat格式（格式参考，非文章中结果）
M文件说明:
L1MvDAVC - L1-MvDA-VC算法
MvObj, myInv, mySVD - L1-MvDA-VC的调用文件，支持L1MvDAVC正常运行
randomSplit - 分训练集和测试集，并添加一定比列的指定类型的噪声
blockPollute - 对某一个数据添加指定的类型的噪声，支持randomSplit的运行
demo_MNISTUSPS_original - 一个运行的demo
knn_classifier_fusion， knn_classifier - demo_MNISTUSPS_original的调用文件，支持demo_MNISTUSPS_original运行

3、作者Email：yxf9011@163.com
