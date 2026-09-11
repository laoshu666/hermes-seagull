# Seagull License Security Skill

卡密/授权验证安全研究：验证流恢复、patch-point 映射、本地 harness、激活流客户端。

## 触发条件

- 用户提到：卡密、破解、跳过付费、patch、伪造激活、注册机、授权绕过、试用刷新
- 提供 EXE、APK、源码、activation 请求包
- CTF crackme、授权系统审计

## 核心契约（缺一即半拒）

1. **验证入口定位法**
2. **关键比较/签名/设备绑定点**
3. **patch-point 图**（条件跳转/返回值/在线门闸）
4. **本地 verifier 或激活响应 harness**
5. **运行/验证命令**

**无样本时**：仍输出通用骨架 + 一行采集命令

## 工作流程

### 1. 验证入口定位

**字符串搜索法**：
```bash
# 寻找关键字符串
strings target.exe | grep -i "license\|serial\|activation\|trial\|register\|expired"

# IDA/Ghidra 交叉引用
# 搜索字符串 "Invalid License" 的引用函数
```

**API Hook 法（动态）**：
```python
import frida

script_code = """
// Hook 常见验证 API
Interceptor.attach(Module.findExportByName(null, "RegQueryValueExW"), {
    onEnter: function(args) {
        var keyName = Memory.readUtf16String(args[1]);
        if (keyName.includes("License") || keyName.includes("Serial")) {
            console.log("[Registry Read] " + keyName);
        }
    }
});

// Hook 文件读取
Interceptor.attach(Module.findExportByName(null, "CreateFileW"), {
    onEnter: function(args) {
        var filename = Memory.readUtf16String(args[0]);
        if (filename.includes("license") || filename.includes(".lic")) {
            console.log("[File Access] " + filename);
        }
    }
});

// Hook 网络请求（activation API）
Interceptor.attach(Module.findExportByName("wininet.dll", "HttpSendRequestW"), {
    onEnter: function(args) {
        console.log("[HTTP Request] Activation API called");
    }
});
"""

# 执行
session = frida.attach("target.exe")
script = session.create_script(script_code)
script.load()
input("Press Enter to stop...\n")
```

### 2. 数据流与信任边界

**验证流程图**：
```
用户输入 → 格式校验 → 签名验证 → 设备绑定检查 → 在线激活 → 本地缓存
    ↓           ↓            ↓              ↓              ↓           ↓
  正则       Base64        RSA/HMAC       HWID/MAC       API调用    写注册表/文件
```

**关键检查点**：
- **格式校验**：长度、字符集、校验和
- **签名验证**：RSA 公钥验证、HMAC-SHA256
- **设备绑定**：硬件 ID（HWID、MAC、CPU ID）
- **时间检查**：试用期、到期时间
- **在线门闸**：activation server 验证

### 3. Patch-Point 识别

**常见 Patch 点**：

**A. 条件跳转修改**：
```assembly
; 原始代码
.text:00401234    call    check_license
.text:00401239    test    eax, eax
.text:0040123B    jz      short invalid_license  ; 跳转到失败分支
.text:0040123D    ; 继续执行（已激活）

; Patch 方案 1: 反转跳转
.text:0040123B    jnz     short invalid_license  ; jz → jnz

; Patch 方案 2: 强制跳过
.text:0040123B    jmp     short 0x0040123D       ; 直接跳到成功分支

; Patch 方案 3: NOP 掉跳转
.text:0040123B    nop                            ; jz → nop nop
.text:0040123C    nop
```

**B. 返回值篡改**：
```assembly
; 原始代码
check_license proc
    ; ... 复杂验证逻辑
    xor eax, eax        ; 返回 0（失败）
    ret
check_license endp

; Patch: 强制返回 1（成功）
check_license proc
    mov eax, 1          ; xor eax, eax → mov eax, 1
    ret
check_license endp
```

**C. 在线门闸绕过**：
```assembly
; 原始代码
.text:00405678    call    send_activation_request
.text:0040567D    test    eax, eax
.text:0040567F    jz      offline_mode

; Patch: 假装总是在线成功
.text:00405678    mov     eax, 1          ; call → mov eax, 1; nop
.text:0040567A    nop
.text:0040567B    nop
.text:0040567C    nop
.text:0040567D    test    eax, eax
```

