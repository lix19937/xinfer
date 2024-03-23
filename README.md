# xinfer  推理引擎     
## 特色   
+ 自研  
+ cpp/cu
+ 单级SSA IR   
+ 细粒度算子   
+ 静态图模式         
+ 支持cnn
+ 支持LLM
  
## 模块设计    
|模块|说明|备注 |   
|--- |---|----|  
|parser | IR-onnx外部输入 <br>IR-xir内部表示 |源码集成到 libxinfer.so <br><br> 支持解析完导出为文件（json/MessagePack）|  
|compile/optimizer  |删除公共子表达式<br>死代码消除<br>算子融合<br>常量传播<br>常量折叠<br>代数化简<br><br>内存优化，如内存复用-图着色的方法实现无计算依赖的节点间的内存复用，显著减低内存消耗<br><br>指令调度-根据计算图分析指令之间的依赖关系，根据这些依赖关系优化各指令的执行顺序<br><br>算子等价| 源码集成到 libxinfer.so|     
|计算后端|cpu/gpu 基于硬件的各op的实现| 源码集成到 libxinfer.so |   
|引擎生成与分析工具 | `类似trtexec` <br>对模型进行序列化<br>性能分析<br>查看模型的输入输出节点信息<br>查看版本信息<br>查看支持的ONNX算子<br>查看模型的计算图 |命令行工具 |     
## 结构设计   
|数据结构  |说明|其他|  
|----     |--- |----|  
|shape| 数据类型，各维度的大小，各维度的步长||   
|argument|用来保存数据，类似torch中的Tensor，常用来保存模型的输入和输出数据||   
|literal|常量，比如可以使用literal表示卷积的权重。实际上literal是一种特殊的argument，literal中的值不能修改，而argument中的值可以修改。||   
|instruction|表示指令，可以通过module中的add_instruction()成员函数添加指令。相当于ONNX模型中的一个节点或者torch模型中的一个layer。指令由操作符(算子)和操作数组成。||   
|module|表示子图，每个子图又是由指令组成。创建program的时候，会自动创建一个主计算图，可以通过program的 `get_main_module()`获取主计算图。|   |     
|program|表示一个神经网络模型||   
|target|支持的硬件平台|CPU和GPU，在编译模型的时候，需要指定一个target。|   |   


