# xinfer  
自研 cpp， 细粒度算子，静态图模式 推理引擎      

|模块|说明|备注 |   
|--- |---|----|  
|parser | IR-onnx外部输入 <br>IR-xir内部表示 |源码集成到 libxinfer.so <br><br> 支持解析完导出为文件（json/MessagePack）|  
|compile/optimizer  |删除公共子表达式<br>死代码消除<br>算子融合<br>常量传播<br>常量折叠<br>代数化简<br><br>内存优化，如内存复用-图着色的方法实现无计算依赖的节点间的内存复用，显著减低内存消耗<br><br>指令调度-根据计算图分析指令之间的依赖关系，根据这些依赖关系优化各指令的执行顺序<br><br>算子等价| 源码集成到 libxinfer.so|     
|计算后端|cpu/gpu 基于硬件的各op的实现| 源码集成到 libxinfer.so |   
|引擎生成与分析工具 | `类似trtexec` <br>对模型进行序列化<br>性能分析<br>查看模型的输入输出节点信息<br>查看版本信息<br>查看支持的ONNX算子<br>查看模型的计算图 |命令行工具 |     