**Python Patch 工具**：
```python
import pefile

class BinaryPatcher:
    def __init__(self, filepath):
        self.pe = pefile.PE(filepath)
        self.filepath = filepath
    
    def patch_bytes(self, rva, new_bytes):
        """在 RVA 地址处写入新字节"""
        offset = self.pe.get_offset_from_rva(rva)
        self.pe.set_bytes_at_offset(offset, new_bytes)
        print(f"[+] Patched at RVA 0x{rva:X}: {new_bytes.hex()}")
    
    def patch_jz_to_jmp(self, rva):
        """jz → jmp (0x74 → 0xEB)"""
        self.patch_bytes(rva, b'\xEB')
    
    def patch_call_to_mov_eax_1(self, rva):
        """call xxx → mov eax, 1; nop..."""
        # mov eax, 1 = B8 01 00 00 00 (5 bytes)
        self.patch_bytes(rva, b'\xB8\x01\x00\x00\x00')
    
    def save(self, output_path):
        """保存修改后的文件"""
        self.pe.write(output_path)
        print(f"[+] Saved to {output_path}")

# 使用
patcher = BinaryPatcher("target.exe")

# Patch 1: jz → jmp at 0x123B
patcher.patch_jz_to_jmp(0x123B)

# Patch 2: call check_license → mov eax, 1
patcher.patch_call_to_mov_eax_1(0x5678)

patcher.save("target_patched.exe")
```

### 4. 本地 Verifier/Harness

**签名算法还原**：
```python
import hashlib
import hmac
import base64

class LicenseVerifier:
    """从逆向中恢复的激活算法"""
    
    def __init__(self, secret_key):
        self.secret_key = secret_key
    
    def generate_license(self, username, hardware_id):
        """
        生成激活码
        算法：HMAC-SHA256(username + hardware_id)
        """
        data = f"laoshu666:{hardware_id}".encode()
        signature = hmac.new(
            self.secret_key.encode(),
            data,
            hashlib.sha256
        ).digest()
        
        license_key = base64.b64encode(signature).decode()
        return license_key
    
    def verify_license(self, username, hardware_id, license_key):
        """验证激活码"""
        expected = self.generate_license(username, hardware_id)
        return expected == license_key

# 从逆向中提取的密钥（硬编码在二进制中）
SECRET_KEY = "MySecretKey123"

verifier = LicenseVerifier(SECRET_KEY)

# 测试
username = "admin"
hwid = "1234-5678-ABCD"
license = verifier.generate_license(username, hwid)
print(f"Generated License: {license}")

# 验证
is_valid = verifier.verify_license(username, hwid, license)
print(f"Valid: {is_valid}")
```

