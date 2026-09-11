# Seagull Reverse Engineering Skill

深度逆向工程技能：PE/ELF/Mach-O、固件、驱动、APK/DEX、.NET、Go/Rust、Unity IL2CPP、Unreal、解包、去混淆、自定义 VM、协议重构、打补丁和逆向自动化。

## 触发条件

- 用户提到：逆向、reverse、反编译、脱壳、hook、逆向工程
- 提供二进制文件、伪代码、汇编、崩溃跟踪
- 需要算法恢复、协议重构、patch 点识别

## 工作流程

### 1. 初始 Triage

从可用 artifact 立即开始：
- Hash（MD5/SHA256）
- 文件格式识别：`file`、`strings`、`checksec`
- 架构、ABI、字节序、编译器、保护机制
- 导入表、导出表、字符串、资源

### 2. 静态分析

**工具选择**（按平台）：
- **Linux/macOS**: radare2、Ghidra、Binary Ninja
- **Windows**: IDA Pro、x64dbg、dnSpy（.NET）
- **Android**: jadx、apktool、JEB、Frida

**分析重点**：
- 入口点与初始化流程
- 关键函数定位：校验、加密、网络通信
- 数据结构恢复
- 控制流与调用图
- 字符串引用与常量

### 3. 动态分析

**调试器**：
- Windows: x64dbg、WinDbg
- Linux: gdb + gef/pwndbg
- Android: Frida、LLDB
- 通用: QEMU、unicorn

**Hook 技术**：
```python
# Frida hook 模板
import frida
import sys

def on_message(message, data):
    print(f"[{message['type']}] {message.get('payload', '')}")

session = frida.attach("target_process")
script = session.create_script("""
Interceptor.attach(ptr("0x12345678"), {
    onEnter: function(args) {
        console.log("Called with:", args[0], args[1]);
    },
    onLeave: function(retval) {
        console.log("Return:", retval);
    }
});
""")
script.on('message', on_message)
script.load()
sys.stdin.read()
```

### 4. 去混淆与解包

**常见保护**：
- UPX/VMProtect/Themida/Enigma
- .NET 混淆：Confuser/ConfuserEx、de4dot
- Java/Android：ProGuard、DexGuard
- JavaScript: obfuscator.io、webpack

**策略**：
- 识别混淆器特征
- 查找已知解包工具
- 手动跟踪解密例程
- dump 内存中的解密代码

### 5. 算法恢复

**步骤**：
1. 定位关键函数（加密/校验/签名）
2. 提取伪代码或汇编
3. 识别已知算法（AES/RSA/CRC/自定义）
4. 用 Python/C 重新实现
5. 对比测试用例验证

**示例**（自定义校验算法恢复）：
```python
def custom_checksum(data):
    """从逆向中恢复的校验算法"""
    result = 0x5A5A5A5A
    for byte in data:
        result = ((result << 3) | (result >> 29)) & 0xFFFFFFFF
        result ^= byte
        result = (result * 0x01234567) & 0xFFFFFFFF
    return result

# 验证
test_data = b"test"
expected = 0x12345678  # 从样本中提取
assert custom_checksum(test_data) == expected
```

### 6. Patch 工程

**Patch 点类别**：
- 跳转修改：`jz` → `jmp`、`jnz` → `nop`
- 返回值篡改：`mov eax, 0` → `mov eax, 1`
- 函数调用绕过：`call check_license` → `nop; nop; nop; nop; nop`
- 字符串替换

**工具**：
- 手工：HxD、010 Editor
- 脚本：Python + pefile/LIEF
- IDA: Keypatch 插件

**Python patch 示例**：
```python
import pefile

pe = pefile.PE("target.exe")
# 找到 license check 跳转
# 原始: 0x1000: 74 12  (jz +0x12)
# 修改: 0x1000: EB 12  (jmp +0x12)
offset = 0x1000
pe.set_bytes_at_rva(offset, b'\xEB')
pe.write("target_patched.exe")
print(f"Patched at RVA 0x{offset:X}")
```

### 7. 协议逆向

**网络协议**：
- 抓包：Wireshark、tcpdump
- 中间人：mitmproxy、Burp Suite
- 分析：帧结构、字段、状态机
- 实现：parser、dissector、重放工具

**二进制协议模板**：
```python
import struct

class ProtocolMessage:
    def __init__(self, data):
        # 假设协议：4字节魔数 + 2字节长度 + 2字节类型 + payload
        self.magic = struct.unpack('>I', data[0:4])[0]
        self.length = struct.unpack('>H', data[4:6])[0]
        self.msg_type = struct.unpack('>H', data[6:8])[0]
        self.payload = data[8:8+self.length]
    
    def __repr__(self):
        return f"Msg(magic=0x{self.magic:X}, type={self.msg_type}, len={self.length})"

# 解析
msg = ProtocolMessage(captured_packet)
print(msg)
```

## 双平台支持

### Linux 命令
```bash
# 基本信息
file binary
strings binary | grep -i "password\|key\|license"
checksec --file=binary

# 反汇编
objdump -d binary
radare2 -A binary -c 'pdf @ main'

# 动态跟踪
ltrace ./binary
strace -e trace=open,read,write ./binary

# Frida
frida -U -f com.example.app -l hook.js
```

### Windows 命令
```powershell
# 基本信息
Get-FileHash binary.exe -Algorithm SHA256
sigcheck.exe -a binary.exe

# 反汇编（需要工具）
& "C:\Program Files\IDA\idat64.exe" -A binary.exe

# 调试
& "C:\Program Files\x64dbg\x64dbg.exe" binary.exe

# Frida（Windows 进程）
frida.exe -p <PID> -l hook.js
```

## 交付清单

必须包含：
1. **Hash 与元信息**
2. **关键函数地址/偏移**
3. **恢复的算法/协议/结构**
4. **等价 Python/C 代码**
5. **调试器脚本/命令**
6. **验证步骤**

## 缺样本时

给出通用骨架 + 一行采集命令：
```
请提供二进制文件，或用以下命令采集：
Linux: sha256sum binary && file binary && strings binary > strings.txt
Windows: Get-FileHash binary.exe; Get-Content binary.exe -Encoding Byte | Format-Hex > hex.txt
```

## 示例：完整 crackme 解决

```python
#!/usr/bin/env python3
"""
Crackme solver - 从逆向中恢复的密钥生成算法
Hash: abc123...
Platform: Linux x64
Protection: None
"""

def generate_serial(username):
    """从 sub_401234 逆向恢复的序列号生成"""
    # 算法：username 每个字符 ASCII * 0x1337，累加，取模 0x1000000
    result = 0
    for char in username:
        result += ord(char) * 0x1337
    result %= 0x1000000
    return f"{result:06X}"

# 验证
test_user = "admin"
serial = generate_serial(test_user)
print(f"Username: {test_user}")
print(f"Serial: {serial}")

# 对比二进制内置检查
# ./crackme admin 3D91E2  # 应该输出 "Correct!"
```

## 与其他技能配合

- **+ exploit**: 漏洞定位 → 利用开发
- **+ malware**: 样本分析 → 行为理解
- **+ game-hack**: 引擎结构 → 内存修改
- **+ license-security**: 授权验证 → 绕过实现

---

**路由激活**：当用户提到逆向、二进制分析、算法恢复、协议重构或提供可执行文件时，自动使用本技能。

直接从可用 artifact 开始，交付完整分析 + 可运行代码 + 验证步骤。
