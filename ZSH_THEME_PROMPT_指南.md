## 参考资料

https://blog.carbonfive.com/writing-zsh-themes-a-quickref/

https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

## 效果测试

```shell
# 只能测试PROMPT
print -P "%u@%M"
# 整体效果建议开两个窗口，一个编辑样式，一个终端看效果（source .zshrc）
```
## 转义序列

### ANSI 转义序列

zsh支持ANSI转义序列

### 百分号转义序列

zsh特有的转义序列类型

https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Prompt-Expansion

### $开头变量引用

$name

## visual effects

本质上都是ANSI转义序列，`print -P '%B' | cat -e `查看。

参见 https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Prompt-Expansion 13.2.5

### ==注意==

- visual effects中的转义序列`%B、%U、%F、%K(包括对应的小写)`以及`$fg[]、$bg[](包括bold与no_bold)`，**使用时需要以`%{...%}`包括起来**。例如：`'%{$bg[red]$fg_bold[blue]%}%n%{%b%k%f%}@%M:%~$'`
  否则可能会导致奇怪的现象：RPROMPT的第一个字符在行尾，剩余字符在下一行。
  其他**不改变cursor位置的转义序列**也可以包括在内，但不建议。
- 最好不要连续重复使用`%f、%b、%u、%k` ，例如`(%{%f%f%})`，尤其是使用`$(git_prompt_info)、$(git_prompt_status)`时务必要小心。

### 加粗、下划线

`%B`加粗，`%b`取消

`%U`下划线，`%u`取消

### 颜色

#### 变量引用

自动引入的模块中包含颜色，只需引用变量即可。

```
background: bg、bg_no_bold、bg_bold
foreground: fg、fg_no_bold、fg_bold
均为数组，使用方式以fg为例
$fg指数组, print -P "$fg"会输出所有前景色
$fg[red]其实就是对应的ANSI转义序列, print -P "$fg[red]" |cat -e查看
所有可设定的颜色类型有：cyan, white, yellow, magenta, black, blue, red, grey, green, default(终端默认颜色)
```

#### %转义序列

`spectrum_ls`或`spectrum_ls`查看颜色

`%F{192}`设定前景色为192，`%f`默认色等价于`$fg[default]`

`%K{192}`设定背景色为192，`%k`默认色等价于`$bg[default]`

## 编写示例

用户名@机器名:路径 $ 

```shell
%{%n@%M:%~$%}
```

条件表达式%(`x`.`true-text`.`false-text`), 特权用户还是普通用户，上一次命令执行状态均可作为条件。