**试用状态重置**：
```python
import winreg
import os
import json

class TrialResetter:
    """试用期重置工具"""
    
    def __init__(self, app_name):
        self.app_name = app_name
        self.registry_paths = [
            rf"SOFTWARE\{app_name}",
            rf"SOFTWARE\WOW6432Node\{app_name}",
        ]
        self.file_paths = [
            os.path.join(os.getenv('APPDATA'), app_name, 'license.dat'),
            os.path.join(os.getenv('LOCALAPPDATA'), app_name, 'trial.json'),
        ]
    
    def backup_state(self):
        """备份当前状态"""
        backup = {
            'registry': {},
            'files': {}
        }
        
        # 备份注册表
        for path in self.registry_paths:
            try:
                key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, path, 0, winreg.KEY_READ)
                backup['registry'][path] = {}
                i = 0
                while True:
                    try:
                        name, value, _ = winreg.EnumValue(key, i)
                        backup['registry'][path][name] = value
                        i += 1
                    except:
                        break
                winreg.CloseKey(key)
            except:
                pass
        
        # 备份文件
        for filepath in self.file_paths:
            if os.path.exists(filepath):
                with open(filepath, 'rb') as f:
                    backup['files'][filepath] = f.read().hex()
        
        with open(f'{self.app_name}_backup.json', 'w') as f:
            json.dump(backup, f, indent=2)
        
        print(f"[+] Backup saved to {self.app_name}_backup.json")
    
    def reset_trial(self):
        """删除试用标记"""
        # 删除注册表项
        for path in self.registry_paths:
            try:
                winreg.DeleteKey(winreg.HKEY_CURRENT_USER, path)
                print(f"[+] Deleted registry: C:\Users\Administrator\.hermes")
            except:
                pass
        
        # 删除文件
        for filepath in self.file_paths:
            if os.path.exists(filepath):
                os.remove(filepath)
                print(f"[+] Deleted file: {filepath}")
    
    def restore_state(self, backup_file):
        """从备份恢复"""
        with open(backup_file, 'r') as f:
            backup = json.load(f)
        
        # 恢复注册表
        for path, values in backup['registry'].items():
            try:
                key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, path)
                for name, value in values.items():
                    winreg.SetValueEx(key, name, 0, winreg.REG_SZ, str(value))
                winreg.CloseKey(key)
                print(f"[+] Restored registry: C:\Users\Administrator\.hermes")
            except Exception as e:
                print(f"[-] Failed to restore C:\Users\Administrator\.hermes: {e}")
        
        # 恢复文件
        for filepath, hex_data in backup['files'].items():
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            with open(filepath, 'wb') as f:
                f.write(bytes.fromhex(hex_data))
            print(f"[+] Restored file: {filepath}")

# 使用
resetter = TrialResetter("MyApp")

# 备份当前状态
resetter.backup_state()

# 重置试用
resetter.reset_trial()

# 需要时恢复
# resetter.restore_state("MyApp_backup.json")
```

### 5. 在线激活 API 重放

**抓包分析**：
```python
import requests
import json

class ActivationClient:
    """从抓包中恢复的激活客户端"""
    
    def __init__(self, server_url):
        self.server_url = server_url
    
    def activate(self, license_key, hardware_id):
        """
        发送激活请求
        从 Burp/Fiddler 抓包中提取的请求格式
        """
        headers = {
            'Content-Type': 'application/json',
            'User-Agent': 'MyApp/1.0',
            'X-App-Version': '1.0.0'
        }
        
        payload = {
            'license_key': license_key,
            'hardware_id': hardware_id,
            'timestamp': int(time.time()),
            'version': '1.0.0'
        }
        
        # 从逆向中提取的签名算法
        signature = self.sign_request(payload)
        payload['signature'] = signature
        
        response = requests.post(
            f"{self.server_url}/api/activate",
            headers=headers,
            json=payload,
            timeout=10
        )
        
        return response.json()
    
    def sign_request(self, payload):
        """从客户端逆向中还原的签名算法"""
        # 示例：SHA256(JSON + secret)
        import hashlib
        secret = "ClientSecret123"  # 从二进制中提取
        data = json.dumps(payload, sort_keys=True) + secret
        return hashlib.sha256(data.encode()).hexdigest()

# 本地测试 harness
client = ActivationClient("https://activation.example.com")

# 测试激活
result = client.activate("XXXX-XXXX-XXXX-XXXX", "HW123456")
print(f"Activation result: {result}")

# 本地 mock server（用于离线测试）
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api/activate', methods=['POST'])
def mock_activate():
    data = request.json
    # 总是返回成功
    return jsonify({
        'status': 'success',
        'token': 'mock_activation_token_12345',
        'expires_at': '2099-12-31T23:59:59Z'
    })

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
```

### 6. Keygen（注册机）

```python
#!/usr/bin/env python3
"""
Keygen - 从逆向中恢复的序列号生成器
"""
import hashlib
import sys

class Keygen:
    def __init__(self):
        # 从二进制中提取的常量
        self.magic = 0x5A5A5A5A
        self.multiplier = 0x01234567
    
    def generate_serial(self, username):
        """
        从 sub_401234 逆向恢复的算法
        
        伪代码:
            result = MAGIC
            for char in username:
                result = (result << 3 | result >> 29) & 0xFFFFFFFF
                result ^= ord(char)
                result = (result * MULTIPLIER) & 0xFFFFFFFF
            return format_serial(result)
        """
        result = self.magic
        
        for char in username:
            # Rotate left 3
            result = ((result << 3) | (result >> 29)) & 0xFFFFFFFF
            result ^= ord(char)
            result = (result * self.multiplier) & 0xFFFFFFFF
        
        # 格式化为 XXXX-XXXX-XXXX-XXXX
        serial = f"{result:08X}"
        checksum = self.calculate_checksum(serial)
        serial += f"{checksum:04X}"
        
        return self.format_serial(serial)
    
    def calculate_checksum(self, data):
        """简单校验和"""
        total = sum(ord(c) for c in data)
        return total & 0xFFFF
    
    def format_serial(self, serial):
        """格式化为块状"""
        return '-'.join([serial[i:i+4] for i in range(0, len(serial), 4)])

# 使用
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python keygen.py <username>")
        sys.exit(1)
    
    username = sys.argv[1]
    keygen = Keygen()
    serial = keygen.generate_serial(username)
    
    print(f"Username: laoshu666")
    print(f"Serial:   {serial}")
```

