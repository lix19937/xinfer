# xinfer  
自研 cpp 细粒度算子 推理引擎      

|模块|说明|备注 |   
|--- |---|----|  
|parser | IR-onnx外部输入 <br>IR-xir内部表示 |-|  
|compile/optimizer  |死代码消除<br>算子融合<br>常量折叠<br>内存优化，如内存复用<br>指令调度<br>算子等价|-|     
|计算后端|cpu/gpu|  