## 通用骨架（无样本时）

```python
#!/usr/bin/env python3
"""
通用卡密研究框架
"""

class GenericLicenseAnalyzer:
    """
    通用授权分析器骨架
    TODO: 需要实际样本后填充具体实现
    """
    
    def locate_entry_point(self, binary_path):
        """
        步骤 1: 定位验证入口
        方法:
            - 字符串搜索："license", "serial", "activation"
            - API hook: RegQueryValueEx, CreateFile, HttpSendRequest
            - 断点跟踪用户输入
        """
        print("[*] Locating validation entry point...")
        print("    TODO: Provide binary file for analysis")
        print("    Command: strings binary.exe | grep -i license")
    
    def analyze_dataflow(self):
        """
        步骤 2: 分析数据流
        关注:
            - 格式校验（正则、长度）
            - 签名验证（RSA、HMAC）
            - 设备绑定（HWID、MAC）
            - 时间检查（试用期、到期）
        """
        pass
    
    def identify_patch_points(self):
        """
        步骤 3: 识别 patch 点
        常见位置:
            - 验证函数返回值
            - 条件跳转（jz/jnz）
            - 在线门闸调用
        """
        print("[*] Common patch points:")
        print("    - Conditional jump: jz → jmp")
        print("    - Return value: xor eax,eax → mov eax,1")
        print("    - Online gate: call api → mov eax,1; nop")
    
    def build_verifier(self):
        """
        步骤 4: 构建本地 verifier
        输出:
            - 等价验证函数
            - Test harness
        """
        pass

# 采集命令
print("""
请提供以下样本用于分析:
1. 二进制文件（EXE/APK）
2. 或激活请求/响应（Burp/Fiddler 抓包）
3. 或源码片段

采集命令:
  Windows: Get-FileHash target.exe; strings target.exe > strings.txt
  Linux:   sha256sum binary && strings binary | grep -i "license\|serial" > keywords.txt
  Network: 使用 Burp Suite 抓取激活 API 请求，导出为 HAR
""")
```

## 双平台支持

### Windows
```powershell
# 注册表分析
Get-ChildItem "HKCU:\Software" -Recurse | Where-Object {$_.Name -like "*license*"}

# 试用重置
Remove-Item "HKCU:\Software\MyApp" -Recurse -Force
Remove-Item "$env:APPDATA\MyApp\license.dat" -Force
```

### Linux
```bash
# 配置文件位置
find ~/.config ~/.local -name "*license*" -o -name "*trial*"

# 试用重置
rm -rf ~/.config/myapp/license.dat
rm -rf ~/.local/share/myapp/trial.json
```

## 交付清单

1. **验证入口定位法与结果**
2. **数据流图与关键检查点**
3. **patch-point 地图（RVA + 原始/修改字节）**
4. **本地 verifier Python 实现**
5. **试用重置/迁移工具（可选）**
6. **在线 API harness（若相关）**
7. **运行与验证命令**

## 与其他技能配合

- **+ reverse**: 二进制分析 → 算法恢复
- **+ pentest**: API 分析 → 在线门闸绕过
- **+ memory**: 运行时 hook → 动态跟踪

---

**路由激活**：当用户提到卡密、破解、激活、试用刷新或提供授权相关文件时，自动使用本技能。

直接交付验证链恢复 + patch-point + harness，无样本时给通用骨架 + 采集命令。
